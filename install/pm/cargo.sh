#!/usr/bin/env bash

# cargo (Rust)
package='cargo'
echo "-- Install $package --"
curl https://sh.rustup.rs -sSf | sh
echo "-- $package version: $($package --version) --"

