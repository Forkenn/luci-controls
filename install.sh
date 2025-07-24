#!/bin/ash

. /etc/os-release
VERSION_MAJOR=$(echo "$VERSION_ID" | cut -d. -f1)
VERSION_MINOR=$(echo "$VERSION_ID" | cut -d. -f2)

echo "Beginning of the installation."
echo "Checking the system version..."
if [ "$VERSION_MAJOR" -gt 23 ] || { [ "$VERSION_MAJOR" -eq 23 ] && [ "$VERSION_MINOR" -ge 5 ]; }; then
    echo "OpenWrt version is $VERSION_ID. The luci-lua-runtime package is required."
    if ! opkg list-installed | grep -q '^luci-lua-runtime '; then
        echo "Package luci-lua-runtime is NOT installed. Installation aborted."
        exit 1
    fi
    echo "Package luci-lua-runtime is installed. Continuing installation..."
fi

if [ -d "./controller" ]; then
    TARGET_CONTROLLER="/usr/lib/lua/luci/controller"
    echo "Creating folder $TARGET_CONTROLLER if it does not exist..."
    mkdir -p "$TARGET_CONTROLLER"

    echo "Copying controllers..."
    cp -r ./controller/* "$TARGET_CONTROLLER/"
else
    echo "Directory ./controller not found, skip."
fi

if [ -d "./view" ]; then
    TARGET_VIEW="/usr/lib/lua/luci/view"
    echo "Creating folder $TARGET_VIEW if it does not exist..."
    mkdir -p "$TARGET_VIEW"

    echo "Copying view..."
    cp -r ./view/* "$TARGET_VIEW/"
else
    echo "Directory ./view not found, skip."
fi

if [ -d "./config" ]; then
    TARGET_CONFIG="/etc/config"

    echo "Copying config..."
    cp -r ./config/* "$TARGET_CONFIG/"
else
    echo "Directory ./config not found, skip."
fi

echo "Installation complete."