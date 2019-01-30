#!/bin/bash
#
# Script to copy changed files from Scorch's updated K40 Whisperer
# to staging directory for creating macOS package.
#
# 1. Copy over new files from directory specified on command line
# 2. Apply macOS patches from `macOS.patch` and update version numbers
# 3. Run the build script
# 4. Create a disk image (.dmg) for release
#
MD5="md5 -q"
files="gpl-3.0.txt Change_Log.txt README_Linux.txt README_MacOS.md \
		CC.png LL.png LR.png UL.png UR.png up.png down.png left.png right.png \
		scorchworks.ico emblem emblem64 build_exe.bat \
		bezmisc.py cspsubdiv.py cubicsuperpath.py dxf.py ecoords.py egv.py \
		ffgeom.py g_code_library.py inkex.py interpolate.py nano_library.py \
		py2exe_setup.py requirements.txt  simplepath.py \
		simplestyle.py simpletransform.py svg_reader.py windowsinhibitor.py"

UPDATE_DIR=$1
if [ ! -f ${UPDATE_DIR}/k40_whisperer.py ] ; then
	echo "K40 Whisperer does not exist at \$1 = ${UPDATE_DIR}!"
	exit
fi

NEW_APP=$(ls -1 ${UPDATE_DIR}/k40_whisperer.py)
VERSION=$(grep "^version " ${UPDATE_DIR}/k40_whisperer.py | grep -Eo "[\.0-9]+")
#VERSION=$(echo ${FILE_VERSION}|cut -c1).$(echo ${FILE_VERSION}|cut -c2-)

echo "Updating to version $VERSION"

# Copy f-engrave Python script
echo "Copy new version of K40 Whisperer..."
echo "    `basename ${NEW_APP}`"
cp "${NEW_APP}" "k40_whisperer.py"

# Copy over changed supporting files
echo "Copy supporting files..."
for i in $files
do
	curd5=`${MD5} "${i}"`
	newd5=`${MD5} "${UPDATE_DIR}/${i}"`
	if [ "$curd5" != "$newd5" ]; then
		echo "    $i"
		cp "${UPDATE_DIR}/${i}" "$i"
	fi
done

# Apply macOS patches to f-engrave.py
echo "Patch k40_whisperer.py for macOS..."
patch -p0 -i macOS.patch

# Update version in setup script
echo "Update version number in setup script..."
sed -i.orig "s/app_version = .*/app_version = \"${VERSION}\"/" py2app_setup.py

echo "Convert emblem to .icns..."
sips -s format icns emblem --out emblem.icns

# Build macOS application
echo "Build macOS Application..."
./build_macOS.sh

# Make macOS Disk Image (.dmg) for distribution
echo "Build macOS Disk Image..."
rm ./K40-Whisperer-${VERSION}.dmg
hdiutil create -fs HFS+ -volname K40-Whisperer-${VERSION} -srcfolder ./dist ./K40-Whisperer-${VERSION}.dmg

