# K40 Whisperer

[Download](https://github.com/stephenhouser/k40-whisperer/releases) the latest macOS package.

Packaging of Scorchworks K40 Whisperer as an OSX Application.

> K40 Whisperer is an alternative to the the Laser Draw (LaserDRW) program that comes with the cheap Chinese laser cutters available on E-Bay and Amazon. K40 Whisperer reads SVG and DXF files,interprets the data and sends commands to the K40 controller to move the laser head and control the laser accordingly. K40 Whisperer does not require a USB key (dongle) to function.

![K40 Whisperer Main](K40_Whisperer_Main.png?raw=true)

The official K40 Whisperer and instructions are at Scorchworks:

> http://www.scorchworks.com/K40whisperer/k40whisperer.html

This fork is to add packaging and minor fixes to work on macOS systems, creating a clickable application that can be installed on any macOS system. This eliminates having to run K40 Whisperer from a Terminal prompt.

## Running The Packaged Application

K40 Whisperer requires a few dependencies that are not installed as part of the application bundle. You will need to install these yourself to have a functioning application.

* [Homebrew](https://brew.sh/) Not required but **strongly recomended**
* [libusb](https://libusb.info) for access to the USB port(s)
* [inkscape](https://inkscape.org) for drawing and rasterization

These dependencies are best installed with [Homebrew](https://brew.sh/) in a `Terminal` window as follows. This only needs to be done once on your system.

```
# Install HomeBrew (only if you don't have it)
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install Dependencies
brew install libusb
brew cask install xquartz
brew cask install inkscape
```

You need not read any further in this document. You should be able to run K40 Whisperer.

## macOS Build/Update Process Overview

This fork adds the following files to Scorch's work

* `build-macOS.sh` -- bash build script to build and create application bundle.
* `update-macOS.sh` -- bash script to patch a new version of K40 Whisperer and bundle it.
* `k40_whisperer.spec` -- application specification for PyInstaller.
* `emblem.icns` -- Icons for macOS application bundle (made with `sips`)
* `macOS.patch` -- tweaks to Scorch's source for macOS

When a new source package is released by Scorch, the general update process is.

1. Download and extract the new source code
2. Check this repository out into a working directory
3. Run `update_macOS.sh` with the address of the latest source archive
4. *poof* out comes a disk image (`.dmg` file) with the new bundled version.
5. Don't forget to test it!

Most of this is handled by the `update_macOS.sh` script. Here's my process... and my likely future copy and paste.

```
# Get this repository
git clone https://github.com/stephenhouser/k40_whisperer.git
cd k40_whisperer

# Download, apply patches, build the application
./update_macOS.sh -u https://www.scorchworks.com/K40whisperer/K40_Whisperer-0.56_src.zip

# Test/Fix/Test...(needs some work)
...
open ./dist/K40\ Whisperer v0.56.app
...

# Move newly generated patch file into place
mv macOS-0.56.patch macOS.patch

# Commit and push back to GitHub
git commit -a -m"Update to v0.56"
git tag v0.56
git push --follow-tags
```

## macOS Build/Update Process Details

*** These directions may be outdated, please check the `build-macOS.sh` script for the current details.***

In the main directory run `build-macOS.sh`. This will create a clickable macOS Application in the `./dist` directory named `K40 Whisperer.app` that can then be distributed or moved to your Applications folder. See the following sections for details based on your chosen Python version.

If you are using one of the most excellent [Homebrew](https://brew.sh/) versions of Python, you are not only a wonderful person, but life will be easy for you. This build process has been tested *mostly* on Python 3.7.2 and Python 2.7.15 using [pyenv](https://github.com/pyenv/pyenv).

NOTE: When installing Python with `pyenv`, you should use the `--enable-framework` flag so that Python can get properly bundled with the application.

### Python 3.9.1

Set up Python 3.9.1 with `HomeBrew` and `pyenv`. Something like the following should work

```
# Install HomeBrew (only if you don't have it)
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install Dependencies (only if you haven't done this already)
brew install libusb
brew cask install xquartz
brew cask install inkscape
brew install pyenv

# Install Python 3.9.1 with pyenv and set it as the default Python
PYTHON_CONFIGURE_OPTS="--enable-framework" pyenv install 3.7.2
pyenv global 3.7.2
pyenv rehash
```

Then running the build should work. If not, well, there should be a lot of error messages to help you track things down.

```
./build-macOS.sh
```

### Vagrant buildfile

Included is a `vagrant` build setup as well. It's not well tested but seems to mostly work. If nothing else it has the dependency information built into it.

```
host$ vagrant up                # takes a long time
host$ vagrant ssh
vagrant$ cd /vagrant
vagrant$ ./build-macOS.sh       # run the build on the vagrant guest
vagrant$ exit
host$ ls -l dist/*              # the `.app` will show up here.
```
