#!/bin/sh
#
# Copyright Sveinung Kval Bakken 2012
# sveinung.bakken@gmail.com
#
# Please keep this comment, but copy and modify anything below as you want.
# source: https://github.com/sveinungkb/ios-ota-buddy

PLIST_BUDDY="/usr/libexec/PlistBuddy -c"

provisioning()
{
	if [ -z "$2" ]; then
		unzip -p "$1" "**.mobileprovision"
	else
		unzip -p "$1" "**.mobileprovision" > $2
		echo $"Extracted the .mobileprovison in $1 to: $2"
	fi
}

urlencode()
{
	echo $1 | python -c 'import sys,urllib;print urllib.quote_plus(sys.stdin.read().strip())'
}

otaplist()
{
	if [ -z "$2" ]; then
		echo "Missing URL parameter"
		printusage
		exit 1
	elif [ -z "$3" ]; then
		echo "Missing output file parameter"
		printusage
		exit 1
	else
		# Extract IPA-files
		APP_PLIST=temp.plist
		OTA_PLIST=$3
		echo "IPA PATH:$1"
		echo "OTA_PLIST:$OTA_PLIST"

		unzip -p "$1" "**.app/Info.plist" > $APP_PLIST

		#Read contents
		BUNDLE_IDENTIFIER=$($PLIST_BUDDY "Print CFBundleIdentifier" $APP_PLIST)
		BUNDLE_NAME=$($PLIST_BUDDY "Print CFBundleName" $APP_PLIST)

		# Clean up
		#rm $APP_PLIST

		# Create .plist
		$PLIST_BUDDY "Add :items array" $OTA_PLIST
		$PLIST_BUDDY "Add :items:0:metadata dict" $OTA_PLIST
		$PLIST_BUDDY "Add :items:0:metadata:bundle-identifier string $BUNDLE_IDENTIFIER" $OTA_PLIST
		$PLIST_BUDDY "Add :items:0:metadata:title string $BUNDLE_NAME" $OTA_PLIST
		$PLIST_BUDDY "Add :items:0:metadata:kind string software" $OTA_PLIST
		$PLIST_BUDDY "Add :items:0:assets array" $OTA_PLIST
		$PLIST_BUDDY "Add :items:0:assets:0 dict" $OTA_PLIST
		$PLIST_BUDDY "Add :items:0:assets:0:kind string software-package" $OTA_PLIST
		$PLIST_BUDDY "Add :items:0:assets:0:url string $2" $OTA_PLIST

		echo "Created $OTA_PLIST with values:"
		echo "Bundle identifier: $BUNDLE_IDENTIFIER"
		echo "Title:             $BUNDLE_NAME"
		echo "URL to app:        $2"
	fi
}

otaplists()
{
	echo "Cleaning up old .plists"
	rm -f *.plist
	for ipa in *.ipa; do
		name="${ipa%.*}"
		url="${1}/${ipa}"
		file="${name}.plist"
		otaplist $ipa $url $file
		itms "${1}/${file}"
	done
}

itms()
{
	if [ -z $1 ]; then
		echo "Missing URL to .plist"
		printusage
		exit 1
	else
		echo "It can be downloaded with this link:"
		echo "itms-services://?action=download-manifest&url=$(urlencode $1)"
		echo "Example HTML anchor:"
		echo "<a href=\"itms-services://?action=download-manifest&url=$(urlencode $1)\">Download my application</a>"
	fi
}

printusage()
{
	echo "Usage:"
	echo $"$0 provisioning: Will extract the embedded provisioning profile from your application.ipa"
	echo $" $0 provisioning file.ipa, will print the provisioning profile to STDOUT, pipe it where you want (can be used to download)"
	echo $" $0 provisioning file.ipa name.mobileprovision, will extract the provisioning profile to name.mobileprovision"
	echo ""
	echo $"$0 plist: Will generate the .plist required for OTA-distribution"
	echo $" $0 plist file.ipa http://domain.com/path/distribution/file.ipa application.plist"
	echo $"$0 plists: Same as above, but will process the entire directory. Provide common URL prefix:"
	echo $" $0 plists http://domain.com/path/distribution/"
	echo ""
	echo $"$0 itms: Will generate an itms-services link that can be used to download your application."
	echo $" $0 itms http://domain.com/path/distribution/application.plist"
	exit 1
}

if [ -z "$2" ]; then
printusage
fi

case "$1" in
		provisioning)
			provisioning "$2" "$3"
			;;
		plist)
			otaplist "$2" "$3" "$4"
			;;
		plists)
			otaplists "$2"
			;;
		itms)
			itms "$2"
			;;
		*)
			printusage

esac
