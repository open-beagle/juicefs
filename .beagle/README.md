# juicefs

<https://github.com/juicedata/juicefs>

## 上游同步

```bash
git remote add upstream git@github.com:juicedata/juicefs.git
git fetch upstream
git merge v1.3.1
```

## build

### 本地编译（调试用）

```bash
# 本地编译 linux/amd64（需要安装 go 1.22+）
CGO_ENABLED=1 go build -ldflags="-s -w" -o juicefs .

# 测试命令
./juicefs version
./juicefs format --help
./juicefs mount --help
```

### 流水线编译（多架构）

```bash
# golang build cross (amd64 + arm64)
docker run -it --rm \
  -v $HOME/go/pkg:/go/pkg \
  -v $PWD/:/go/src/github.com/juicedata/juicefs \
  -w /go/src/github.com/juicedata/juicefs \
  -e BUILD_VERSION=v1.3.1-beagle \
  registry.cn-qingdao.aliyuncs.com/wod/golang:1.25-alpine \
  bash .beagle/build.sh

# 构建多架构镜像（需要先执行 build 步骤）
docker build \
  --build-arg BASE=registry.cn-qingdao.aliyuncs.com/wod/alpine:3 \
  --build-arg TARGETARCH=amd64 \
  --build-arg AUTHOR=open-beagle \
  --build-arg VERSION=v1.3.1-beagle \
  --tag registry.cn-qingdao.aliyuncs.com/wod/juicefs:mount-ce-v1.3.1 \
  --file .beagle/dockerfile \
  . && \
docker push registry.cn-qingdao.aliyuncs.com/wod/juicefs:mount-ce-v1.3.1
```
