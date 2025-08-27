#!/usr/bin/env python3
"""
OIDC Tester App Icon Generator
Creates a professional app icon matching the UI theme
"""

import os
import sys
from pathlib import Path

# Check if Pillow is available, if not, install it
try:
    from PIL import Image, ImageDraw, ImageFont
    import math
except ImportError:
    print("Installing required packages...")
    os.system("pip3 install Pillow")
    from PIL import Image, ImageDraw, ImageFont
    import math

def create_gradient_background(size, start_color, end_color):
    """Create a radial gradient background"""
    image = Image.new('RGBA', (size, size), (255, 255, 255, 0))
    draw = ImageDraw.Draw(image)
    
    # Create radial gradient
    center_x, center_y = size // 2, size // 2
    max_radius = size // 2
    
    for r in range(max_radius, 0, -1):
        # Calculate blend ratio
        ratio = (max_radius - r) / max_radius
        
        # Interpolate colors
        red = int(start_color[0] + (end_color[0] - start_color[0]) * ratio)
        green = int(start_color[1] + (end_color[1] - start_color[1]) * ratio)
        blue = int(start_color[2] + (end_color[2] - start_color[2]) * ratio)
        alpha = int(start_color[3] + (end_color[3] - start_color[3]) * ratio)
        
        color = (red, green, blue, alpha)
        draw.ellipse([center_x - r, center_y - r, center_x + r, center_y + r], fill=color)
    
    return image

def create_shield_shape(size, color):
    """Create a shield/badge shape for security/authentication theme"""
    image = Image.new('RGBA', (size, size), (255, 255, 255, 0))
    draw = ImageDraw.Draw(image)
    
    # Shield dimensions
    shield_width = int(size * 0.6)
    shield_height = int(size * 0.7)
    start_x = (size - shield_width) // 2
    start_y = (size - shield_height) // 2
    
    # Create shield path
    points = []
    
    # Top rounded corners
    top_radius = shield_width // 8
    points.extend([
        (start_x + top_radius, start_y),
        (start_x + shield_width - top_radius, start_y)
    ])
    
    # Right side
    points.extend([
        (start_x + shield_width, start_y + top_radius),
        (start_x + shield_width, start_y + shield_height * 0.7)
    ])
    
    # Bottom point
    points.append((start_x + shield_width // 2, start_y + shield_height))
    
    # Left side
    points.extend([
        (start_x, start_y + shield_height * 0.7),
        (start_x, start_y + top_radius)
    ])
    
    # Create the shield with smooth curves
    # Use ellipse for rounded corners and polygon for main shape
    shield_color = color + (255,) if len(color) == 3 else color
    
    # Draw main shield body
    draw.polygon(points, fill=shield_color)
    
    # Add rounded top corners
    draw.ellipse([start_x - top_radius, start_y - top_radius, 
                  start_x + top_radius, start_y + top_radius], fill=shield_color)
    draw.ellipse([start_x + shield_width - top_radius, start_y - top_radius,
                  start_x + shield_width + top_radius, start_y + top_radius], fill=shield_color)
    
    return image

def create_oidc_symbol(size, color):
    """Create OIDC-themed symbol (key and shield combination)"""
    image = Image.new('RGBA', (size, size), (255, 255, 255, 0))
    draw = ImageDraw.Draw(image)
    
    center_x, center_y = size // 2, size // 2
    
    # Key symbol
    key_color = color + (255,) if len(color) == 3 else color
    
    # Key head (circle)
    key_head_radius = size // 8
    key_head_x = center_x - size // 6
    key_head_y = center_y - size // 12
    draw.ellipse([key_head_x - key_head_radius, key_head_y - key_head_radius,
                  key_head_x + key_head_radius, key_head_y + key_head_radius], 
                 outline=key_color, width=max(2, size // 64))
    
    # Key shaft
    shaft_width = max(2, size // 32)
    shaft_length = size // 4
    draw.rectangle([key_head_x + key_head_radius - shaft_width // 2, 
                   key_head_y - shaft_width // 2,
                   key_head_x + key_head_radius + shaft_length,
                   key_head_y + shaft_width // 2], fill=key_color)
    
    # Key teeth
    tooth_size = size // 16
    for i in range(2):
        tooth_y = key_head_y + shaft_width // 2 + i * tooth_size
        draw.rectangle([key_head_x + key_head_radius + shaft_length - tooth_size,
                       tooth_y,
                       key_head_x + key_head_radius + shaft_length,
                       tooth_y + tooth_size // 2], fill=key_color)
    
    # Shield outline
    shield_size = size // 3
    shield_x = center_x + size // 8
    shield_y = center_y - shield_size // 4
    
    # Simple shield shape
    shield_points = [
        (shield_x, shield_y),
        (shield_x + shield_size, shield_y),
        (shield_x + shield_size, shield_y + shield_size * 0.6),
        (shield_x + shield_size // 2, shield_y + shield_size),
        (shield_x, shield_y + shield_size * 0.6)
    ]
    
    draw.polygon(shield_points, outline=key_color, width=max(2, size // 64))
    
    return image

def create_app_icon(size):
    """Create the complete app icon"""
    # Colors matching the app theme
    bg_start_color = (250, 250, 255, 255)  # Light blue-white
    bg_end_color = (242, 245, 250, 255)    # Subtle blue-gray
    
    # Create base with gradient background
    icon = create_gradient_background(size, bg_start_color, bg_end_color)
    
    # Add subtle border
    draw = ImageDraw.Draw(icon)
    border_color = (200, 210, 230, 100)
    border_width = max(1, size // 128)
    draw.ellipse([border_width, border_width, 
                  size - border_width, size - border_width], 
                 outline=border_color, width=border_width)
    
    # Create main shield element
    shield_color = (70, 130, 230)  # Blue matching app theme
    shield = create_shield_shape(int(size * 0.8), shield_color)
    
    # Composite shield onto background
    shield_offset = (size - shield.size[0]) // 2
    icon.paste(shield, (shield_offset, shield_offset), shield)
    
    # Add OIDC symbol
    symbol_color = (255, 255, 255)  # White for contrast
    symbol = create_oidc_symbol(int(size * 0.6), symbol_color)
    symbol_offset = (size - symbol.size[0]) // 2
    icon.paste(symbol, (symbol_offset, symbol_offset), symbol)
    
    # Add subtle highlight
    highlight = Image.new('RGBA', (size, size), (255, 255, 255, 0))
    highlight_draw = ImageDraw.Draw(highlight)
    highlight_color = (255, 255, 255, 40)
    
    # Top highlight arc
    highlight_draw.arc([size // 8, size // 8, size - size // 8, size - size // 8],
                      start=-45, end=45, fill=highlight_color, width=max(2, size // 32))
    
    icon = Image.alpha_composite(icon, highlight)
    
    return icon

def generate_all_icon_sizes():
    """Generate all required icon sizes for macOS"""
    icon_sizes = {
        # macOS sizes
        'icon_16x16.png': 16,
        'icon_16x16@2x.png': 32,
        'icon_32x32.png': 32,
        'icon_32x32@2x.png': 64,
        'icon_128x128.png': 128,
        'icon_128x128@2x.png': 256,
        'icon_256x256.png': 256,
        'icon_256x256@2x.png': 512,
        'icon_512x512.png': 512,
        'icon_512x512@2x.png': 1024,
        # iOS universal (if needed)
        'icon_1024x1024.png': 1024
    }
    
    # Create icons directory
    assets_dir = Path('OIDC Tester/Assets.xcassets/AppIcon.appiconset')
    assets_dir.mkdir(parents=True, exist_ok=True)
    
    print("Generating app icons...")
    
    for filename, size in icon_sizes.items():
        print(f"Creating {filename} ({size}x{size})")
        icon = create_app_icon(size)
        icon.save(assets_dir / filename, 'PNG', optimize=True)
    
    print(f"✅ Generated {len(icon_sizes)} icon files in {assets_dir}")
    
    # Also create a preview version
    preview_icon = create_app_icon(512)
    preview_icon.save('app_icon_preview.png', 'PNG', optimize=True)
    print("✅ Created app_icon_preview.png for preview")

if __name__ == "__main__":
    try:
        generate_all_icon_sizes()
        print("\n🎉 App icon generation completed successfully!")
        print("The new icons match your app's blue gradient theme with a professional shield and key design.")
    except Exception as e:
        print(f"❌ Error generating icons: {e}")
        sys.exit(1)
