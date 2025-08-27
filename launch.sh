#!/bin/bash

# Launch script for OIDC Tester
echo "Building OIDC Tester..."
xcodebuild -project "OIDC Tester.xcodeproj" -scheme "OIDC Tester" build

if [ $? -eq 0 ]; then
    echo "Build successful! Launching app..."
    open "/Users/aaron/Library/Developer/Xcode/DerivedData/OIDC_Tester-axdsjjdyfbsoukbdacqdrxfpqpvk/Build/Products/Debug/OIDC Tester.app"
else
    echo "Build failed!"
    exit 1
fi
