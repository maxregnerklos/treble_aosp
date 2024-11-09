#!/bin/bash

# Utility functions for MaxRegnerGSI

function apply_performance_patches() {
    echo "Applying performance optimizations..."
    
    # CPU optimization
    echo "ro.power_profile.override=true" >> system/build.prop
    echo "ro.sys.fw.bg_apps_limit=60" >> system/build.prop
    
    # Memory management
    echo "ro.sys.fw.use_trim_settings=true" >> system/build.prop
    echo "ro.sys.fw.empty_app_percent=50" >> system/build.prop
}

function apply_battery_patches() {
    echo "Applying battery optimizations..."
    
    # Battery optimizations
    echo "ro.config.hw_power_saving=true" >> system/build.prop
    echo "ro.config.hw_power_saving.enabled=1" >> system/build.prop
}

function check_dependencies() {
    local deps=("git" "repo" "make" "jq" "python3")
    
    for dep in "${deps[@]}"; do
        if ! command -v $dep &> /dev/null; then
            echo "Error: $dep is required but not installed."
            exit 1
        fi
    done
}

function setup_ccache() {
    export USE_CCACHE=1
    export CCACHE_DIR="${HOME}/.ccache"
    ccache -M 50G
}

function cleanup_build() {
    echo "Cleaning up build environment..."
    make clean
    rm -rf out/target/product/*/system.img
} 