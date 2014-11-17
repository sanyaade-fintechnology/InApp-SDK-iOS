#!/bin/sh

#kill simulator if running
echo "Stopping iPhone Simulator"
killall -s "iPhone Simulator" &> /dev/null
if [ $? -eq 0 ]; then
killall -m -KILL "iPhone Simulator" &> /dev/null
fi

set -ex

#/usr/bin/pkill ssh-agent
#eval $(/usr/bin/ssh-agent)
#/usr/bin/ssh-add /Users/build/.ssh/id-ssh

#WORKSPACE="/Users/build/IntPay-iOS"

# unlock keychain
#if [ -d "/Users/build/Library/Keychains/login.keychain" ]; then
security unlock-keychain -p "builderpayleven" /Users/build/Library/Keychains/login.keychain || exit 1 ;
security set-keychain-settings -u -t 7200 /Users/build/Library/Keychains/login.keychain || exit 1 ;
#fi

#buidl default or specific target

XCODE_TARGET="ExampleApp"
if [ $1 ]; then
XCODE_TARGET=$1
fi

export HOCKEY_API_TOKEN="b6a9d39a0955422096932d4a84d0fd74"

INFO_PLIST_PATH="${WORKSPACE}/ZenPay/${XCODE_TARGET}-Info.plist"

MARKETING_VERSION=`/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$INFO_PLIST_PATH"`
BUNDLE_VERSION=${BUILD_NUMBER}
export BUNDLE_IDENTIFIER=`/usr/libexec/PlistBuddy -c "Print CFBundleIdentifier" "$INFO_PLIST_PATH"`

if [ $2 ]; then
  export HOCKEY_APP_TOKEN=$2
fi

GIT_COMMIT_LOG=`git log -n1 --oneline | sed "s/'//g"`

# Fill ZenPayHockeyConstants.h with current HOCKEY_APP_TOKEN
echo "#define kHockeyTokenString @\"$HOCKEY_APP_TOKEN\"" > "${WORKSPACE}/ZenPay/Application/ZenPayHockeyConstants.h" || exit 1 ;

# Update Info-Plist
/usr/libexec/PlistBuddy -c "Set CFBundleVersion ${BUNDLE_VERSION}" "${INFO_PLIST_PATH}" || exit 1 ;
/usr/libexec/PlistBuddy -c "Set CFBundleDisplayName ${BUNDLE_DISPLAY_NAME}" "${INFO_PLIST_PATH}" || exit 1 ;

# Update Version in Settings.bundle
/usr/libexec/PlistBuddy -c "Set PreferenceSpecifiers:1:Value $MARKETING_VERSION" "${SETTINGS_BUNDLE_PATH}" || exit 1 ;
/usr/libexec/PlistBuddy -c "Set PreferenceSpecifiers:1:DefaultValue $MARKETING_VERSION" "${SETTINGS_BUNDLE_PATH}" || exit 1 ;

# Update BundleIdentifier in Settings.bundle
/usr/libexec/PlistBuddy -c "Set PreferenceSpecifiers:2:Value $BUNDLE_IDENTIFIER" "${SETTINGS_BUNDLE_PATH}" || exit 1 ;
/usr/libexec/PlistBuddy -c "Set PreferenceSpecifiers:2:DefaultValue $BUNDLE_IDENTIFIER" "${SETTINGS_BUNDLE_PATH}" || exit 1 ;

# Update Hudson-ID in Settings.bundle
/usr/libexec/PlistBuddy -c "Set PreferenceSpecifiers:3:Value $BUILD_ID" "${SETTINGS_BUNDLE_PATH}" || exit 1 ;
/usr/libexec/PlistBuddy -c "Set PreferenceSpecifiers:3:DefaultValue $BUILD_ID" "${SETTINGS_BUNDLE_PATH}" || exit 1 ;

# Update Git-Log in Settings.bundle
/usr/libexec/PlistBuddy -c "Set PreferenceSpecifiers:4:Value $GIT_COMMIT_LOG" "${SETTINGS_BUNDLE_PATH}" || exit 1 ;
/usr/libexec/PlistBuddy -c "Set PreferenceSpecifiers:4:DefaultValue $GIT_COMMIT_LOG" "${SETTINGS_BUNDLE_PATH}" || exit 1 ;


# Cleanup simulator and derived data dirs
rm -rf ~/Library/Application\ Support/iPhone\ Simulator/*
rm -rf ~/Library/Developer/Xcode/DerivedData/*


# build and release ipa to hockey server
if [ $HOCKEY_APP_TOKEN ]; then

	xcodebuild VALID_ARCHS="armv7 arm64" ARCHS="armv7 arm64" ONLY_ACTIVE_ARCH=NO -workspace "PaylevenInAppSDK.xcworkspace" -scheme "${XCODE_ADHOC_SCHEME}" -sdk "iphoneos8.1" -configuration "AdHoc" clean build || exit 1 ;

fi