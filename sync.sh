#!/bin/bash

# Enhanced sync script for MaxRegnerGSI
source scripts/utils.sh

MANIFEST_URL="https://android.googlesource.com/platform/manifest"
BRANCH="android-15.0.0_r5"

function sync_source() {
    echo "Syncing Android source code..."
    repo init -u $MANIFEST_URL -b $BRANCH
    repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
}

function sync_vendor_patches() {
    echo "Syncing vendor patches..."
    git clone https://github.com/your-username/maxregner-patches.git patches
}

# Main execution
check_dependencies
setup_ccache
sync_source
sync_vendor_patches
