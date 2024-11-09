#!/bin/bash

<<<<<<< HEAD
set -e

patches="$(readlink -f -- $1)"
tree="$2"

for project in $(cd $patches/patches/$tree; echo *); do
    p="$(tr _ / <<<$project |sed -e 's;platform/;;g')"
    [ "$p" == build ] && p=build/make
    [ "$p" == treble/app ] && p=treble_app
    [ "$p" == vendor/hardware/overlay ] && p=vendor/hardware_overlay
    pushd $p &>/dev/null
    for patch in $patches/patches/$tree/$project/*.patch; do
        git am $patch || exit
    done
    popd &>/dev/null
done
=======
# Enhanced patch system for MaxRegnerGSI
source scripts/utils.sh

PATCH_DIR="patches"
CONFIG_FILE="config/gsi_config.json"

function apply_patches() {
    local variant=$1
    echo "Applying patches for ${variant} variant..."
    
    # Read patches from config
    local patches=$(jq -r ".variants.${variant}.patches[]" $CONFIG_FILE)
    
    for patch in $patches; do
        echo "Applying ${patch} patches..."
        if [ -d "${PATCH_DIR}/${patch}" ]; then
            for p in "${PATCH_DIR}/${patch}"/*.patch; do
                git apply --check "$p"
                if [ $? -eq 0 ]; then
                    git apply "$p"
                    echo "Applied patch: $(basename $p)"
                else
                    echo "Failed to apply patch: $(basename $p)"
                    exit 1
                fi
            done
        fi
    done
}

function apply_features() {
    echo "Applying additional features..."
    
    # Apply performance optimizations
    if [ "$(jq -r '.features.performance' $CONFIG_FILE)" == "true" ]; then
        apply_performance_patches
    fi
    
    # Apply battery optimizations
    if [ "$(jq -r '.features.battery_optimization' $CONFIG_FILE)" == "true" ]; then
        apply_battery_patches
    fi
}

# Main execution
if [ -z "$1" ]; then
    echo "Please specify a variant: vanilla, gapps, or microg"
    exit 1
fi

apply_patches "$1"
apply_features
>>>>>>> origin/main
