#!/bin/bash
set -e

DMG_NAME="DeveloperDiskImageModified.dmg"
DEVICE_SUPPORT="/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/DeviceSupport"
MOUNT_POINT="/Volumes/DeveloperDiskImage"
PLIST_FILE="com.apple.debugserver.plist"

BOLD='\033[1m'
NC='\033[0m'

echo "available ddis:"
versions=($(ls "$DEVICE_SUPPORT" | sort -V))
for i in "${!versions[@]}"; do
    echo -e "$((i+1)). ${BOLD}iOS ${versions[$i]}${NC}"
done

read -p "select ddi (1-${#versions[@]}): " choice
selected="${versions[$((choice-1))]}"
SOURCE_DMG="$DEVICE_SUPPORT/$selected/DeveloperDiskImage.dmg"

echo "selected: $selected"

rm -f "$DMG_NAME"
hdiutil convert -format UDRW -o "$DMG_NAME" "$SOURCE_DMG"
hdiutil attach -owners on "$DMG_NAME"

cp "$PLIST_FILE" "$MOUNT_POINT/Library/LaunchDaemons/"
chown root:wheel "$MOUNT_POINT/Library/LaunchDaemons/$PLIST_FILE"
chmod 644 "$MOUNT_POINT/Library/LaunchDaemons/$PLIST_FILE"

hdiutil detach "$MOUNT_POINT"
openssl dgst -sign key.pem -out "$DMG_NAME.signature" -binary -sha1 "$DMG_NAME"

echo "${BOLD}done!${NC}"
