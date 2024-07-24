#============================================================================
# Title: macos
#
# Description:
# Sets macos preferences. Mostly taken from Mostly taken from
# https://mths.be/macos
#============================================================================

chirp --title "Configure MacOS"

chirp --info "Setting macOS preferences"

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until everything has finished
while true; do
	sudo -n true
	sleep 60
	kill -0 "$$" || exit
done 2>/dev/null &

###############################################################################
# General UI/UX                                                               #
###############################################################################

chirp --subtitle "General UI/UX"

chirp --info "Set computer name (as done via System Preferences → Sharing)"
sudo scutil --set ComputerName "Matine's MacBook"
sudo scutil --set HostName "Matines-MacBook"
sudo scutil --set LocalHostName "Matines-MacBook"
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "Matines-MacBook"

chirp --info "Set sidebar icon size to medium"
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2

chirp --info "Turn on zooming"
defaults write com.apple.universalaccess closeViewScrollWheelToggle -bool true

chirp --info "Expand save panel by default"
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

chirp --info "Expand print panel by default"
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

chirp --info "Save to disk (not to iCloud) by default"
defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

chirp --info "Automatically quit printer app once the print jobs complete"
defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

chirp --info "Disable the 'Are you sure you want to open this application?' dialog"
defaults write com.apple.LaunchServices LSQuarantine -bool false

chirp --info "Enable moving a window by clicking on any part of it with cmd + ctrl"
defaults write -g NSWindowShouldDragOnGesture -bool true

chirp --info "Reveal IP address, hostname, OS version, etc. when clicking the clock in the login window"
sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName

chirp --info "Disable Notification Center and remove the menu bar icon"
launchctl load -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist 2>/dev/null

# Reduce spacing between menu bar icons
defaults -currentHost write -globalDomain NSStatusItemSpacing -int 7
defaults -currentHost write -globalDomain NSStatusItemSelectionPadding -int 7

chirp --info "Disable automatic capitalization as it’s annoying when typing code"
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

chirp --info "Disable smart dashes as they’re annoying when typing code"
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

chirp --info "Disable automatic period substitution as it’s annoying when typing code"
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

chirp --info "Disable smart quotes as they’re annoying when typing code"
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

chirp --info "Disable auto-correct"
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

###############################################################################
# Trackpad, mouse, keyboard, Bluetooth accessories, and input                 #
###############################################################################

chirp --subtitle "Input"

chirp --info "Increase sound quality for Bluetooth headphones/headsets"
defaults write com.apple.BluetoothAudioAgent "Apple Bitpool Min (editable)" -int 40

chirp --info "Enable full keyboard access for all controls"
# (e.g. enable Tab in modal dialogs)
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

chirp --info "Disable press-and-hold for keys in favor of key repeat"
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

chirp --info "Set a blazingly fast keyboard repeat rate"
defaults write NSGlobalDomain KeyRepeat -int 3
defaults write NSGlobalDomain InitialKeyRepeat -int 50

chirp --info "Set language and text formats"
# Note: if you’re in the US, replace `EUR` with `USD`, `Centimeters` with
# `Inches`, `en_GB` with `en_US`, and `true` with `false`.
defaults write NSGlobalDomain AppleLanguages -array "en"
defaults write NSGlobalDomain AppleLocale -string "en_GB@currency=GBP"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Centimeters"
defaults write NSGlobalDomain AppleMetricUnits -bool true

chirp --info "Set the timezone"
# See `sudo systemsetup -listtimezones` for other values"
# sudo systemsetup -settimezone "Europe/Brussels" > /dev/null

chirp --info "Stop iTunes from responding to the keyboard media keys"
launchctl unload -w /System/Library/LaunchAgents/com.apple.rcd.plist 2>/dev/null

chirp --info "Show battery percentage in status bar"
defaults write com.apple.menuextra.battery ShowPercent YES

###############################################################################
# Energy saving                                                               #
###############################################################################

chirp --subtitle "Energy saving"

chirp --info "Enable lid wakeup"
sudo pmset -a lidwake 1

chirp --info "Sleep the display after 10 minutes"
sudo pmset -a displaysleep 10

chirp --info "Disable machine sleep while charging"
sudo pmset -c sleep 30

chirp --info "Set machine sleep to 5 minutes on battery"
sudo pmset -b sleep 20

###############################################################################
# Screen                                                                      #
###############################################################################

chirp --subtitle "Screen"

chirp --info "Require password immediately after sleep or screen saver begins"
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

chirp --info "Save screenshots to the Screenshots folder"
defaults write com.apple.screencapture location -string "${HOME}/Screenshots"

chirp --info "Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)"
defaults write com.apple.screencapture type -string "png"

chirp --info "Disable shadow in screenshots"
defaults write com.apple.screencapture disable-shadow -bool true

chirp --info "Enable subpixel font rendering on non-Apple LCDs"
defaults write NSGlobalDomain AppleFontSmoothing -int 1

chirp --info "Enable HiDPI display modes (requires restart)"
sudo defaults write /Library/Preferences/com.apple.windowserver DisplayResolutionEnabled -bool true

###############################################################################
# Finder                                                                      #
###############################################################################

chirp --subtitle "Finder"

chirp --info "Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons"
defaults write com.apple.finder QuitMenuItem -bool true

chirp --info "Set Desktop as the default location for new Finder windows"
# For other paths, use `PfLo` and `file:///full/path/here/`
defaults write com.apple.finder NewWindowTarget -string "PfDe"
defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"

chirp --info "Show icons for hard drives, servers, and removable media on the desktop"
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

chirp --info "Finder: Show hidden files by default"
defaults write com.apple.finder AppleShowAllFiles -bool true

chirp --info "Finder: show all filename extensions"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

chirp --info "Finder: show status bar"
defaults write com.apple.finder ShowStatusBar -bool true

chirp --info "Finder: show path bar"
defaults write com.apple.finder ShowPathbar -bool true

chirp --info "Display full POSIX path as Finder window title"
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

chirp --info "Keep folders on top when sorting by name"
defaults write com.apple.finder _FXSortFoldersFirst -bool true

chirp --info "When performing a search, search the current folder by default"
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

chirp --info "Disable the warning when changing a file extension"
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

chirp --info "Avoid creating .DS_Store files on network or USB volumes"
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

chirp --info "Disable disk image verification"
defaults write com.apple.frameworks.diskimages skip-verify -bool true
defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

chirp --info "Automatically open a new Finder window when a volume is mounted"
defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

chirp --info "Show item info near icons on the desktop and in other icon views"
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:showItemInfo true" ~/Library/Preferences/com.apple.finder.plist

chirp --info "Show item info to the right of the icons on the desktop"
/usr/libexec/PlistBuddy -c "Set DesktopViewSettings:IconViewSettings:labelOnBottom false" ~/Library/Preferences/com.apple.finder.plist

chirp --info "Enable snap-to-grid for icons on the desktop and in other icon views"
/usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
/usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

chirp --info "Use column view in all Finder windows by default"
# Four-letter codes for the other view modes: `icnv`, `clmv`, `glyv`
defaults write com.apple.Finder FXPreferredViewStyle Nlsv

chirp --info "Enable AirDrop over Ethernet and on unsupported Macs running Lion"
defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

chirp --info "Show the ~/Library folder"
chflags nohidden ~/Library

chirp --info "Show the /Volumes folder"
sudo chflags nohidden /Volumes

chirp --info "Expand File Info panes"
# “General”, “Open with”, and “Sharing & Permissions”
defaults write com.apple.finder FXInfoPanesExpanded -dict \
	General -bool true \
	OpenWith -bool true \
	Privileges -bool true

chirp --info "Open untitled file rather than iCloud syncing crap"
defaults write -g NSShowAppCentricOpenPanelInsteadOfUntitledFile -bool false

###############################################################################
# Dock, Dashboard, and hot corners                                            #
###############################################################################

chirp --subtitle "Dock & Dashboard"

chirp --info "Enable highlight hover effect for the grid view of a stack (Dock)"
defaults write com.apple.dock mouse-over-hilite-stack -bool true

chirp --info "Set the icon size of Dock items to 44 pixels"
defaults write com.apple.dock tilesize -int 60

chirp --info "Minimize windows into their application’s icon"
defaults write com.apple.dock minimize-to-application -bool true

chirp --info "Show indicator lights for open applications in the Dock"
defaults write com.apple.dock show-chirp --process-indicators -bool true

chirp --info "Show only open applications in the Dock"
defaults write com.apple.dock static-only -bool false

chirp --info "Don’t animate opening applications from the Dock"
defaults write com.apple.dock launchanim -bool false

chirp --info "Disable Dashboard"
defaults write com.apple.dashboard mcx-disabled -bool true

chirp --info "Don’t show Dashboard as a Space"
defaults write com.apple.dock dashboard-in-overlay -bool true

chirp --info "Don’t automatically rearrange Spaces based on most recent use"
defaults write com.apple.dock mru-spaces -bool false

chirp --info "Remove the auto-hiding Dock delay"
defaults write com.apple.dock autohide-delay -float 0

chirp --info "Automatically hide and show the Dock"
defaults write com.apple.dock autohide -bool true

chirp --info "Don’t show recent applications in Dock"
defaults write com.apple.dock show-recents -bool false

chirp --info "Reset Launchpad, but keep the desktop wallpaper intact"
find "${HOME}/Library/Application Support/Dock" -name "*-*.db" -maxdepth 1 -delete

chirp --info "Add iOS & Watch Simulator to Launchpad"
sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app" "/Applications/Simulator.app"
sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/Simulator (Watch).app" "/Applications/Simulator (Watch).app"

###############################################################################
# Safari & WebKit                                                             #
###############################################################################

chirp --subtitle "Safari & WebKit"

chirp --info "Don’t send search queries to Apple"
defaults write com.apple.Safari UniversalSearchEnabled -bool false
defaults write com.apple.Safari SuppressSearchSuggestions -bool true

chirp --info "Show the full URL in the address bar (note: this still hides the scheme)"
defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true

chirp --info "Enable Safari’s debug menu"
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true

chirp --info "Enable the Develop menu and the Web Inspector in Safari"
defaults write com.apple.Safari IncludeDevelopMenu -bool true
defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

chirp --info "Add a context menu item for showing the Web Inspector in web views"
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true

chirp --info "Enable continuous spellchecking"
defaults write com.apple.Safari WebContinuousSpellCheckingEnabled -bool true

chirp --info "Disable auto-correct"
defaults write com.apple.Safari WebAutomaticSpellingCorrectionEnabled -bool false

chirp --info "Update extensions automatically"
defaults write com.apple.Safari InstallExtensionUpdatesAutomatically -bool true

###############################################################################
# Time Machine                                                                #
###############################################################################

chirp --subtitle "Time Machine"

chirp --info "Prevent Time Machine from prompting to use new hard drives as backup volume"
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

###############################################################################
# Activity Monitor                                                            #
###############################################################################

chirp --subtitle "Activity Monitor"

chirp --info "Show the main window when launching Activity Monitor"
defaults write com.apple.ActivityMonitor OpenMainWindow -bool true

chirp --info "Visualize CPU usage in the Activity Monitor Dock icon"
defaults write com.apple.ActivityMonitor IconType -int 5

chirp --info "Show all chirp --processes in Activity Monitor"
defaults write com.apple.ActivityMonitor ShowCategory -int 0

chirp --info "Sort Activity Monitor results by CPU usage"
defaults write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
defaults write com.apple.ActivityMonitor SortDirection -int 0

###############################################################################
# Disk Utility                                                                #
###############################################################################

chirp --subtitle "Disk Utility"

chirp --info "Enable the debug menu in Disk Utility"
defaults write com.apple.DiskUtility DUDebugMenuEnabled -bool true
defaults write com.apple.DiskUtility advanced-image-options -bool true

###############################################################################
# Mac App Store                                                               #
###############################################################################

chirp --subtitle "Mac App Store"

chirp --info "Enable the WebKit Developer Tools in the Mac App Store"
defaults write com.apple.appstore WebKitDeveloperExtras -bool true

chirp --info "Enable Debug Menu in the Mac App Store"
defaults write com.apple.appstore ShowDebugMenu -bool true

chirp --info "Enable the automatic update check"
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

# chirp --info "Check for software updates daily, not just once per week"
# defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# chirp --info "Download newly available updates in background"
# defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

chirp --info "Install System data files & security updates"
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

# chirp --info "Turn on app auto-update"
# defaults write com.apple.commerce AutoUpdate -bool true

###############################################################################
# Photos                                                                      #
###############################################################################

chirp --subtitle "Photos"

chirp --info "Prevent Photos from opening automatically when devices are plugged in"
defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true

###############################################################################
# Kill affected applications                                                  #
###############################################################################

for app in "Activity Monitor" \
	"cfprefsd" \
	"Dock" \
	"Finder" \
	"Google Chrome Canary" \
	"Google Chrome" \
	"Photos" \
	"Safari" \
	"SystemUIServer" \
	"Transmission"; do
	killall "${app}" &>/dev/null
done

chirp --success "macOS preferences applied. Note that some of these changes require a logout/restart to take effect."