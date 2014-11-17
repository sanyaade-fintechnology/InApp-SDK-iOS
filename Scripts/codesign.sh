#!/bin/sh

set -ex

if [ $HOCKEY_APP_TOKEN ]; then

# constants
adHocCertificate="iPhone Distribution: Jade 1360. GmbH"

provisioningProfilePath=""

case $BUNDLE_IDENTIFIER in
  "com.payleven.Payment.dev" )
    provisioningProfilePath="${PROJECT_DIR}/mobileprovision/Payment_Dev.mobileprovision" 
    ;;
    "com.payleven.Payment.computop" )
    provisioningProfilePath="${PROJECT_DIR}/mobileprovision/Payment_Computop.mobileprovision"
    ;;
  "com.payleven.Payment.stable" )
    provisioningProfilePath="${PROJECT_DIR}/mobileprovision/Payment_Stable.mobileprovision" 
    ;;
  "com.payleven.Payment.test" )
    provisioningProfilePath="${PROJECT_DIR}/mobileprovision/Payment_Test.mobileprovision" 
    ;;
  "com.payleven.Payment.beta" )
    provisioningProfilePath="${PROJECT_DIR}/mobileprovision/Payment_Beta.mobileprovision" 
    ;;
  "com.payleven.Payment.iPad.dev" )
    provisioningProfilePath="${PROJECT_DIR}/mobileprovision/Payment_iPad_Dev.mobileprovision"
    ;;
  "com.payleven.Payment.iPad.computop" )
    provisioningProfilePath="${PROJECT_DIR}/mobileprovision/Payment_iPad_Computop.mobileprovision"
    ;;
  "com.payleven.Payment.iPad.stable" )
    provisioningProfilePath="${PROJECT_DIR}/mobileprovision/Payment_iPad_Stable.mobileprovision"
    ;;
  "com.payleven.Payment.iPad.test" )
    provisioningProfilePath="${PROJECT_DIR}/mobileprovision/Payment_iPad_Test.mobileprovision"
    ;;
  "com.payleven.Payment.iPad.beta" )
    provisioningProfilePath="${PROJECT_DIR}/mobileprovision/Payment_iPad_Beta.mobileprovision"
    ;;
  "com.payleven.Payment.Backend" )
    provisioningProfilePath="${PROJECT_DIR}/mobileprovision/Payment_Backend.mobileprovision"
    ;;
  "com.payleven.Payment" )
    provisioningProfilePath="${PROJECT_DIR}/mobileprovision/Payment_Distribution.mobileprovision" 
    ;;
  "com.payleven.Payment.beta.internal" )
    provisioningProfilePath="${PROJECT_DIR}/mobileprovision/Payment_Beta_Internal.mobileprovision"
    ;;
  "com.payleven.Payment.iPad.beta.internal" )
    provisioningProfilePath="${PROJECT_DIR}/mobileprovision/Payment_iPad_Beta_internal.mobileprovision"
    ;;
  "com.payleven.Payment.demo" )
    provisioningProfilePath="${PROJECT_DIR}/mobileprovision/Payleven_Demo.mobileprovision"
    ;;
  "com.payleven.Payment.ipad.demo" )
    provisioningProfilePath="${PROJECT_DIR}/mobileprovision/Payleven_iPad_Demo.mobileprovision"
    ;;
  "com.payleven.Payment.kif" )
    provisioningProfilePath="${PROJECT_DIR}/mobileprovision/Payment_Kif.mobileprovision"
    ;;
  "com.payleven.Payment.iPad.kif" )
    provisioningProfilePath="${PROJECT_DIR}/mobileprovision/Payment_iPad_Kif.mobileprovision"
    ;;
  "com.payleven.payment.Playground" )
    provisioningProfilePath="${PROJECT_DIR}/mobileprovision/Playground.mobileprovision"
    ;;
  "com.payleven.Payment.stable.inv" )
    provisioningProfilePath="${PROJECT_DIR}/mobileprovision/Payment_Inv.mobileprovision"
    ;;
  "com.payleven.Payment.iPad.stable.inv" )
    provisioningProfilePath="${PROJECT_DIR}/mobileprovision/Payment_iPad_Inv.mobileprovision"
    ;;
  "com.payleven.Payment.austria" )
    provisioningProfilePath="${PROJECT_DIR}/mobileprovision/Payment_Austria.mobileprovision" 
    ;;
  "com.payleven.Payment.iPad.austria" )
    provisioningProfilePath="${PROJECT_DIR}/mobileprovision/Payment_iPad_Austria.mobileprovision"
    ;;    
  "com.payleven.Payment.newadyen" )
    provisioningProfilePath="${PROJECT_DIR}/mobileprovision/Payment_Newadyen.mobileprovision" 
    ;;
  "com.payleven.Payment.iPad.newadyen" )
    provisioningProfilePath="${PROJECT_DIR}/mobileprovision/Payment_iPad_Newadyen.mobileprovision"
    ;;
  "com.payleven.CardDataCaptureApp" )
    provisioningProfilePath="${PROJECT_DIR}/mobileprovision/CardData_InHouse.mobileprovision"
    ;;  
esac



if [ ! -f "$provisioningProfilePath" ]; then
  echo "ERROR => Provisioning \"$provisioningProfilePath\" does not exist"
  exit 1;
fi

XCODE_TARGET="payleven"
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