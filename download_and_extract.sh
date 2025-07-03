#!/usr/bin/env bash

set -e

# 检测架构（优先使用 dpkg-architecture，否则 fallback 到 uname）
ARCH=$1

# 下载缓存目录
DOWNLOAD_DIR=".download_cache"

# GitHub API 获取最新 release 的 URL
GITHUB_API_URL="https://api.github.com/repos/VSCodium/vscodium/releases/latest"

# 获取 JSON 数据
RELEASE_JSON=$(curl -s -H "Accept: application/vnd.github.v3+json" "$GITHUB_API_URL")

# 提取所有 asset 的 download URL
ASSET_URLS=$(echo "$RELEASE_JSON" | jq -r '.assets[].browser_download_url')

# 筛选出包含当前架构且以 .tar.gz 结尾的下载链接
TARBALL_URL=$(echo "$ASSET_URLS" | grep "VSCodium-linux-$ARCH" | grep "\.tar\.gz$")

# 检查是否找到匹配的 tarball
if [ -z "$TARBALL_URL" ]; then
  echo "Error: No matching tar.gz file found for architecture '$ARCH'." >&2
  exit 1
fi

TARBALL=$(basename "$TARBALL_URL")
EXTRACTED_DIR="${TARBALL%.tar.gz}"

# 创建下载缓存目录
mkdir -p "$DOWNLOAD_DIR"
mkdir -p "$DOWNLOAD_DIR/$EXTRACTED_DIR"

# 下载并解压
echo "Downloading VSCodium for $ARCH: $TARBALL_URL"
wget "$TARBALL_URL" -O "$DOWNLOAD_DIR/$TARBALL"

echo "Extracting to $DOWNLOAD_DIR/$EXTRACTED_DIR"
tar -xzvf $DOWNLOAD_DIR/$TARBALL -C "$DOWNLOAD_DIR/$EXTRACTED_DIR"

# Create Temp Install Dir
INSTALL_DIR=".install_dir"
# 创建文件结构
cp -rv official "$INSTALL_DIR"

mv "$INSTALL_DIR/DEBIAN/control.in" "$INSTALL_DIR/DEBIAN/control"
# 获取版本号
version=$(echo "$TARBALL" | sed -E 's/.*-([0-9]+\.[0-9]+\.[0-9]+)\.tar\.gz/\1/')

# 替换版本号
sed -i "s/%TBD_PACKAGE_VERSION%/$version/g" "$INSTALL_DIR/DEBIAN/control"

# 替换架构
sed -i "s/%TBD_PACKAGE_ARCH%/$ARCH/g" "$INSTALL_DIR/DEBIAN/control"

# 替换软件包大小
app_size=$(du -sh --block-size=1k "$DOWNLOAD_DIR/$EXTRACTED_DIR" | awk '{print $1}')
sed -i "s/%TBD_PACKAGE_SIZE%/$app_size/g" "$INSTALL_DIR/DEBIAN/control"

# 复制内容
mv "$DOWNLOAD_DIR/$EXTRACTED_DIR" "$INSTALL_DIR/usr/share/codium"

# 打包
fakeroot dpkg -b "$INSTALL_DIR" "codium_$(echo $version)_$(echo $ARCH).deb"

echo "version=${version}" >> "$GITHUB_OUTPUT"


