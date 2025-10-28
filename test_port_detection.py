#!/usr/bin/env python3
"""
Quick test script to verify port detection functionality.

Run this to test the port detection before running the full web server.
"""

import sys
from pathlib import Path

# Add project to path
sys.path.insert(0, str(Path(__file__).parent))

from yt_dlp_wizwam.web import is_port_in_use, find_available_port


def test_port_detection():
    """Test port detection functions."""
    print("🔍 Testing Port Detection Functionality\n")
    
    # Test 1: Check if common ports are in use
    test_ports = [8080, 8081, 8082, 42070, 5000, 3000]
    print("1️⃣ Checking common ports:")
    for port in test_ports:
        status = "❌ IN USE" if is_port_in_use(port) else "✅ AVAILABLE"
        print(f"   Port {port}: {status}")
    
    print()
    
    # Test 2: Find available port starting from 8080
    print("2️⃣ Finding available port starting from 8080:")
    available = find_available_port(start_port=8080, max_attempts=20)
    if available:
        print(f"   ✅ Found available port: {available}")
    else:
        print(f"   ❌ No available port found in range 8080-8099")
    
    print()
    
    # Test 3: Find available port starting from 42070 (old Docker port)
    print("3️⃣ Finding available port starting from 42070:")
    available = find_available_port(start_port=42070, max_attempts=10)
    if available:
        print(f"   ✅ Found available port: {available}")
        if available != 42070:
            print(f"   ℹ️  Note: Port 42070 is in use (probably Docker deployment)")
    else:
        print(f"   ❌ No available port found in range 42070-42079")
    
    print()
    
    # Test 4: Test specific port (8080)
    print("4️⃣ Detailed check for port 8080:")
    if is_port_in_use(8080):
        print("   ❌ Port 8080 is IN USE")
        print("   💡 The web server will automatically use an alternative port")
        alternative = find_available_port(start_port=8081, max_attempts=10)
        if alternative:
            print(f"   ✅ Alternative port available: {alternative}")
    else:
        print("   ✅ Port 8080 is AVAILABLE")
        print("   💡 The web server will use this as the default")
    
    print("\n" + "="*60)
    print("✅ Port detection tests complete!")
    print("="*60)
    print("\n💡 Next steps:")
    print("   1. Run: source .venv/bin/activate")
    print("   2. Run: downloader web --open-browser")
    print("   3. The app will automatically select an available port\n")


if __name__ == '__main__':
    try:
        test_port_detection()
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
