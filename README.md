# K40 Whisperer

Packaging of Scorchworks K40 Whisperer as an OSX Application.

> K40 Whisperer is an alternative to the the Laser Draw (LaserDRW) program that comes with the cheap Chinese laser cutters available on E-Bay and Amazon. K40 Whisperer reads SVG and DXF files,interprets the data and sends commands to the K40 controller to move the laser head and control the laser accordingly. K40 Whisperer does not require a USB key (dongle) to function.

![K40 Whisperer Main](K40 Whisperer Main.png)

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

## Rebuilding from Source (macOS)

*** These directions may be outdated, please check the `build_macOS.sh` script for the current details.***

In the main directory run `build_macOS.sh`. This will create a clickable macOS Application in the `./dist` directory named `K40 Whisperer.app` that can then be distributed or moved to your Applications folder. See the following sections for details based on your chosen Python version.

If you are using one of the most excellent [Homebrew](https://brew.sh/) versions of Python, you are not only a wonderful person, but life will be easy for you. This build process has been tested *mostly* on Python 3.7.2 and Python 2.7.15 using [pyenv](https://github.com/pyenv/pyenv).

NOTE: When installing Python with `pyenv`, you should use the `--enable-framework` flag so that Python can get properly bundled with the application.

### Python 3.9.1 (preferred method)

Set up Python 3.9.1 with HomeBrew and pyenv. Something like the following should work

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
./build_macOS.sh
```

### Python 3.6

Don't do it.

Compiling with `py2app-0.18` under Homebrew Python 3.6.6 results in:

```
ValueError: character U+6573552f is not in range [U+0000; U+10ffff]
```

### Python 2.7.15 (not preferred)

Don't do it. Python 2 is dead.

### macOS System Python (not preferred)

Don't do it.

If you build K40 Whisperer with the default system Python there are a few complications with compilation that are not (cannot be) addressed directly in the `build_macOS.sh` script and need to be handled manually before compiling. These stem from the _System Integrity Protection_ on macOS (since 10.10) and the system Python packager, `py2app`.

A solution that has worked for my system is documented on Stack Overflow in [py2app Operation Not Permitted](http://stackoverflow.com/questions/33197412/py2app-operation-not-permitted) and there is a detailed discusson on [Apple's Developer Forums](https://forums.developer.apple.com/thread/6987).

Solution:
* Boot in recovery mode and open a command-line or Terminal
* Run `csrutil disable`
* Reboot and open a command-line or Terminal
* Run `sudo chflags -R norestricted /System/Library/Frameworks/Python.framework`
* Reboot into recovery mode and open a command-line or Terminal
* Run `csrutil enable`
* Reboot and build...

You need to do that before this will work!

I've was able to compile everything on a freshly installed macOS 10.14.2 (January 2019) system after installing the dependencies listed below. I haven't really tested this method extensively and have made code changes since it worked. Use at your own risk.

## macOS Build Notes

This fork adds the following files to Scorch's work

* `build_macOS.sh` -- bash build script to build and create application bundle.
* `update_macOS.sh` -- bash script to patch a new version of K40 Whisperer and bundle it.
* `py2app_setup.py` -- `py2app` setup script that creates the application bundle.
* `emblem.icns` -- Icons for macOS application bundle (made with `sips`)
* `macOS.patch` -- tweaks to Scorch's source for macOS

When a new source package is released by Scorch, the general update process is.

1. Download and extract the new source code
2. Check this repository out into a working directory
3. Run `update_macOS.sh` with the address of the latest source archive
4. *poof* out comes a disk image (`.dmg` file) with the new bundled version.
5. Don't forget to test it!

Here's my typing... and my likely future copy and paste.

```
# Get this repository
git clone https://github.com/stephenhouser/k40_whisperer.git
cd k40_whisperer

# Download, apply patches, build the application
./update_macOS.sh -u https://www.scorchworks.com/K40whisperer/K40_Whisperer-0.29_src.zip

# Test/Fix/Test...(needs some work)
...
open ./dist/K40\ Whisperer.app
...

# Move newly generated patch file into place
mv macOS-0.29.patch macOS.patch

# Commit and push back to GitHub
git commit -a -m"Update to v0.29"
git tag v0.29
git push --follow-tags
```

### Vagrant buildfile

Included is a `vagrant` build setup as well. It's not well tested but seems to mostly work. If nothing else it has the dependency information built into it.

```
host$ vagrant up                # takes a long time
host$ vagrant ssh
vagrant$ cd /vagrant
vagrant$ ./build_macOS.sh       # run the build on the vagrant guest
vagrant$ exit
host$ ls -l dist/*              # the `.app` will show up here.
```

### Button Text Doesn't Wrap Properly

NOTE: This seems to be resolved in Python 3.9.1 and/or newer Tk. No longer needed.

Button text does not wrap properly on macOS tkinter. My simple solution is to...

* specify a `wraplength` for `Open` and `Reload`
* shorten the text for `Raster Engrave` and `Vector Engrave` buttons

The following goes in somewhere around line 477 in `k40_whisperer.py`. The `.patch` file has the details.

```
# Adjust button wrap locations for macOS
self.Open_Button.config(wraplength=20)
self.Reload_Button.config(wraplength=20)
self.Reng_Button.config(text="Raster Eng.")
self.Veng_Button.config(text="Vector Eng.")
```

The `Save` button on the `General Settings` has a similar problem. Around line 3872.

```
w_entry=50
```

### Buttons are Blank

NOTE: This seems to be resolved in Python 3.9.1 and/or newer Tk. No longer needed.

macOS Mojave has a strange Tkinter problem where button text is blank until you resize the application window with Python 3.7.2. I don't see the same problem with Python 2.7.15. A simple code fix from StackOverflow [button text of tkinter not works in mojave](https://stackoverflow.com/questions/52529403/button-text-of-tkinter-not-works-in-mojave) is as follows.
This was tested on macOS 10.14.2 with Python 2.7.14 and Python 3.7.2.

```
# START CHANGES
def fix():
    a = root.winfo_geometry().split('+')[0]
    b = a.split('x')
    w = int(b[0])
    h = int(b[1])
    root.geometry('%dx%d' % (w+1,h+1))
    
root.update()
root.after(0, fix)
# END CHANGES
tkinter.mainloop()
```

A variant of this is included in the patch file.
