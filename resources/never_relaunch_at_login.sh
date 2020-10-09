#!/usr/bin/env bash
## disable relaunching apps on reboot or crash

## this script should be hooked at login using LoginHook in com.apple.loginwindow:
## https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CustomLogin.html

## despite disabling system resume (System Preferences → General → Close windows when quitting an app):
##   defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false
## apps get relaunched when you reboot.
## if the system crashes, you don't have the option of unchecking "Reopen windows when logging back in" on the reboot dialog.

## https://www.jamf.com/jamf-nation/discussions/23993/disable-self-service-from-launching-at-reboot#responseChild145131

## Get the logged in user
# loggedInUser=$(stat -f%Su /dev/console)
## actually, a LoginHook'd script is run as root, but for convenience, $1 returns the short name of the user who is logging in.
loggedInUser=$1

## Get the Mac's UUID string
UUID=$(ioreg -rd1 -c IOPlatformExpertDevice | awk -F'"' '/IOPlatformUUID/{print $4}')

## Delete the plist array
/usr/libexec/PlistBuddy -c 'Delete :TALAppsToRelaunchAtLogin' /Users/${loggedInUser}/Library/Preferences/ByHost/com.apple.loginwindow.${UUID}.plist
