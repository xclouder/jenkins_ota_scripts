BUILD_PATH=$1
BUILD_URL=$2
OTA_WEB_URL=$3
QR_FILE_NAME=install.png

IPA=`ls $BUILD_PATH | grep ipa`
PLIST_FILE="install.plist"

echo "BUILD_PATH:$BUILD_PATH"
echo "OTA_WEB_URL:$OTA_WEB_URL"
echo "IPA:$IPA"
echo "PLIST_FILE:$PLIST_FILE"

urlencode()
{
	echo $1 | python -c 'import sys,urllib;print urllib.quote_plus(sys.stdin.read().strip())'
}

chmod 755 ./otabuddy.sh
./otabuddy.sh plist $BUILD_PATH/$IPA ${BUILD_URL}$IPA $BUILD_PATH/$PLIST_FILE

OTA_DOWNLOAD_URL="${OTA_WEB_URL}?package_url=${BUILD_URL}$PLIST_FILE&qr_src=${BUILD_URL}${QR_FILE_NAME}"
echo "QR_URL:"$OTA_DOWNLOAD_URL
OTA_DOWNLOAD_URL_ENCODE="${OTA_WEB_URL}?package_url=$(urlencode ${BUILD_URL}$PLIST_FILE)&qr_src=$(urlencode ${BUILD_URL}/${QR_FILE_NAME})"
echo "QR_URL_ENCODED:"$OTA_DOWNLOAD_URL_ENCODE

brew install qrencode
qrencode -o $BUILD_PATH/$QR_FILE_NAME $OTA_DOWNLOAD_URL_ENCODE