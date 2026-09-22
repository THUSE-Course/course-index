# Kubernetes 部署

SECoder 使用 Kubernetes 运行应用。项目将部署配置和源代码一起保存在 Git 仓库中：GitLab CI 使用 BuildKit 构建镜像，将镜像推送到项目的 Container Registry，再使用 Kustomize 和 `kubectl` 更新 Kubernetes 资源。

## 一次部署包含什么

一个可从浏览器访问的 Web 应用通常至少包含以下资源：

|资源|作用|
|-|-|
|Deployment / StatefulSet|声明要运行的容器、镜像、环境变量、端口和资源限制|
|Pod|Kubernetes 根据工作负载声明创建的容器实例|
|Service|为一组 Pod 提供稳定的集群内访问地址|
|HTTPRoute|把 `*.t.secoder.net` 的外部请求转发到 Service|
|Secret|保存 Registry 凭据等敏感配置|
|ConfigMap|保存非敏感配置|
|PersistentVolumeClaim|为需要持久化的数据申请存储|

一般不直接创建或修改 Pod，而是修改 Deployment 或 StatefulSet，让 Kubernetes 维护所需的 Pod。

## 部署目录

推荐把资源文件集中在仓库的 `deploy/` 目录：

```text
deploy/
├── deployment.yaml
├── service.yaml
├── httproute.yaml
└── kustomization.yaml
```

### Deployment

下面的示例部署一个监听 80 端口的前端应用。请统一替换资源名、镜像占位值和标签。

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-2026-next-hw
  labels:
    app.kubernetes.io/name: app-2026-next-hw
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: app-2026-next-hw
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app.kubernetes.io/name: app-2026-next-hw
    spec:
      imagePullSecrets:
        - name: gitlab-registry-2026-next-hw
      containers:
        - name: next
          image: registry.example.invalid/2026-next-hw:latest
          env:
            - name: HOSTNAME
              value: 0.0.0.0
            - name: PORT
              value: "80"
          ports:
            - name: http
              containerPort: 80
          readinessProbe:
            httpGet:
              path: /
              port: http
            initialDelaySeconds: 10
            periodSeconds: 10
          resources:
            requests:
              cpu: 32m
              memory: 256Mi
            limits:
              cpu: 125m
              memory: 1Gi
```

`selector.matchLabels`、Pod 标签和 Service selector 必须完全一致。应用也必须监听 `0.0.0.0`，不能只监听 `127.0.0.1`。

### Service

Service 将请求转发到带有相同标签的 Pod：

```yaml
apiVersion: v1
kind: Service
metadata:
  name: app-2026-next-hw
spec:
  selector:
    app.kubernetes.io/name: app-2026-next-hw
  ports:
    - name: http
      port: 80
      targetPort: http
```

同一命名空间中的其他应用可以通过 `http://app-2026-next-hw` 访问这个 Service。

### HTTPRoute

HTTPRoute 为 Service 分配外部域名：

```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: route-2026-next-hw
spec:
  parentRefs:
    - group: gateway.networking.k8s.io
      kind: Gateway
      name: traefik-gateway
      namespace: infra
  hostnames:
    - u-2026000000-2026-next-hw.t.secoder.net
  rules:
    - backendRefs:
        - name: app-2026-next-hw
          port: 80
          kind: Service
      matches:
        - path:
            type: PathPrefix
            value: /
```

学生应用的 hostname 必须以自己的命名空间开头。例如命名空间是 `u-2026000000`，域名可以是 `u-2026000000-2026-next-hw.t.secoder.net`。

### Kustomization

`kustomization.yaml` 是整套资源的入口：

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
  - service.yaml
  - httproute.yaml
```

提交前可以在本地预览最终配置，这条命令不会修改集群：

```bash
kubectl kustomize deploy
```

更多可复用资源和补丁示例见
[secoder-tmpl](https://github.com/THUSE-Course/secoder-tmpl)。

## CI/CD 凭据

在 GitLab 项目的 **Settings → CI/CD → Variables** 中配置：

|变量|值|保护方式|
|-|-|-|
|`TOKEN`|SECoder 个人资料页面中的 Kubernetes API 令牌|Masked|
|`NAMESPACE`|个人命名空间，例如 `u-2026000000`|普通变量|
|`GITLAB_REGISTRY_USER`|创建 Registry Token 的 GitLab 用户名|普通变量|
|`GITLAB_PAT`|具有 `read_registry` 权限的长期有效 Token|Masked|

`CI_REGISTRY`、`CI_REGISTRY_IMAGE`、`CI_REGISTRY_USER`、`CI_REGISTRY_PASSWORD` 和 `CI_COMMIT_SHA` 由 GitLab 自动提供，用于在当前 CI 作业中构建并推送镜像。

## GitLab CI/CD

以下配置包含镜像构建和部署两个阶段。为避免 Runner 获取外部模板失败，请把模板直接放进项目的 `.gitlab-ci.yml`，不要使用远程 `include:`。

```yaml
stages:
  - build
  - deploy

.buildkit:
  image:
    name: moby/buildkit:rootless
    entrypoint: [""]
  variables:
    BUILDKITD_CONFIG: /tmp/buildkitd.toml
    BUILDKITD_FLAGS: --oci-worker-no-process-sandbox --config /tmp/buildkitd.toml
    BUILDKIT_CACHE_REF: $CI_REGISTRY_IMAGE:buildcache
  before_script:
    - mkdir -p ~/.docker
    - echo "{\"auths\":{\"$CI_REGISTRY\":{\"username\":\"$CI_REGISTRY_USER\",\"password\":\"$CI_REGISTRY_PASSWORD\"}}}" > ~/.docker/config.json
    - |
      cat > "$BUILDKITD_CONFIG" <<'EOF'
      [registry."docker.io"]
        insecure = true
      EOF
  script:
    - |
      buildctl-daemonless.sh build \
        --frontend dockerfile.v0 \
        --local context=. \
        --local dockerfile=. \
        --import-cache type=registry,ref="${BUILDKIT_CACHE_REF}" \
        --export-cache type=registry,ref="${BUILDKIT_CACHE_REF}",mode=max \
        --output type=image,name="${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHA}",push=true

.kustomize:
  image:
    name: alpine/k8s:1.35.1
    entrypoint: [""]
  variables:
    KUSTOMIZE_PATH: deploy
  script:
    - |
      set -eu
      : "${TOKEN:?TOKEN is required}"
      : "${NAMESPACE:?NAMESPACE is required}"
      export KUBECTL_APPLYSET=true
      kubectl --token="${TOKEN}" -n "${NAMESPACE}" \
        apply -k "${KUSTOMIZE_PATH}" \
        --applyset="gitops-ci-${CI_PROJECT_PATH_SLUG}" \
        --prune

build-image:
  extends: .buildkit
  stage: build
  rules:
    - if: '$CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH'

deploy:
  extends: .kustomize
  stage: deploy
  needs:
    - build-image
  before_script:
    - |
      set -eu
      : "${GITLAB_REGISTRY_USER:?GITLAB_REGISTRY_USER is required}"
      : "${GITLAB_PAT:?GITLAB_PAT is required}"
      kubectl --token="${TOKEN}" -n "${NAMESPACE}" \
        create secret docker-registry gitlab-registry-2026-next-hw \
        --docker-server="${CI_REGISTRY}" \
        --docker-username="${GITLAB_REGISTRY_USER}" \
        --docker-password="${GITLAB_PAT}" \
        --dry-run=client -o yaml | \
        kubectl --token="${TOKEN}" -n "${NAMESPACE}" apply -f -
    - sed -i "s|registry.example.invalid/2026-next-hw:latest|${CI_REGISTRY_IMAGE}:${CI_COMMIT_SHA}|" deploy/deployment.yaml
  rules:
    - if: '$CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH'
```

后端项目使用同一结构，只需替换资源名、容器启动配置、健康检查和对外域名。

!!! warning "ApplySet 会清理资源"

    `--prune` 会删除同一 ApplySet 上一次部署过、但本次 Kustomize 输出中已经不存在的资源。不要让两个项目使用相同的 ApplySet 名称，也不要用一个项目管理另一个项目的资源。

    `kubectl apply` 不是事务操作。如果某个资源校验失败，排在它前面的资源可能已经更新。应先检查流水线日志和命名空间中的实际资源，再修正配置并重新运行流水线。

## 验证部署

流水线成功后，依次验证工作负载、Service 和 HTTPRoute：

```bash
kubectl get deployment,pod,service,httproute
kubectl rollout status deployment/app-2026-next-hw
kubectl get httproute route-2026-next-hw -o yaml
curl -I https://u-2026000000-2026-next-hw.t.secoder.net
```

若部署失败，按 [kubectl 使用指南](kubectl.md#troubleshooting)检查事件、容器日志、Service selector 和 HTTPRoute 状态。
