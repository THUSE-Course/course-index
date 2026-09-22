# kubectl 使用指南

`kubectl` 是 Kubernetes 的命令行客户端。它通过 kubeconfig 中记录的集群地址和凭据访问 SECoder Kubernetes API，可用于查看资源、读取日志、进入容器以及应用配置。

## 安装

请按照 Kubernetes 官方的 [Install Tools](https://kubernetes.io/docs/tasks/tools/) 页面选择 Linux、macOS 或 Windows 的安装方法。安装完成后检查客户端：

```bash
kubectl version --client
```

## 配置 SECoder 集群

在 SECoder 的 **个人资料**页面点击 **下载 kubectl 配置**，保存得到的 `u-<学号>.kubeconfig` 文件。

!!! warning "kubeconfig 是凭据"

    kubeconfig 的权限等同于账户密码。不要把它提交到 Git 仓库、发送给其他人或放进项目目录。若文件泄露，应立即在 SECoder 个人资料页面轮换 API 令牌并重新下载。

在 Linux 或 macOS 上先限制文件权限：

```bash
chmod 600 /path/to/u-2026000000.kubeconfig
```

最稳妥的方式是在每条命令中显式指定配置文件：

```bash
kubectl --kubeconfig=/path/to/u-2026000000.kubeconfig get pods
```

也可以在当前终端设置环境变量：

```bash
export KUBECONFIG=/path/to/u-2026000000.kubeconfig
kubectl get pods
```

首先确认当前上下文和默认命名空间：

```bash
kubectl config current-context
kubectl config view --minify --output 'jsonpath={..namespace}'
echo
kubectl auth can-i get pods
```

正常情况下，配置文件已经将默认命名空间设为 `u-<学号>`，后续命令无需重复添加 `-n`。如果你同时使用多个集群，执行命令前务必再次确认当前上下文。

## 常见资源

|资源|常用缩写|用途|
|-|-|-|
|Pod|`po`|运行一个或多个容器|
|Deployment|`deploy`|维护无状态应用的 Pod|
|StatefulSet|`sts`|维护需要稳定身份或存储的 Pod|
|Service|`svc`|为 Pod 提供稳定的集群内地址|
|HTTPRoute|无|将外部域名和路径转发到 Service|
|ConfigMap|`cm`|保存非敏感配置|
|Secret|无|保存敏感配置或 Registry 凭据|
|PersistentVolumeClaim|`pvc`|申请持久存储|

## 查看资源

列出常用资源：

```bash
kubectl get pods
kubectl get deployment,statefulset,service,httproute
kubectl get pods -o wide
kubectl get events --sort-by=.metadata.creationTimestamp
```

使用标签筛选属于某个应用的 Pod：

```bash
kubectl get pods -l app.kubernetes.io/name=app-2026-next-hw
```

查看单个资源的详细状态和事件：

```bash
kubectl describe pod/<pod-name>
kubectl describe deployment/app-2026-next-hw
kubectl get httproute/route-2026-next-hw -o yaml
```

`describe` 适合查看调度、镜像拉取、探针和挂载错误；`-o yaml` 适合检查控制器写入的完整状态字段。

## 日志和容器终端

读取日志：

```bash
kubectl logs <pod-name>
kubectl logs -f <pod-name>
kubectl logs --tail=200 <pod-name>
kubectl logs --previous <pod-name>
```

Pod 包含多个容器时，用 `-c` 指定容器：

```bash
kubectl logs <pod-name> -c <container-name>
```

在运行中的容器里执行命令：

```bash
kubectl exec -it <pod-name> -- /bin/sh
```

镜像不一定包含 Bash，因此优先尝试 `/bin/sh`。不要在容器内直接修改程序或配置：Pod 被重建后这些修改会丢失，应回到 Git 仓库修改声明文件并重新部署。

临时把本机端口转发到 Service：

```bash
kubectl port-forward service/app-2026-next-hw 8080:80
```

随后可以通过 `http://127.0.0.1:8080` 测试服务。这只在命令运行期间有效，不会创建外部域名。

## 预览和应用配置

渲染 Kustomize 配置，不访问或修改集群：

```bash
kubectl kustomize deploy
```

比较本地声明与集群状态：

```bash
kubectl diff -k deploy
```

发现差异时 `kubectl diff` 会以状态码 1 退出，这表示“存在差异”，不等于命令执行故障。

应用配置会修改集群：

```bash
kubectl apply -k deploy
```

课程项目的正常发布入口是 GitLab CI/CD。手动 `apply` 适合有明确目的的调试或恢复，但下一次 CI 部署仍会按照仓库内容更新资源。修改成功后应把最终配置同步回 Git 仓库。

!!! danger "谨慎删除"

    `kubectl delete` 会立即删除资源。特别是 PVC 或 Secret，删除后可能造成数据丢失或应用无法拉取镜像。执行前必须用 `kubectl get` 确认完整资源类型、名称和命名空间，不要对不明确的标签或通配范围执行批量删除。

## 查看发布状态

Deployment 更新后，可以等待发布完成：

```bash
kubectl rollout status deployment/app-2026-next-hw --timeout=5m
kubectl rollout history deployment/app-2026-next-hw
```

紧急情况下可以回退到上一版 Deployment：

```bash
kubectl rollout undo deployment/app-2026-next-hw
```

回退只改变集群当前状态；如果 Git 仓库仍声明错误镜像，下一次 CI 会再次覆盖它，因此还必须修正并提交部署配置。

## Troubleshooting：排查应用

建议按请求经过的方向逐层检查：

1. **Deployment / StatefulSet**：期望副本数是否已经 Ready。

   ```bash
   kubectl get deployment,statefulset
   kubectl rollout status deployment/<name>
   ```

2. **Pod**：是否处于 `Running`，事件中是否有调度、镜像拉取、探针或 OOM 错误。

   ```bash
   kubectl get pods -o wide
   kubectl describe pod/<pod-name>
   kubectl logs --tail=200 <pod-name>
   kubectl logs --previous <pod-name>
   ```

3. **Service**：selector 是否能选中 Pod，端口名和 `targetPort` 是否正确。

   ```bash
   kubectl describe service/<name>
   kubectl get endpointslice -l kubernetes.io/service-name=<name>
   ```

4. **HTTPRoute**：hostname、backend Service 和端口是否正确，并检查 `Accepted` 与 `ResolvedRefs` 条件。

   ```bash
   kubectl get httproute/<name> -o yaml
   ```

5. **外部请求**：最后再从校园网访问域名。

   ```bash
   curl -i https://<namespace>-<application>.t.secoder.net/
   ```

如果 Pod 正常但 HTTPRoute 报 `ResolvedRefs=False`，通常是 Service 名称或端口引用错误；如果 Route 正常但没有可用后端，继续检查 Service selector、Pod Ready 状态以及应用监听地址。

## 参考资料

- [Introduction to kubectl](https://kubernetes.io/docs/reference/kubectl/introduction/)
- [kubectl Quick Reference](https://kubernetes.io/docs/reference/kubectl/quick-reference/)
- [kubectl Command Reference](https://kubernetes.io/docs/reference/kubectl/generated/)
- [Declarative Management Using Kustomize](https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/)
- [Kubernetes Concepts](https://kubernetes.io/docs/concepts/)
- [SECoder 学生手册](https://man.t.secoder.net/)
