#!/usr/bin/env bash

set -ex

WORKDIR=$(pwd)
git config --global --add safe.directory "$WORKDIR"

export VERSION=${VERSION:-v1.3.1}
export REVISION=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
export REVISIONDATE=$(git log -1 --pretty=format:'%cd' --date short 2>/dev/null || date +%Y-%m-%d)
export PKG=github.com/juicedata/juicefs/pkg/version
export LDFLAGS="-s -w -X ${PKG}.revision=${REVISION} -X ${PKG}.revisionDate=${REVISIONDATE}"

echo "Building JuiceFS ${VERSION}"
echo "Revision: ${REVISION}"
echo "Date: ${REVISIONDATE}"
echo "---"

# Install clang and lld for cross-compilation (native arch)
apk add clang lld

# Build for amd64
echo "Building for linux/amd64..."
export TARGETPLATFORM=linux/amd64
xx-apk add musl-dev gcc
CGO_ENABLED=1 xx-go build -ldflags="${LDFLAGS}" -o juicefs .
mkdir -p "$WORKDIR/_output/linux/amd64/"
mv juicefs "$WORKDIR/_output/linux/amd64/"
xx-verify "$WORKDIR/_output/linux/amd64/juicefs"

echo "✓ amd64 build completed"
file "$WORKDIR/_output/linux/amd64/juicefs"
echo "---"

# Build for arm64
echo "Building for linux/arm64..."
export TARGETPLATFORM=linux/arm64
xx-apk add musl-dev gcc
CGO_ENABLED=1 xx-go build -ldflags="${LDFLAGS}" -o juicefs .
mkdir -p "$WORKDIR/_output/linux/arm64/"
mv juicefs "$WORKDIR/_output/linux/arm64/"
xx-verify "$WORKDIR/_output/linux/arm64/juicefs"

echo "✓ arm64 build completed"
file "$WORKDIR/_output/linux/arm64/juicefs"
echo "---"

echo "All builds completed successfully!"
ls -lh "$WORKDIR/_output/linux/"*/juicefs
