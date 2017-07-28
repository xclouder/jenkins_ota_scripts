#环境变量
WORKSPACE=`pwd`
BUILD_URL="http://ci.ezfun.cn/otatest/15/"
echo "BUILD_DIR :$BUILD_DIR"

BUILD_DIR="build"
OTA_WEB_URL="http://ota.ezfun.cn"

#以下是真实打包时的脚本
rm -rf build
mkdir -p build

#Simulate build
cp OTATest.ipa $BUILD_DIR/OTATest.ipa

sh ./ota.sh ${WORKSPACE}/${BUILD_DIR} ${BUILD_URL}artifact/$BUILD_DIR/ $OTA_WEB_URL