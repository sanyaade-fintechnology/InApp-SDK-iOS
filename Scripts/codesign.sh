#!/bin/sh

set -ex


# HOCKEY_APP_TOKEN = "fa4d75f90d230a773190b9fa44ee1330"
# HOCKEY_API_TOKEN = "b6a9d39a0955422096932d4a84d0fd74"

if [ $HOCKEY_APP_TOKEN ]; then

# constants
adHocCertificate="iPhone Distribution: Jade 1360. GmbH"

provisioningProfilePath=""

case $BUNDLE_IDENTIFIER in
  "com.payleven.Payment.InAppSDKExample" )
    provisioningProfilePath="${PROJECT_DIR}/Scripts/InAppSDKExampleInHouse.mobileprovision" 
    ;;
esac



if [ ! -f "$provisioningProfilePath" ]; then
  echo "ERROR => Provisioning \"$provisioningProfilePath\" does not exist"
  exit 1;
fi

XCODE_TARGET="InAppSDKExample"
if [ $1 ]; then
XCODE_TARGET=$1
fi

appFile="${XCODE_TARGET}.app"
ipaFile="${XCODE_TARGET}.ipa"
dsymFile="${XCODE_TARGET}.app.dSYM"
dsymZipFile="${XCODE_TARGET}.app.dSYM.zip"
releaseNotes=`git log -n1 --oneline`

if [ ! -d "${CONFIGURATION_BUILD_DIR}/$appFile" ]; then
  echo "ERROR => \"${CONFIGURATION_BUILD_DIR}/$appFile\" does not exist"
  exit 1;
fi

echo "Configuration Build Dir => \"${CONFIGURATION_BUILD_DIR}/$appFile\" does not exist"
# sign app
/usr/bin/xcrun -verbose -sdk iphoneos PackageApplication "${CONFIGURATION_BUILD_DIR}/$appFile" -o "${CONFIGURATION_BUILD_DIR}/$ipaFile" --sign "$adHocCertificate" --embed "$provisioningProfilePath" || exit 1

# go to binary dir
cd "${CONFIGURATION_BUILD_DIR}" || exit 1

# zip dSYM file
zip -q -r -9 "$dsymZipFile" "$dsymFile" || exit 1

# submit ipa and dSYM to hockey
CURL_APP_RESPONSE=`curl --silent --show-error -F "status=2" -F "notify=1" -F "notes_type=1" -F "notes=$releaseNotes" -F "ipa=@$ipaFile" -F "dsym=@$dsymZipFile" -H "X-HockeyAppToken: ${HOCKEY_API_TOKEN}" https://rink.hockeyapp.net/api/2/apps || exit 1`
if [ `echo $CURL_APP_RESPONSE | grep -o error` ]; then
  echo $CURL_APP_RESPONSE
  exit 1;
fi

# submit mobileprovision to hockey
CURL_PROV_RESPONSE=`curl --silent --show-error -F "mobileprovision=@$provisioningProfilePath" -H "X-HockeyAppToken: ${HOCKEY_API_TOKEN}" https://rink.hockeyapp.net/api/2/apps/${HOCKEY_APP_TOKEN}/provisioning_profiles || exit 1`
if [ `echo $CURL_PROV_RESPONSE | grep -o error` ]; then
  echo $CURL_PROV_RESPONSE
  exit 1;
fi

# remove old versions from hockey
CURL_REMOVE_RESPONSE=`curl --silent --show-error -F "keep=10" -H "X-HockeyAppToken: ${HOCKEY_API_TOKEN}" https://rink.hockeyapp.net/api/2/apps/${HOCKEY_APP_TOKEN}/app_versions/delete`
if [ `echo $CURL_REMOVE_RESPONSE | grep -o error` ]; then
  echo $CURL_REMOVE_RESPONSE
  exit 1;
fi

exit 0

fi

echo "INFO => HOCKEY_APP_TOKEN missing. HOCKEY_APP_TOKEN will be set in Hudson-Environment"

exit 0