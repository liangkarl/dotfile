#!/bin/bash

PATH=$PATH:$HOME/bin

pushd $HOME/Projects/ref
echo "Start Sync"
repo sync -dqf
echo "Sync End"
popd
