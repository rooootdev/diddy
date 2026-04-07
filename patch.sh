#!/bin/bash
set -e

DMG_NAME="DeveloperDiskImageModified.dmg"
DDI_DIR="/Library/Developer/DeveloperDiskImages/iOS_DDI/Restore"
MOUNT_POINT="/Volumes/DeveloperDiskImage"
PLIST_FILE="com.apple.debugserver.plist"

BOLD='\033[1m'
NC='\033[0m'

echo "available ddis:"
mapfile -t ddies < <(ls "$DDI_DIR"/*.dmg 2>/dev/null | sort -V)
for i in "${!ddies[@]}"; do
    basename_ddi=$(basename "${ddies[$i]}")
    echo -e "$((i+1)). ${BOLD}${basename_ddi}${NC}"
done

read -p "select ddi (1-${#ddies[@]}): " choice
SOURCE_DMG="${ddies[$((choice-1))]}"

echo "selected: $(basename "$SOURCE_DMG")"

rm -f "$DMG_NAME"
hdiutil convert -format UDRW -o "$DMG_NAME" "$SOURCE_DMG"
hdiutil attach -owners on "$DMG_NAME"

cp "$PLIST_FILE" "$MOUNT_POINT/Library/LaunchDaemons/"
chown root:wheel "$MOUNT_POINT/Library/LaunchDaemons/$PLIST_FILE"
chmod 644 "$MOUNT_POINT/Library/LaunchDaemons/$PLIST_FILE"

hdiutil detach "$MOUNT_POINT"
openssl dgst -sign key.pem -out "$DMG_NAME.signature" -binary -sha1 "$DMG_NAME"

echo "${BOLD}done!${NC}"
