#/bin/bash
set -e
# set -x

echo "We now use GitHub Webhook to deploy to lab.cs., this script is deprecated."

exit 1

### A reminder of how to deploy the course index to the remote `gitlab` repository
# https://lab.cs.tsinghua.edu.cn/software-engineering/

# if remote `gitlab` does not exist, create it and point to git@git.tsinghua.edu.cn:thuse-course/course-index.git
if ! git remote | grep -q gitlab; then
  git remote add gitlab git@git.tsinghua.edu.cn:thuse-course/course-index.git
fi

# push to remote `gitlab`
git checkout gh-pages
git pull origin gh-pages
git push gitlab gh-pages
git checkout master
