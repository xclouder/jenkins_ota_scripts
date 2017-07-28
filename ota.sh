# OTA_SERVER_URL="https://ci.ezfun.cn"
OTA_SERVER_URL=$1
echo $OTA_SERVER_URL
IPA=`ls | grep ipa`
PLIST_FILE="install.plist"

cd .

chmod 755 ./otabuddy.sh
./otabuddy.sh plist $IPA ${OTA_SERVER_URL}/$IPA $PLIST_FILE

#修改otabuddy.sh 获取INSTALL_URL
INSTALL_URL=`./otabuddy.sh itms ${OTA_SERVER_URL}/${PLIST_FILE}`


echo $INSTALL_URL > install.htm


brew install qrencode
qrencode -o install.png $INSTALL_URL