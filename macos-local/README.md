# Local setup: xemu-macos with my own fixes

The branch `willemabc` is a MichaelJSr/xemu-macos release with my own fixes on
top, one commit per fix. Run `git log <release-tag>..willemabc` to list them.
The first fix, "nv2a/vk: show PVIDEO overlay movies on the Vulkan renderer",
makes video-overlay (PVIDEO) movies show on the Vulkan renderer. Without it,
games such as Midtown Madness 3 play their movies as a black screen with
sound. This folder holds the scripts that build, install and start the result
on this Mac.

## What is installed where

| Thing | Location |
|---|---|
| Patched emulator | `/Applications/xemu-macos (patched).app` |
| Unpatched fork, official xemu | `/Applications/xemu-macos.app`, `/Applications/xemu.app` |
| Launchers (start games with these) | `~/Applications/xemu-macos (GameSir).app`, `~/Applications/xemu (GameSir).app` |
| Prelaunch script | `~/Library/Application Support/xemu/xemu-macos-prelaunch.sh` |
| Settings (shared by all xemu apps) | `~/Library/Application Support/xemu/xemu/xemu.toml` |
| Log of the last run | `~/Library/Logs/xemu-macos.log` |

## Controller (GameSir G7 SE via OpenJoystickDriver)

SDL's HIDAPI Xbox One driver doesn't work with the OpenJoystickDriver virtual
pad, so the launchers start xemu with `SDL_JOYSTICK_HIDAPI_XBOX_ONE=0`. The
pad is then read through macOS's controller support. Each launcher also writes
the pad's ID into `port1` in `xemu.toml`. The ID differs per SDL version:

- xemu-macos (SDL 3.4.18): `0500509d5e040000130b00003ba36d04`
- official xemu (SDL 3.4.8): `050018dc5e040000130b0000b87a6d04`

`xemu-macos-prelaunch.sh` also forces the Vulkan renderer. The Vulkan driver
(MoltenVK or KosmicKrisp) is chosen under `[display.vulkan] driver` in
`xemu.toml`. If KosmicKrisp crashes once, xemu-macos writes
`kosmickrisp-strike.txt` next to `xemu.toml` and falls back to MoltenVK.
Delete that file to try KosmicKrisp again.

## Rebuild after changing the code

First time (or after moving the folder), set up the Python tools:

```sh
/usr/bin/python3 -m venv .buildvenv
.buildvenv/bin/pip install pyyaml requests tomli
```

Full build (from the repo root, takes a while):

```sh
export PATH="$PWD/.buildvenv/bin:$PATH"
XEMU_PGO=use ./build.sh -a arm64 > build.log 2>&1
```

Incremental build, then copy the binary into the installed patched app:

```sh
ninja -C build qemu-system-i386 && sh macos-local/repack.sh
```

`repack.sh` needs `dist/xemu.app` from a full build. To install a full build
as the patched app for the first time:

```sh
ditto dist/xemu.app "/Applications/xemu-macos (patched).app"
```

## Recreate the launchers

```sh
osacompile -o ~/Applications/"xemu-macos (GameSir).app" macos-local/launcher-xemu-macos.applescript
osacompile -o ~/Applications/"xemu (GameSir).app" macos-local/launcher-xemu-official.applescript
cp macos-local/xemu-macos-prelaunch.sh ~/Library/Application\ Support/xemu/
```

## Update to a newer xemu-macos release

```sh
git fetch origin --tags
git rebase <new-tag>      # e.g. v0.16.6
```

Then do a full build. Fixes for the same problems may already be in the new
release, so check whether movies show there before rebasing.
