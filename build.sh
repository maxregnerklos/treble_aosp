#!/bin/bash

# Enhanced MaxRegnerGSI Build Script
VERSION="15.0.0"
BUILD_DATE=$(date +%Y%m%d)
GSI_VARIANT="MaxRegnerGSI"

# Configuration
export ALLOW_MISSING_DEPENDENCIES=true
export BUILD_TYPE="release"
export TARGET_ARCH="arm64"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# New feature: Multi-variant support
VARIANTS=("vanilla" "gapps" "microg")

function setup_environment() {
    echo -e "${GREEN}Setting up build environment...${NC}"
    source build/envsetup.sh
    lunch aosp_arm64-userdebug
}

function build_gsi() {
    local variant=$1
    echo -e "${YELLOW}Building ${GSI_VARIANT} ${variant} variant...${NC}"
    
    # New feature: Enhanced build options
    make systemimage \
        -j$(nproc --all) \
        TARGET_ARCH=$TARGET_ARCH \
        BOARD_SYSTEMIMAGE_PARTITION_SIZE=4294967296 \
        BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE=ext4 \
        TARGET_USES_TREBLE=true
        
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Build successful!${NC}"
        sign_gsi "${variant}"
    else
        echo -e "${RED}Build failed!${NC}"
        exit 1
    fi
}

# Main execution
setup_environment

for variant in "${VARIANTS[@]}"; do
    build_gsi $variant
done
