#!/bin/sh
# Run by "xemu-macos (GameSir).app" before starting xemu-macos.
# 1. Port 1 -> the GameSir pad's ID as xemu-macos's SDL 3.4.18 sees it
#    (with SDL_JOYSTICK_HIDAPI_XBOX_ONE=0).
# 2. Start on the Vulkan renderer with the default (Metal) presentation, so the
#    driver chosen under [display.vulkan] (e.g. KosmicKrisp) can load.
C="$HOME/Library/Application Support/xemu/xemu/xemu.toml"
[ -f "$C" ] || exit 0
/usr/bin/sed -i '' "s/^port1 = .*/port1 = '0500509d5e040000130b00003ba36d04'/" "$C"
/usr/bin/sed -i '' "/^presentation_backend = /d" "$C"
if /usr/bin/grep -q "^renderer = " "$C"; then
  /usr/bin/sed -i '' "s/^renderer = .*/renderer = 'VULKAN'/" "$C"
elif /usr/bin/grep -q '^\[display\]$' "$C"; then
  /usr/bin/sed -i '' "/^\[display\]\$/a\\
renderer = 'VULKAN'
" "$C"
else
  printf "\n[display]\nrenderer = 'VULKAN'\n" >> "$C"
fi
