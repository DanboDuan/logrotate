#!/bin/bash

set -eux
set -o pipefail
version="1.0.0"
swift build -c release -Xcc -DTOOL_VERSION=\"${version}\" --disable-sandbox --triple arm64-apple-macosx
swift build -c release -Xcc -DTOOL_VERSION=\"${version}\" --disable-sandbox --triple x86_64-apple-macosx
rm -fr .build/apple/Products/Release
mkdir -p .build/apple/Products/Release
lipo -create -output .build/apple/Products/Release/logrotate .build/arm64-apple-macosx/release/logrotate .build/x86_64-apple-macosx/release/logrotate

file=".build/apple/Products/Release/logrotate"
# ls -alh $file
mkdir -p ~/bin && cp $file ~/bin
