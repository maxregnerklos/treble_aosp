#!/bin/bash

<<<<<<< HEAD
echo
echo "--------------------------------------"
echo "          AOSP 15.0 Buildbot          "
echo "                  by                  "
echo "                ponces                "
echo "--------------------------------------"
echo

set -e

BL=$PWD/treble_aosp
BD=$HOME/builds
BV=$1

initRepos() {
    echo "--> Initializing workspace"
    repo init -u https://android.googlesource.com/platform/manifest -b android-15.0.0_r5 --git-lfs
    echo

    echo "--> Preparing local manifest"
    mkdir -p .repo/local_manifests
    cp $BL/build/default.xml .repo/local_manifests/default.xml
    cp $BL/build/remove.xml .repo/local_manifests/remove.xml
    echo
}

syncRepos() {
    echo "--> Syncing repos"
    repo sync -c --force-sync --no-clone-bundle --no-tags -j$(nproc --all) || repo sync -c --force-sync --no-clone-bundle --no-tags -j$(nproc --all)
    echo
}

applyPatches() {
    echo "--> Applying TrebleDroid patches"
    bash $BL/patch.sh $BL trebledroid
    echo

    echo "--> Applying personal patches"
    bash $BL/patch.sh $BL personal
    echo

    echo "--> Generating makefiles"
    cd device/phh/treble
    cp $BL/build/aosp.mk .
    bash generate.sh aosp
    cd ../../..
    echo
}

setupEnv() {
    echo "--> Setting up build environment"
    source build/envsetup.sh &>/dev/null
    mkdir -p $BD
    echo
}

buildTrebleApp() {
    echo "--> Building treble_app"
    cd treble_app
    bash build.sh release
    cp TrebleApp.apk ../vendor/hardware_overlay/TrebleApp/app.apk
    cd ..
    echo
}

buildVariant() {
    echo "--> Building $1"
    lunch "$1"-ap3a-userdebug
    make -j$(nproc --all) installclean
    make -j$(nproc --all) systemimage
    make -j$(nproc --all) target-files-package otatools
    bash $BL/sign.sh "vendor/ponces-priv/keys" $OUT/signed-target_files.zip
    unzip -jo $OUT/signed-target_files.zip IMAGES/system.img -d $OUT
    mv $OUT/system.img $BD/system-"$1".img
    echo
}

buildVndkliteVariant() {
    echo "--> Building $1-vndklite"
    cd treble_adapter
    sudo bash lite-adapter.sh "64" $BD/system-"$1".img
    mv s.img $BD/system-"$1"-vndklite.img
    sudo rm -rf d tmp
    cd ..
    echo
}

buildVariants() {
    buildVariant treble_arm64_bvN
    buildVariant treble_arm64_bgN
    buildVndkliteVariant treble_arm64_bvN
    buildVndkliteVariant treble_arm64_bgN
}

generatePackages() {
    echo "--> Generating packages"
    buildDate="$(date +%Y%m%d)"
    find $BD/ -name "system-treble_*.img" | while read file; do
        filename="$(basename $file)"
        [[ "$filename" == *"_bvN"* ]] && variant="vanilla" || variant="gapps"
        [[ "$filename" == *"-vndklite"* ]] && vndk="-vndklite" || vndk=""
        name="aosp-arm64-ab-${variant}${vndk}-15.0-$buildDate"
        xz -cv "$file" -T0 > $BD/"$name".img.xz
    done
    rm -rf $BD/system-*.img
    echo
}

generateOta() {
    echo "--> Generating OTA file"
    version="$(date +v%Y.%m.%d)"
    buildDate="$(date +%Y%m%d)"
    timestamp="$START"
    json="{\"version\": \"$version\",\"date\": \"$timestamp\",\"variants\": ["
    find $BD/ -name "aosp-*-15.0-$buildDate.img.xz" | sort | {
        while read file; do
            filename="$(basename $file)"
            [[ "$filename" == *"-vanilla"* ]] && variant="v" || variant="g"
            [[ "$filename" == *"-vndklite"* ]] && vndk="-vndklite" || vndk=""
            name="treble_arm64_b${variant}N${vndk}"
            size=$(wc -c $file | awk '{print $1}')
            url="https://github.com/ponces/treble_aosp/releases/download/$version/$filename"
            json="${json} {\"name\": \"$name\",\"size\": \"$size\",\"url\": \"$url\"},"
        done
        json="${json%?}]}"
        echo "$json" | jq . > $BL/config/ota.json
    }
    echo
}

START=$(date +%s)

initRepos
syncRepos
applyPatches
setupEnv
buildTrebleApp
[ ! -z "$BV" ] && buildVariant "$BV" || buildVariants
generatePackages
generateOta

END=$(date +%s)
ELAPSEDM=$(($(($END-$START))/60))
ELAPSEDS=$(($(($END-$START))-$ELAPSEDM*60))

echo "--> Buildbot completed in $ELAPSEDM minutes and $ELAPSEDS seconds"
echo
=======
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
>>>>>>> origin/main
