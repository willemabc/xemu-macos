-- Starts xemu with SDL's Xbox HIDAPI driver disabled, so the OpenJoystickDriver
-- virtual pad (GameSir G7 SE) is read through macOS's controller support instead.
set cfg to (POSIX path of (path to application support folder from user domain)) & "xemu/xemu/xemu.toml"
do shell script "/usr/bin/sed -i '' \"s/^port1 = .*/port1 = '050018dc5e040000130b0000b87a6d04'/\" " & quoted form of cfg
do shell script "/usr/bin/open --env SDL_JOYSTICK_HIDAPI_XBOX_ONE=0 -a xemu"
