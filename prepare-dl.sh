#!/bin/bash

set -ex

VER=0.6.3
PWD=`pwd`
rm -rf dest.tar.gz dest
mkdir -p dest

wget -O dest.tar.gz https://fw0.koolcenter.com/binary/kspeeder/iStoreEnhance-binary-${VER}.tar.gz
tar --strip-components=1 -zxf ./dest.tar.gz -C ./dest/
cp ./kspeeder-install.sh ./dest/
rm -f ./dest.tar.gz

