#!/bin/bash
# ---------------------------------------------------------------------
# This file executes the build command for the OS X Application bundle.
# It is here because I am lazy
# ---------------------------------------------------------------------

echo "Validate environment..."

# Get version from main source file.
VERSION=$(grep "^version " k40_whisperer.py | grep -Eo "[\.0-9]+")

# Precheck for 'restricted' permissions on system Python. See below
# Build will fail if using the system Python and it's restricted
if [ "$(which python)" == "/usr/bin/python" ]
	then
	if ls -dlO /System/Library/Frameworks/Python.framework | grep 'restricted'> /dev/null
	then
		echo -e "\033[1;31m"
		echo "  *** *** *** *** *** *** *** *** *** *** *** *** ***"
		echo ""
		echo "  ️You are using the macOS system Python"
		echo "  and it has the 'restricted' flag set."
		echo ""
		echo "  This causes application packaging to fail."
		echo "  Please read README.md for details on how to "
		echo "  resolve this problem."
		echo ""
		echo "  A better choice is to use a 'homebrew' installed"
		echo "  Python. Please see the README.md for more info."
		echo ""
		echo "  *** *** *** *** *** *** *** *** *** *** *** *** ***"
		echo -e "\033[0m"
		exit 1
	fi
fi

# Clean up any previous build work
echo "Remove old builds..."
rm -rf ./build ./dist *.pyc

# Set up and activate virtual environment for dependencies
echo "Setup Python Virtual Environment..."
PY_VER=$(python --version 2>&1)
if [[ $PY_VER == *"2.7"* ]]
then
	pip install virtualenv py2app==0.16
	virtualenv python_venv
else
	python -m venv python_venv
fi

source ./python_venv/bin/activate

# Install requirements
echo "Install Dependencies..."
pip install -r requirements.txt

# Use system (OSX) python and py2app. Do use not homebrew or another version. 
# This ensures things will work on other people's computers who might not
# have great tools like homebrew installed.
#
# There's a permission problem since 10.10 with the default system py2app:
# http://stackoverflow.com/questions/33197412/py2app-operation-not-permitted
# https://forums.developer.apple.com/thread/6987
#
# Solution:
#   - Boot in recovery mode
#   - csrutil disable
#   - Reboot
#   - sudo chflags -R norestricted /System/Library/Frameworks/Python.framework
#   - Reboot into recovery mode
#   - csrutil enable
#   - Reboot and build...
# You need to do that before this will work!
echo "Build macOS Application Bundle..."
python py2app_setup.py py2app --packages=PIL

echo "Build macOS Disk Image..."
hdiutil create -fs HFS+ -volname K40-Whisperer-${VERSION} -srcfolder ./dist ./K40-Whisperer-${VERSION}.dmg

# Clean up the build directory when we are done.
echo "Clean up and deactivate Python virtual environment..."
rm -rf build

# Remove virtual environment
deactivate
rm -rf python_venv

echo "Done."