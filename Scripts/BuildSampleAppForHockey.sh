set -e

if [ -z "$1" ]
then
echo "No Hockey App Token supplied"
else
echo "Provided Hockey App Token "$1
fi

PROJECT_ROOT="`pwd`"
BUILD_ROOT="$PROJECT_ROOT/build"
PRODUCT_NAME="PaylevenInAppSDKExample"

rm -rf "$BUILD_ROOT"

security unlock-keychain -p "builderpayleven" ~/Library/Keychains/login.keychain

xcodebuild -workspace PaylevenInAppSDK.xcworkspace -scheme InAppSDKExample -configuration Release -sdk iphoneos -destination 'generic/platform=iOS' archive -archivePath $BUILD_ROOT/$PRODUCT_NAME

xcodebuild -workspace PaylevenInAppSDK.xcworkspace -scheme BundleFramework -configuration Release -sdk iphoneos -destination 'generic/platform=iOS' archive -archivePath $BUILD_ROOT/$PRODUCT_NAME

xcodebuild -workspace PaylevenInAppSDK.xcworkspace -scheme PaylevenInAppSDK -configuration Release -sdk iphoneos -destination 'generic/platform=iOS' archive -archivePath $BUILD_ROOT/$PRODUCT_NAME

xcodebuild -exportArchive -exportFormat IPA -archivePath $BUILD_ROOT/$PRODUCT_NAME.xcarchive -exportPath $BUILD_ROOT/$PRODUCT_NAME -exportProvisioningProfile "InApp SDK ExampleApp InHouse Profile"

# Upload to HockeyApp
cd "$BUILD_ROOT/$PRODUCT_NAME.xcarchive/dSYMs"
zip -r ${PRODUCT_NAME}.app.dSYM.zip ${PRODUCT_NAME}.app.dSYM
mv ${PRODUCT_NAME}.app.dSYM.zip "$BUILD_ROOT"
cd "$BUILD_ROOT"
curl \
-F "status=2" \
-F "notify=0" \
-F "ipa=@${PRODUCT_NAME}.ipa" \
-F "dsym=@${PRODUCT_NAME}.app.dSYM.zip" \
-H "X-HockeyAppToken:"$1 \
https://rink.hockeyapp.net/api/2/apps/upload