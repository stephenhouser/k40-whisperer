#!/bin/bash
# ---------------------------------------------------------------------
# This file executes the build command for the OS X Application bundle.
# It is here because I am lazy
# ---------------------------------------------------------------------
PYENV_PYTHON_VERSION=3.9.1

# Call getopt to validate the provided input. 
VENV_DIR=build_env.$$
VERBOSE=false
MAKE_DISK=false
KEEP_VENV=false
SETUP_ENVIRONMENT=false
while getopts "hvdesp" OPTION; do
	case "$OPTION" in
		h)  echo "Options:"
			echo "\t-h Print help (this)"
			echo "\t-v Verbose output"
			echo "\t-e Keep Python virtual environment (don't delete)"
			echo "\t-p Use py2app to build instead of PyInstaller"
			echo "\t-s Setup dev environment"
			echo "\t-d Make disk image (.dmg)"
			exit 0
			;;
		v) 	VERBOSE=true
			;;
		d) 	MAKE_DISK=true
			;;
		e)  KEEP_VENV=true
			;;
		s)  SETUP_ENVIRONMENT=true
			;;
		*)  echo "Incorrect option provided"
			exit 1
			;;
    esac
done

# Prints the provided error message and then exits with an error code
function fail {
    CODE="${1:-1}"
    MESSAGE="${2:-Unknown error}"
    echo ""
    echo -e "\033[31;1;4m*** ERROR: $MESSAGE ***\033[0m"
    echo ""
    exit $CODE
}


# Exits with error code/message if the previous command failed
function check_failure {
    CODE="$?"
    MESSAGE="$1"
    [[ $CODE == 0 ]] || fail "$CODE" "$MESSAGE" 
}

# *** Not Tested! ***
if [ "$SETUP_ENVIRONMENT" = true ]
then
	# Install HomeBrew (only if you don't have it)
	/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
	check_failure "Failed to install homebrew"

	# Install Dependencies
	brew cask install xquartz
	brew cask install inkscape
	brew install libusb
	check_failure "Failed to install libusb"

	# Install python environments...
	brew install pyenv
	check_failure "Failed to install pyenv"
	eval "$(pyenv init -)"

	# Install Python with pyenv and set it as the default Python
	PYTHON_CONFIGURE_OPTS="--enable-framework" pyenv install ${PYENV_PYTHON_VERSION}
	check_failure "Failed to install Python ${PYENV_PYTHON_VERSION}"
fi

echo "Validate environment..."

# Select Python to use
#pyenv local ${PYENV_PYTHON_VERSION} && pyenv rehash
#check_failure "Failed to setup Python ${PYENV_PYTHON_VERSION}"

# Use the specific python version from pyenv so we don't get hung up on the
# system python or a user's own custom environment.
PYTHON=$(command -v python3)
PY_VER=$($PYTHON --version 2>&1 | awk '{ print $2 }')
[[ ${PY_VER} == "${PYTHON_VERSION}" ]] || fail 1 "Packaging REQUIRES Python ${PYTHON_VERSION}. Please rerun with -s to setup build environment"

# Clean up any previous build work
echo "Remove old builds..."
rm -rf ./build ./dist *.pyc ./__pycache__

# Set up and activate virtual environment for dependencies
echo "Setup Python Virtual Environment..."
python3 -m venv "${VENV_DIR}"
check_failure "Failed to initialize python venv"

source "./${VENV_DIR}/bin/activate"
check_failure "Failed to activate python venv"

# Unset our python variable now that we are running inside of the virtualenv
# and can just use `python` directly
PYTHON=

# Install requirements
echo "Install Dependencies..."
pip3 install -r requirements.txt
check_failure "Failed to install python requirements"

echo "Build macOS Application Bundle..."

# Get version from main source file.
VERSION=$(grep "^version " k40_whisperer.py | grep -Eo "[\.0-9]+")

python3 -OO -m PyInstaller -y --clean k40_whisperer.spec
check_failure "Failed to package k40_whisperer bundle"

# Remove temporary binary
rm -rf dist/k40_whisperer

echo "Copy support files to dist..."
cp k40_whisperer_test.svg Change_Log.txt gpl-3.0.txt README_MacOS.md dist

# Clean up the build directory when we are done.
echo "Clean up build artifacts..."
rm -rf build

# Remove virtual environment
if [ "$KEEP_VENV" = false ]
then
	echo "Remove Python virtual environment..."
	deactivate
	rm -rf python_venv
fi

# Buid a new disk image
if [ "$MAKE_DISK" = true ]
then
	echo "Build macOS Disk Image..."
	VOLNAME=K40-Whisperer-${VERSION}
	rm ${VOLNAME}.dmg
	hdiutil create -fs HFS+ -volname ${VOLNAME} -srcfolder ./dist ./${VOLNAME}.dmg
	check_failure "Failed to build k40_whisperer dmg"
fi

echo "Done."