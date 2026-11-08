-- Starts the patched xemu-macos fork (movie overlay fix) for the GameSir G7 SE (via OpenJoystickDriver).
-- Prelaunch script: ~/Library/Application Support/xemu/xemu-macos-prelaunch.sh
-- xemu's output goes to ~/Library/Logs/xemu-macos.log (previous run: xemu-macos.log.prev).
set logf to (POSIX path of (path to library folder from user domain)) & "Logs/xemu-macos.log"
set pre to (POSIX path of (path to application support folder from user domain)) & "xemu/xemu-macos-prelaunch.sh"
do shell script "/bin/mv -f " & quoted form of logf & " " & quoted form of (logf & ".prev") & " 2>/dev/null; true"
do shell script "/bin/sh " & quoted form of pre
do shell script "/usr/bin/open --stdout " & quoted form of logf & " --stderr " & quoted form of logf & " --env SDL_JOYSTICK_HIDAPI_XBOX_ONE=0 -a " & quoted form of "/Applications/xemu-macos (patched).app"
