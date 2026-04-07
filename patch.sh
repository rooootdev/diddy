#!/bin/bash
set -e

DMG_NAME="DeveloperDiskImageModified.dmg"
SOURCE_DMG="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport/16.1/DeveloperDiskImage.dmg"
MOUNT_POINT="/Volumes/DeveloperDiskImage"
LAUNCH_DAEMONS_DIR="$MOUNT_POINT/Library/LaunchDaemons"
PLIST_FILE="com.apple.debugserver.plist"

rm -f "$DMG_NAME"

hdiutil convert -format UDRW -o "$DMG_NAME" "$SOURCE_DMG"
hdiutil attach -owners on "$DMG_NAME"

cp "$PLIST_FILE" "$LAUNCH_DAEMONS_DIR/"
chown root:wheel "$LAUNCH_DAEMONS_DIR/$PLIST_FILE"
chmod 644 "$LAUNCH_DAEMONS_DIR/$PLIST_FILE"

hdiutil detach "$MOUNT_POINT"

openssl dgst -sign key.pem -out DeveloperDiskImageModified.dmg.signature -binary -sha1 DeveloperDiskImageModified.dmg
