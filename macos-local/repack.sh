#!/bin/sh
# Copy build/qemu-system-i386 into dist/xemu.app and the installed patched app,
# pointing its libraries at the bundle (as build.sh's package_macos does).
set -e
cd "$(dirname "$0")/.."
E=dist/xemu.app/Contents/MacOS/xemu
cp build/qemu-system-i386 "$E"
for dep in $(otool -L "$E" | awk 'NR>1{print $1}' | grep '^/opt/local/lib/'); do
  install_name_tool -change "$dep" "@executable_path/../Libraries/arm64/$(basename "$dep")" "$E" 2>/dev/null
done
otool -l "$E" | awk '/LC_RPATH/{f=1} f&&/ path /{print $2; f=0}' | while read -r p; do
  install_name_tool -delete_rpath "$p" "$E" 2>/dev/null
done
install_name_tool -add_rpath "@executable_path/../Libraries/arm64/" "$E" 2>/dev/null
codesign --force --deep --preserve-metadata=entitlements,requirements,flags,runtime --sign - "$E" 2>/dev/null
codesign --verify --deep dist/xemu.app
ditto "$E" "/Applications/xemu-macos (patched).app/Contents/MacOS/xemu"
codesign --verify --deep "/Applications/xemu-macos (patched).app"
otool -l "/Applications/xemu-macos (patched).app/Contents/MacOS/xemu" | awk '/LC_RPATH/{f=1} f&&/ path /{print "rpath:", $2; f=0}'
otool -L "/Applications/xemu-macos (patched).app/Contents/MacOS/xemu" | awk 'NR>1{print $1}' | grep -c '^/opt/local' || true
echo repacked
