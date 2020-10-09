#!/usr/bin/env bash
## osxdotz: OS X configuration
set -eu

## Based on:
## https://github.com/mathiasbynens/dotfiles/blob/master/.macos

echo ""
echo "osxdotz::defaults"
echo "!!! Keep System Preferences and other application preferences windows closed for best results !!!"
echo "Note: Finder and other apps/services will be killed during this process."
sleep 8
killall "System Preferences" || :

## Ask for the administrator password up front
sudo -v
## Keep-alive: update existing `sudo` time stamp until finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

## if $basedir is unset
if [ -z ${basedir+x} ]; then
  basedir=$(dirname "$(perl -MCwd=realpath -e "print realpath '$0'")")
  basedir=$(dirname "$basedir")
fi

## source private options (like my own personal $defaults_osxhostname, $defaults_loginnote, etc.)
## if the file is present, any options defined there will override the defaults in this file
## you don't have to do that though. you can just edit the values in this file directly.
## i just did it to avoid putting personal information on github
private_defaults="$HOME/.config/osxdotz/private_defaults.conf"
if [[ -e "$private_defaults" ]]; then
  echo ""
  echo "Found private config: $private_defaults"
  source "$private_defaults"
fi


###############################################################################
## General UI/UX
###############################################################################

echo ""
echo "***** General UI/UX *****"

echo ""
defaults_osxhostname=${defaults_osxhostname-"MyMac"}
echo "Setting computer name to $defaults_osxhostname (System Preferences → Sharing)"
sudo scutil --set ComputerName "$defaults_osxhostname"
sudo scutil --set HostName "$defaults_osxhostname"
sudo scutil --set LocalHostName "$defaults_osxhostname"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$defaults_osxhostname"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server ServerDescription -string "$defaults_osxhostname"

# echo ""
# echo "Setting highlight color to green"
# defaults write NSGlobalDomain AppleHighlightColor -string "0.764700 0.976500 0.568600"

# echo ""
# echo "Disabling OS X Gate Keeper"
# echo "(You'll be able to install any app you want from here on, not just Mac App Store apps)"
# sudo spctl --master-disable
# sudo defaults write /var/db/SystemPolicy-prefs.plist enabled -string no

echo ""
echo "Disabling the “Are you sure you want to open this application? its from the internet etc” dialog"
defaults write com.apple.LaunchServices LSQuarantine -bool false

echo ""
echo "Increasing the window resize speed for Cocoa applications"
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001

echo ""
echo "Saving to local disk (not to iCloud) by default"
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

echo ""
echo "Expanding the save and printer dialog panels by default"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

# echo ""
# echo "Automatically quit printer app once the print jobs complete"
# defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

# ## Try e.g. `cd /tmp; unidecode "\x{0000}" > cc.txt; open -e cc.txt`
# echo ""
# echo "Displaying ASCII control characters using caret notation in standard text views"
# defaults write NSGlobalDomain NSTextShowsControlCharacters -bool true

echo ""
echo "Disabling automatic termination of inactive apps (typically when there are 0 app windows open)"
defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

echo ""
echo "Reveal IP address, hostname, OS version, etc. when clicking the clock in the login screen"
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

echo ""
defaults_loginnote=${defaults_loginnote-"Reward if found! Please return to rightful owner!"}
echo "Adding a note to the login/lock screen: $defaults_loginnote"
sudo defaults write /Library/Preferences/com.apple.loginwindow LoginwindowText "$defaults_loginnote"

echo ""
echo "Restoring old power button behavior: show shutdown/restart dialog instead of going to sleep"
defaults write com.apple.loginwindow PowerButtonSleepsSystem -bool false

# echo ""
# echo "Check for software updates daily, not just once per week"
# defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

echo ""
echo "Disable the crash reporter"
echo "  - no application crash report dialogs are shown to the user (though they are still logged)."
defaults write com.apple.CrashReporter DialogType Server

echo ""
echo "Set Help Viewer windows to not be always-on-top"
defaults write com.apple.helpviewer DevMode -bool true

echo ""
echo "Disk Utility: show advanced options incl. debug menu, hidden volumes, unmounted volumes, checksum routines..."
defaults write com.apple.DiskUtility advanced-image-options -bool true
defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true

## broken
# echo ""
# echo "Disabling 'recent files' in VLC (pr0n mode)"
# defaults delete org.videolan.vlc.LSSharedFileList RecentDocuments || :
# defaults write org.videolan.vlc.LSSharedFileList RecentDocuments -dict-add MaxAmount 0
# defaults write org.videolan.vlc NSRecentDocumentsLimit 0

echo ""
echo "Disabling Notification Center and removing the menu bar icon"
launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist 2> /dev/null

echo ""
echo "Disabling autosave behavior in Preview.app etc."
echo "  (System Preferences → General → Ask to keep changes when closing documents)"
defaults write NSGlobalDomain NSCloseAlwaysConfirmsChanges -bool true

echo ""
echo "Disabling system-wide Resume (i.e. saved application states that get restored when you re-open apps)"
echo "  (System Preferences → General → Close windows when quitting an app)"
defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false

echo ""
echo "Disabling system-wide Resume on reboot (ungraceful or otherwise)"
## LoginHook might be gone in macOS 10.15
loginhook_path=/usr/local/bin/LoginHook.sh
sudo cp "$basedir/resources/never_relaunch_at_login.sh" $loginhook_path
sudo chmod 755 $loginhook_path
## https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CustomLogin.html
sudo defaults write com.apple.loginwindow LoginHook $loginhook_path


###############################################################################
## Menu Bar
###############################################################################

echo ""
echo "***** Menu Bar *****"

echo ""
defaults_menubarclockformat=${defaults_menubarclockformat-"EEE MMM d  h:mm:ss a"}
defaults_menubarclockflashsep=${defaults_menubarclockflashsep-"false"}
defaults_menubarclockanalog=${defaults_menubarclockanalog-"false"}
echo "Menubar clock datetime format: $defaults_menubarclockformat"
echo " [day of week = EEE][month = MMM][date = d][12 hour = h | 24 hour = H]:[minute = mm]:[second = ss][am/pm = a]"
echo " e.g.: 'EEE MMM d  h:mm:ss a' = Sat Jul 4 1:45:59 PM"
echo " e.g.: 'EEE H:mm' = Sat 13:45"
defaults write com.apple.menuextra.clock DateFormat -string "$defaults_menubarclockformat"
echo "Menubar clock: flash the time separators? $defaults_menubarclockflashsep"
defaults write com.apple.menuextra.clock FlashDateSeparators -bool $defaults_menubarclockflashsep
echo "Menubar clock: analog? $defaults_menubarclockanalog"
defaults write com.apple.menuextra.clock IsAnalog -bool $defaults_menubarclockanalog

echo ""
defaults_menubarshowbattpercent=${defaults_menubarshowbattpercent-"YES"}
echo "Menubar: show battery percentage (YES or NO)? $defaults_menubarshowbattpercent"
defaults write com.apple.menuextra.battery ShowPercent -string "$defaults_menubarshowbattpercent"

## System Preferences → Displays → Show mirroring options in the menu bar when available
## Forces "/System/Library/CoreServices/Menu Extras/Displays.menu"
defaults write com.apple.airplay showInMenuBarIfPresent -bool false

echo ""
## edit the following array to configure the menubar
##   by commenting/uncommenting and ordering its elements (top→bottom becomes left→right in the menubar)
## macOS 10.12: ordering doesn't seem to work anymore, but you can cmd+click-and-drag items around manually
if [ -z ${defaults_menubaritems+x} ]; then
  defaults_menubaritems=(
    "/System/Library/CoreServices/Menu Extras/AirPort.menu"
    "/System/Library/CoreServices/Menu Extras/Bluetooth.menu"
    "/System/Library/CoreServices/Menu Extras/Battery.menu"
    "/System/Library/CoreServices/Menu Extras/Clock.menu"
    "/Applications/Utilities/Keychain Access.app/Contents/Resources/Keychain.menu"
#     "/System/Library/CoreServices/Menu Extras/Displays.menu"
#     "/System/Library/CoreServices/Menu Extras/Eject.menu"
#     "/System/Library/CoreServices/Menu Extras/ExpressCard.menu"
#     "/System/Library/CoreServices/Menu Extras/Fax.menu"
#     "/System/Library/CoreServices/Menu Extras/HomeSync.menu"
#     "/System/Library/CoreServices/Menu Extras/Ink.menu"
#     "/System/Library/CoreServices/Menu Extras/IrDA.menu"
#     "/System/Library/CoreServices/Menu Extras/PPP.menu"
#     "/System/Library/CoreServices/Menu Extras/PPPoE.menu"
#     "/System/Library/CoreServices/Menu Extras/RemoteDesktop.menu"
#     "/System/Library/CoreServices/Menu Extras/Script Menu.menu"
#     "/System/Library/CoreServices/Menu Extras/TextInput.menu"
#     "/System/Library/CoreServices/Menu Extras/TimeMachine.menu"
#     "/System/Library/CoreServices/Menu Extras/UniversalAccess.menu"
#     "/System/Library/CoreServices/Menu Extras/User.menu"
#     "/System/Library/CoreServices/Menu Extras/VPN.menu"
#     "/System/Library/CoreServices/Menu Extras/Volume.menu"
#     "/System/Library/CoreServices/Menu Extras/WWAN.menu"
#     "/System/Library/CoreServices/Menu Extras/iChat.menu"
  )
fi
echo "Setting up Menu Bar items"
defaults write com.apple.systemuiserver menuExtras -array "${defaults_menubaritems[@]}"


###############################################################################
## Power Management
###############################################################################

echo ""
echo "***** Power Management *****"

# echo ""
# ## The default on supported desktops. The system will not back memory up to persistent storage. 
# ## The system must wake from the contents of memory; the system will lose context on power loss. 
# ## This is, historically, plain old sleep.
# echo "Disable hibernation/SafeSleep (speeds up entering sleep mode)"
# sudo pmset -a hibernatemode 0

# echo ""
# echo "Remove the sleep image file to save disk space"
# sudo rm /private/var/vm/sleepimage
# echo "Creating a zero-byte file instead"
# sudo touch /private/var/vm/sleepimage
# echo "and make sure it can't be rewritten"
# sudo chflags uchg /private/var/vm/sleepimage

echo ""
## when asleep: specifies the delay, in seconds, before writing the hibernation image to 
##   disk and powering off memory for Standby.
## 43200 s = 12 hr
defaults_pmsetstandbydelay=${defaults_pmsetstandbydelay-"43200"}
echo "Speeding up waking from sleep: only go from sleep to hibernate after $defaults_pmsetstandbydelay s"
echo "  (by default, OS X switches from 'sleep' to 'hibernate' after about an hour)"
# http://www.cultofmac.com/221392/quick-hack-speeds-up-retina-macbooks-wake-from-sleep-os-x-tips/
sudo pmset -a standbydelay $defaults_pmsetstandbydelay

echo ""
defaults_pmsetCdisplaysleep=${defaults_pmsetCdisplaysleep-"20"}
echo "Power mgmt: when plugged into the charger, turn off the display after: $defaults_pmsetCdisplaysleep min"
sudo pmset -c displaysleep $defaults_pmsetCdisplaysleep

echo ""
## 0 = never sleep
defaults_pmsetCsleep=${defaults_pmsetCsleep-"0"}
echo "Power mgmt: when plugged into the charger, sleep the computer after: $defaults_pmsetCsleep min"
sudo pmset -c sleep $defaults_pmsetCsleep

echo ""
defaults_pmsetBdisplaysleep=${defaults_pmsetBdisplaysleep-"3"}
echo "Power mgmt: on battery power, turn off the display after: $defaults_pmsetBdisplaysleep min"
sudo pmset -b displaysleep $defaults_pmsetBdisplaysleep

echo ""
defaults_pmsetBsleep=${defaults_pmsetBsleep-"20"}
echo "Power mgmt: on battery power, sleep the computer after: $defaults_pmsetBsleep min"
sudo pmset -b sleep $defaults_pmsetBsleep


###############################################################################
## Screensaver and Displays
###############################################################################

echo ""
echo "***** Screensaver and Displays *****"

echo ""
## 1800 s = 30 min
defaults_screensaveridleTime=${defaults_screensaveridleTime-"1800"}
echo "Screensaver: start after $defaults_screensaveridleTime seconds"
# if [[ -e "$HOME/Library/Preferences/ByHost/com.apple.screensaver.plist" ]]; then
#   defaults write ~/Library/Preferences/ByHost/com.apple.screensaver idleTime -int $defaults_screensaveridleTime
# else
#   macUUID=`ioreg -rd1 -c IOPlatformExpertDevice | grep -i "UUID" | cut -c27-62`
#   if [[ -e "$HOME/Library/Preferences/ByHost/com.apple.screensaver.$macUUID.plist" ]]; then
#     defaults write ~/Library/Preferences/ByHost/com.apple.screensaver.$macUUID.plist idleTime -int $defaults_screensaveridleTime
#   else
#     echo "Error: Hmm, screensaver plist not found. Fix me."
#     exit 1
#   fi
# fi
## note: the following simpler command should work instead of the above stuff, 
##   but i'm not 100% sure it will always work.. :
defaults write ~/Library/Preferences/ByHost/com.apple.screensaver idleTime -int $defaults_screensaveridleTime

echo ""
defaults_screensaverpwdelay=${defaults_screensaverpwdelay-"10"}
echo "Require password $defaults_screensaverpwdelay seconds after sleep or screen saver begins"
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int $defaults_screensaverpwdelay

echo ""
defaults_autodisplaybrightness=${defaults_autodisplaybrightness-"false"}
echo "Automatically adjust display brightness based on ambient lighting (System Preferences → Displays)? $defaults_autodisplaybrightness"
sudo defaults write /Library/Preferences/com.apple.iokit.AmbientLightSensor.plist "Automatic Display Enabled" -bool $defaults_autodisplaybrightness

echo ""
echo "Enabling subpixel font rendering on non-Apple LCDs"
defaults write NSGlobalDomain AppleFontSmoothing -int 1

echo ""
echo "Enabling HiDPI display modes (requires restart)"
sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true


###############################################################################
## Trackpad, Mouse, Keyboard, Input, and Bluetooth accessories
###############################################################################

echo ""
echo "***** Trackpad, Mouse, Keyboard, Input, and Bluetooth accessories *****"

echo ""
echo "Enabling tap-to-click for this user and for the login screen"
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

echo ""
echo "Disabling “natural” scrolling"
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

echo ""
echo "Setting trackpad & mouse speed to a reasonable number"
defaults write NSGlobalDomain com.apple.trackpad.scaling 1
defaults write NSGlobalDomain com.apple.mouse.scaling 2

echo ""
echo "Use scroll gesture with the Ctrl (^) modifier key to zoom"
# ugh, seems broken for now
defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true
# defaults write com.apple.universalaccess HIDScrollZoomModifierMask -int 262144
# echo "Follow the keyboard focus while zoomed in"
# defaults write com.apple.universalaccess closeViewZoomFollowsFocus -bool true

# echo ""
# echo "Disable (automatically) Adjusting keyboard brightness in low light"
# sudo defaults write /Library/Preferences/com.apple.iokit.AmbientLightSensor.plist "Automatic Keyboard Enabled" -bool false

echo ""
defaults_autokeyboardbrightness=${defaults_autokeyboardbrightness-"true"}
defaults_autokeyboardilluminationtimeout=${defaults_autokeyboardilluminationtimeout-"300"}
echo "(Auto-)Adjust keyboard brightness in low light? $defaults_autokeyboardbrightness"
sudo defaults write /Library/Preferences/com.apple.iokit.AmbientLightSensor.plist "Automatic Keyboard Enabled" -bool $defaults_autokeyboardbrightness
echo "...and turn off keyboard illumination when computer is not used for: $defaults_autokeyboardilluminationtimeout seconds"
sudo defaults write /Library/Preferences/com.apple.iokit.AmbientLightSensor.plist "Keyboard Dim Time" -int $defaults_autokeyboardilluminationtimeout

echo ""
echo "Enabling full keyboard access for all controls (e.g. enable Tab in modal dialogs)"
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

echo ""
echo "Disabling press-and-hold for keys in favor of key repeat"
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

echo ""
echo "Setting a blazingly fast keyboard repeat rate"
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 15

echo ""
echo "Disabling auto-correct (System Preferences → Keyboard → Text)"
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

echo ""
echo "Disabling annoying 'smart' quotes, dashes, and ellipses, etc"
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# echo ""
# echo "Increasing sound quality for Bluetooth headphones/headsets"
# defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40


###############################################################################
## Finder
###############################################################################

echo ""
echo "***** Finder *****"

# echo ""
# echo "Showing icons for hard drives, servers, and removable media on the desktop"
# defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true

echo ""
## more info: http://krypted.com/mac-security/lsregister-associating-file-types-in-mac-os-x/
echo "Removing duplicates in the 'Open With' context menu (also see 'lscleanup' alias)"
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister -kill -r -domain local -domain system -domain user

echo ""
echo "Showing all filename extensions in Finder by default"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

echo ""
echo "Showing hidden files in Finder by default"
defaults write com.apple.finder AppleShowAllFiles -bool true

echo ""
echo "Showing status bar in Finder by default"
defaults write com.apple.finder ShowStatusBar -bool true

echo ""
echo "Showing path bar in Finder by default"
defaults write com.apple.finder ShowPathbar -bool true

echo ""
echo "New Finder windows show the home dir by default"
## For other paths, use "PfLo" and "file:///full/path/here/"
## For desktop, use "PfDe" and "file://${HOME}/Desktop/"
defaults write com.apple.finder NewWindowTarget -string "PfHm"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/"

## broken? https://origin-discussions-us.apple.com/thread/7250702
echo ""
echo "Allow text selection in Quick Look (i.e. when hitting space with a file selected in Finder)"
defaults write com.apple.finder QLEnableTextSelection -bool true

# echo ""
# echo "Displaying full POSIX path as Finder window title"
# defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

echo ""
echo "Disabling the Finder warning when changing a file extension"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

echo ""
defaults_finderdefaultsearchscope=${defaults_finderdefaultsearchscope-"SCcf"}
echo "When performing a search in Finder, set the default search scope to: $defaults_finderdefaultsearchscope"
echo "(SCev - Search This Mac, SCcf - Search the Current Folder, SCsp - Use the Previous Search Scope)"
defaults write com.apple.finder FXDefaultSearchScope -string "$defaults_finderdefaultsearchscope"

echo ""
defaults_finderviewmode=${defaults_finderviewmode-"Nlsv"}
echo "Setting default Finder view mode to: $defaults_finderviewmode"
echo "(Nlsv – List View, icnv – Icon View, clmv – Column View, glyv - Gallery View)"
defaults write com.apple.finder FXPreferredViewStyle -string "$defaults_finderviewmode"

echo ""
echo "Avoiding the creation of .DS_Store files on network or USB volumes"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

echo ""
echo "Disabling cmd+P in Finder to avoid accidentally printing stuff"
## by default, cmd+P in Finder prints whatever file(s) you have selected without warning or prompting.
## this really sucks because cmd+P is right next to cmd+O.
## fix this by redefining cmd+P in Finder (System Preferences → Keyboard → Shortcuts) to something innocuous:
defaults write com.apple.finder NSUserKeyEquivalents -dict-add "Bring All to Front" -string "@p"

# echo ""
# echo "Disabling disk image verification"
# defaults write com.apple.frameworks.diskimages skip-verify -bool true
# defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
# defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

# echo ""
# echo "Enabling snap-to-grid for icons on the desktop and in other icon views"
# /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
# /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
# /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

# echo ""
# echo "Setting Finder sidebar icon size to small size"
# defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1

# echo ""
# echo "Disable the warning before emptying the Trash"
# defaults write com.apple.finder WarnOnEmptyTrash -bool false

# echo ""
# echo "Empty Trash securely by default"
# defaults write com.apple.finder EmptyTrashSecurely -bool true


###############################################################################
## Dock, Mission Control, and Dashboard
###############################################################################

echo ""
echo "***** Dock, Mission Control, and Dashboard *****"

## Wipe all (default) app icons from the Dock
##  This is only really useful when setting up a new Mac, or if you don't use
##  the Dock to launch apps.
# defaults write com.apple.dock persistent-apps -array

echo ""
defaults_docktilesize=${defaults_docktilesize-"38"}
echo "Dock: setting icon size to: $defaults_docktilesize px"
defaults write com.apple.dock tilesize -int $defaults_docktilesize

echo ""
defaults_dockorientation=${defaults_dockorientation-"bottom"}
echo "Dock: setting the orientation to: $defaults_dockorientation"
echo "  (options: bottom, left, right)"
defaults write com.apple.dock orientation -string "$defaults_dockorientation"

echo ""
defaults_dockmineffect=${defaults_dockmineffect-"genie"}
echo "Dock: setting minimize animation to: $defaults_dockmineffect"
echo "  (options: genie, scale)"
defaults write com.apple.dock mineffect -string "$defaults_dockmineffect"

echo ""
defaults_minimizetoapplication=${defaults_minimizetoapplication-"false"}
echo "Dock: minimize windows into their application icons? $defaults_minimizetoapplication"
defaults write com.apple.dock minimize-to-application -bool $defaults_minimizetoapplication

# echo ""
# echo "Setting Dock to auto-hide and removing the auto-hiding delay"
# defaults write com.apple.dock autohide -bool true
# defaults write com.apple.dock autohide-delay -float 0
# defaults write com.apple.dock autohide-time-modifier -float 0

echo ""
defaults_showrecentsindock=${defaults_showrecentsindock-"false"}
echo "Dock: show recent applications? $defaults_showrecentsindock"
defaults write com.apple.dock show-recents -bool $defaults_showrecentsindock

echo ""
echo "Mission Control: Speeding up animations"
defaults write com.apple.dock expose-animation-duration -float 0.1

echo ""
## Hot Corners
##  0: none
##  1: none
##  2: Mission Control
##  3: Show application windows
##  4: Desktop
##  5: Start screen saver
##  6: Disable screen saver
##  7: Dashboard
## 10: Put display to sleep
## 11: Launchpad
## 12: Notification Center
## 13: Lock Screen
defaults_hotcornerBottomLeft=${defaults_hotcornerBottomLeft-"2"}
defaults_hotcornerBottomRight=${defaults_hotcornerBottomRight-"1"}
defaults_hotcornerTopLeft=${defaults_hotcornerTopLeft-"4"}
defaults_hotcornerTopRight=${defaults_hotcornerTopRight-"1"}
echo "Mission Control: setting up Hot Corners"
echo "  bottom left: $defaults_hotcornerBottomLeft"
echo "  bottom right: $defaults_hotcornerBottomRight"
echo "  top left: $defaults_hotcornerTopLeft"
echo "  top right: $defaults_hotcornerTopRight"
echo "  (0,1=null, 2=Mission Control, 3=Show application windows, 4=Desktop, 5=Start screen saver, 6=Disable screen saver, 7=Dashboard, 10=Put display to sleep, 11=Launchpad, 12=Notification Center, 13=Lock Screen)"
defaults write com.apple.dock wvous-bl-corner -int $defaults_hotcornerBottomLeft
defaults write com.apple.dock wvous-br-corner -int $defaults_hotcornerBottomRight
defaults write com.apple.dock wvous-tl-corner -int $defaults_hotcornerTopLeft
defaults write com.apple.dock wvous-tr-corner -int $defaults_hotcornerTopRight
## it's kind of unclear what the -modifier keys do at this time, but it seems safe to leave them at 0.
defaults write com.apple.dock wvous-bl-modifier -int 0
defaults write com.apple.dock wvous-br-modifier -int 0
defaults write com.apple.dock wvous-tl-modifier -int 0
defaults write com.apple.dock wvous-tr-modifier -int 0

echo ""
defaults_exposegroupbyapp=${defaults_exposegroupbyapp-"true"}
echo "Mission Control: Group windows by application? $defaults_exposegroupbyapp"
defaults write com.apple.dock "expose-group-by-app" -bool $defaults_exposegroupbyapp

echo ""
echo "Disabling the Dashboard completely"
defaults write com.apple.dashboard mcx-disabled -bool true
defaults write com.apple.dashboard enabled-state -int 1

# echo ""
# defaults_dashboardmode=${defaults_dashboardmode-"2"}
# echo "Enabling the Dashboard, mode: $defaults_dashboardmode"
# echo "  (2 - As Space, 3 - Overlay)"
# defaults write com.apple.dashboard mcx-disabled -bool false
# defaults write com.apple.dashboard enabled-state -int $defaults_dashboardmode


###############################################################################
## Safari & WebKit (lol, as if anyone uses Safari)
###############################################################################

# Privacy: don’t send search queries to Apple
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

# Press Tab to highlight each item on a web page
defaults write com.apple.Safari WebKitTabToLinksPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks -bool true

# Show the full URL in the address bar (note: this still hides the scheme)
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

## Set Safari’s home page to `about:blank` for faster loading
# defaults write com.apple.Safari HomePage -string "about:blank"

# Prevent Safari from opening ‘safe’ files automatically after downloading
defaults write com.apple.Safari AutoOpenSafeDownloads -bool false

# Allow hitting the Backspace key to go to the previous page in history
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2BackspaceKeyNavigationEnabled -bool true

# Hide Safari’s bookmarks bar by default
defaults write com.apple.Safari ShowFavoritesBar -bool false

# Hide Safari’s sidebar in Top Sites
defaults write com.apple.Safari ShowSidebarInTopSites -bool false

# Disable Safari’s thumbnail cache for History and Top Sites
defaults write com.apple.Safari DebugSnapshotsUpdatePolicy -int 2

# Enable Safari’s debug menu
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

# Make Safari’s search banners default to Contains instead of Starts With
defaults write com.apple.Safari FindOnPageMatchesWordStartsOnly -bool false

# Remove useless icons from Safari’s bookmarks bar
defaults write com.apple.Safari ProxiesInBookmarksBar "()"

# Enable the Develop menu and the Web Inspector in Safari
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

# Add a context menu item for showing the Web Inspector in web views
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

# Enable continuous spellchecking
defaults write com.apple.Safari WebContinuousSpellCheckingEnabled -bool true
# Disable auto-correct
# defaults write com.apple.Safari WebAutomaticSpellingCorrectionEnabled -bool false

# Disable AutoFill
defaults write com.apple.Safari AutoFillFromAddressBook -bool false
defaults write com.apple.Safari AutoFillPasswords -bool false
defaults write com.apple.Safari AutoFillCreditCardData -bool false
defaults write com.apple.Safari AutoFillMiscellaneousForms -bool false

# Warn about fraudulent websites
defaults write com.apple.Safari WarnAboutFraudulentWebsites -bool true

# Disable plug-ins
# defaults write com.apple.Safari WebKitPluginsEnabled -bool false
# defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2PluginsEnabled -bool false

# Disable Java
# defaults write com.apple.Safari WebKitJavaEnabled -bool false
# defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaEnabled -bool false

# Block pop-up windows
defaults write com.apple.Safari WebKitJavaScriptCanOpenWindowsAutomatically -bool false
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2JavaScriptCanOpenWindowsAutomatically -bool false

# Disable auto-playing video
#defaults write com.apple.Safari WebKitMediaPlaybackAllowsInline -bool false
#defaults write com.apple.SafariTechnologyPreview WebKitMediaPlaybackAllowsInline -bool false
#defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2AllowsInlineMediaPlayback -bool false
#defaults write com.apple.SafariTechnologyPreview com.apple.Safari.ContentPageGroupIdentifier.WebKit2AllowsInlineMediaPlayback -bool false

# Enable “Do Not Track”
defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

# Update extensions automatically
defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true


###############################################################################
## Terminal
###############################################################################

echo ""
echo "***** Terminal *****"

echo ""
defaults_terminaltheme=${defaults_terminaltheme-"Pro"}
echo "Terminal: setting default/startup theme: $defaults_terminaltheme"
defaults write com.apple.Terminal "Default Window Settings" -string "$defaults_terminaltheme"
defaults write com.apple.Terminal "Startup Window Settings" -string "$defaults_terminaltheme"


###############################################################################
## Time Machine
###############################################################################

echo ""
echo "***** Time Machine *****"

echo ""
echo "Preventing Time Machine from prompting to use new hard drives as backup volume"
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

# echo ""
# echo "Disabling local Time Machine backups"
# hash tmutil &> /dev/null && sudo tmutil disablelocal


###############################################################################
## Google Chrome
###############################################################################

echo ""
echo "***** Google Chrome *****"

echo ""
echo "Disable annoying backswipe (horizontal scroll history navigation) in Chrome"
## trackpad
defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool false
defaults write com.google.Chrome.canary AppleEnableMouseSwipeNavigateWithScrolls -bool false
## magic mouse
defaults write com.google.Chrome AppleEnableMouseSwipeNavigateWithScrolls -bool false
defaults write com.google.Chrome.canary AppleEnableMouseSwipeNavigateWithScrolls -bool false

## Expand the print dialog by default
defaults write com.google.Chrome PMPrintingExpandedStateForPrint2 -bool true
defaults write com.google.Chrome.canary PMPrintingExpandedStateForPrint2 -bool true

###############################################################################
## Kill affected applications
###############################################################################

echo ""
echo "***** Killing affected applications... *****"

for app in "Activity Monitor" "Address Book" "Calendar" "Contacts" "cfprefsd" \
  "Dock" "Finder" "Mail" "Messages" "Opera" "Safari" "SizeUp" "Spectacle" \
  "SystemUIServer" "System Preferences" "iCal"; do
  echo "killing '$app'"
  killall "$app" || :
done

echo ""
echo "Done. Note that some of these changes require a logout/restart to take effect."
echo "Restarting now before messing with stuff is STRONGLY recommended."
