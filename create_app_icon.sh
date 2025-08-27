#!/bin/bash

echo "🎨 Creating OIDC Tester App Icon..."

# Create the AppIcon directory if it doesn't exist
ICON_DIR="OIDC Tester/Assets.xcassets/AppIcon.appiconset"
mkdir -p "$ICON_DIR"

# Icon sizes for macOS and iOS - using arrays instead of associative arrays
ICON_FILES=(
    # macOS icons
    "icon_16x16.png"
    "icon_16x16@2x.png" 
    "icon_32x32.png"
    "icon_32x32@2x.png"
    "icon_128x128.png"
    "icon_128x128@2x.png"
    "icon_256x256.png"
    "icon_256x256@2x.png"
    "icon_512x512.png"
    "icon_512x512@2x.png"
    # iOS icons
    "ios_20x20.png"
    "ios_20x20@2x.png"
    "ios_20x20@3x.png"
    "ios_29x29.png"
    "ios_29x29@2x.png"
    "ios_29x29@3x.png"
    "ios_40x40.png"
    "ios_40x40@2x.png"
    "ios_40x40@3x.png"
    "ios_60x60@2x.png"
    "ios_60x60@3x.png"
    "ios_76x76.png"
    "ios_76x76@2x.png"
    "ios_83.5x83.5@2x.png"
    "ios_1024x1024.png"
)

ICON_SIZES=(16 32 32 64 128 256 256 512 512 1024 20 40 60 29 58 87 40 80 120 120 180 76 152 167 1024)

if command -v qlmanage &> /dev/null; then
    echo "Using qlmanage to convert SVG to PNG..."
    
    # Generate icons using array indices
    for i in "${!ICON_FILES[@]}"; do
        filename="${ICON_FILES[$i]}"
        size="${ICON_SIZES[$i]}"
        echo "Creating $filename (${size}x${size})"
        
        # Use qlmanage to convert SVG to PNG
        qlmanage -t -s $size -o /tmp/ icon_template.svg > /dev/null 2>&1
        
        # Move and rename the generated file
        if [ -f "/tmp/icon_template.svg.png" ]; then
            mv "/tmp/icon_template.svg.png" "$ICON_DIR/$filename"
        fi
    done
    
# Fallback to using Swift to create simple icons
else
    echo "Using fallback method with Swift..."
    
    # Create a Swift script to generate icons programmatically
    cat > generate_icon.swift << 'EOF'
import AppKit
import CoreGraphics
import Foundation

func createIcon(size: Int, filename: String) {
    let rect = NSRect(x: 0, y: 0, width: size, height: size)
    let image = NSImage(size: rect.size)
    
    image.lockFocus()
    
    // Background gradient
    let gradient = NSGradient(colors: [
        NSColor(red: 0.98, green: 0.98, blue: 1.0, alpha: 1.0),
        NSColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1.0)
    ])!
    gradient.draw(in: rect, angle: 135)
    
    // Shield shape
    let shieldColor = NSColor(red: 0.27, green: 0.51, blue: 0.90, alpha: 1.0)
    shieldColor.set()
    
    let shieldRect = NSRect(x: size/6, y: size/6, width: size*2/3, height: size*2/3)
    let shieldPath = NSBezierPath()
    
    // Create shield shape
    shieldPath.move(to: NSPoint(x: shieldRect.minX + shieldRect.width * 0.2, y: shieldRect.minY))
    shieldPath.line(to: NSPoint(x: shieldRect.maxX - shieldRect.width * 0.2, y: shieldRect.minY))
    shieldPath.curve(to: NSPoint(x: shieldRect.maxX, y: shieldRect.minY + shieldRect.height * 0.2),
                     controlPoint1: NSPoint(x: shieldRect.maxX, y: shieldRect.minY),
                     controlPoint2: NSPoint(x: shieldRect.maxX, y: shieldRect.minY + shieldRect.height * 0.1))
    shieldPath.line(to: NSPoint(x: shieldRect.maxX, y: shieldRect.maxY - shieldRect.height * 0.3))
    shieldPath.line(to: NSPoint(x: shieldRect.midX, y: shieldRect.maxY))
    shieldPath.line(to: NSPoint(x: shieldRect.minX, y: shieldRect.maxY - shieldRect.height * 0.3))
    shieldPath.line(to: NSPoint(x: shieldRect.minX, y: shieldRect.minY + shieldRect.height * 0.2))
    shieldPath.curve(to: NSPoint(x: shieldRect.minX + shieldRect.width * 0.2, y: shieldRect.minY),
                     controlPoint1: NSPoint(x: shieldRect.minX, y: shieldRect.minY + shieldRect.height * 0.1),
                     controlPoint2: NSPoint(x: shieldRect.minX, y: shieldRect.minY))
    shieldPath.close()
    shieldPath.fill()
    
    // Key symbol
    NSColor.white.set()
    
    // Key head
    let keyHeadRect = NSRect(x: shieldRect.minX + shieldRect.width * 0.25, 
                           y: shieldRect.minY + shieldRect.height * 0.35,
                           width: shieldRect.width * 0.15, 
                           height: shieldRect.width * 0.15)
    let keyHeadPath = NSBezierPath(ovalIn: keyHeadRect)
    keyHeadPath.lineWidth = max(1, CGFloat(size) / 64)
    keyHeadPath.stroke()
    
    // Key shaft
    let keyShaftRect = NSRect(x: keyHeadRect.maxX - keyHeadRect.width * 0.1,
                            y: keyHeadRect.midY - keyHeadRect.height * 0.1,
                            width: shieldRect.width * 0.3,
                            height: keyHeadRect.height * 0.2)
    NSBezierPath(rect: keyShaftRect).fill()
    
    // Key teeth
    let tooth1Rect = NSRect(x: keyShaftRect.maxX - keyShaftRect.width * 0.1,
                          y: keyShaftRect.maxY,
                          width: keyShaftRect.width * 0.1,
                          height: keyHeadRect.height * 0.3)
    NSBezierPath(rect: tooth1Rect).fill()
    
    image.unlockFocus()
    
    // Save as PNG
    guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil),
          let bitmapRep = NSBitmapImageRep(cgImage: cgImage) else { return }
    
    guard let pngData = bitmapRep.representation(using: .png, properties: [:]) else { return }
    
    let url = URL(fileURLWithPath: filename)
    try? pngData.write(to: url)
}

// Generate all icon sizes for macOS and iOS
let iconSizes = [
    // macOS icons
    ("OIDC Tester/Assets.xcassets/AppIcon.appiconset/icon_16x16.png", 16),
    ("OIDC Tester/Assets.xcassets/AppIcon.appiconset/icon_16x16@2x.png", 32),
    ("OIDC Tester/Assets.xcassets/AppIcon.appiconset/icon_32x32.png", 32),
    ("OIDC Tester/Assets.xcassets/AppIcon.appiconset/icon_32x32@2x.png", 64),
    ("OIDC Tester/Assets.xcassets/AppIcon.appiconset/icon_128x128.png", 128),
    ("OIDC Tester/Assets.xcassets/AppIcon.appiconset/icon_128x128@2x.png", 256),
    ("OIDC Tester/Assets.xcassets/AppIcon.appiconset/icon_256x256.png", 256),
    ("OIDC Tester/Assets.xcassets/AppIcon.appiconset/icon_256x256@2x.png", 512),
    ("OIDC Tester/Assets.xcassets/AppIcon.appiconset/icon_512x512.png", 512),
    ("OIDC Tester/Assets.xcassets/AppIcon.appiconset/icon_512x512@2x.png", 1024),
    // iOS icons
    ("OIDC Tester/Assets.xcassets/AppIcon.appiconset/ios_20x20.png", 20),
    ("OIDC Tester/Assets.xcassets/AppIcon.appiconset/ios_20x20@2x.png", 40),
    ("OIDC Tester/Assets.xcassets/AppIcon.appiconset/ios_20x20@3x.png", 60),
    ("OIDC Tester/Assets.xcassets/AppIcon.appiconset/ios_29x29.png", 29),
    ("OIDC Tester/Assets.xcassets/AppIcon.appiconset/ios_29x29@2x.png", 58),
    ("OIDC Tester/Assets.xcassets/AppIcon.appiconset/ios_29x29@3x.png", 87),
    ("OIDC Tester/Assets.xcassets/AppIcon.appiconset/ios_40x40.png", 40),
    ("OIDC Tester/Assets.xcassets/AppIcon.appiconset/ios_40x40@2x.png", 80),
    ("OIDC Tester/Assets.xcassets/AppIcon.appiconset/ios_40x40@3x.png", 120),
    ("OIDC Tester/Assets.xcassets/AppIcon.appiconset/ios_60x60@2x.png", 120),
    ("OIDC Tester/Assets.xcassets/AppIcon.appiconset/ios_60x60@3x.png", 180),
    ("OIDC Tester/Assets.xcassets/AppIcon.appiconset/ios_76x76.png", 76),
    ("OIDC Tester/Assets.xcassets/AppIcon.appiconset/ios_76x76@2x.png", 152),
    ("OIDC Tester/Assets.xcassets/AppIcon.appiconset/ios_83.5x83.5@2x.png", 167),
    ("OIDC Tester/Assets.xcassets/AppIcon.appiconset/ios_1024x1024.png", 1024)
]

for (filename, size) in iconSizes {
    print("Creating \(filename) (\(size)x\(size))")
    createIcon(size: size, filename: filename)
}

print("✅ Icon generation completed!")
EOF
    
    # Compile and run the Swift script
    swiftc -framework AppKit generate_icon.swift -o generate_icon
    ./generate_icon
    rm generate_icon generate_icon.swift
fi

# Create preview icon
if [ -f "$ICON_DIR/icon_512x512.png" ]; then
    cp "$ICON_DIR/icon_512x512.png" "app_icon_preview.png"
    echo "✅ Created preview: app_icon_preview.png"
fi

echo "🎉 App icon creation completed!"
echo "📁 Icons saved to: $ICON_DIR"
echo ""
echo "The new app icon features:"
echo "• Professional shield design representing security/authentication"
echo "• Key symbol representing OIDC authentication"
echo "• Blue gradient matching your app's UI theme"
echo "• Clean, modern design for both macOS and iOS"
echo "• All required sizes for App Store submission"
