# K40 Whisperer

Packaging of Scorchworks K40 Whisperer as an OSX Application.

    K40 Whisperer is an alternative to the the Laser Draw (LaserDRW) program that comes with the cheap Chinese laser cutters available on E-Bay and Amazon. K40 Whisperer reads SVG and DXF files, interprets the data and sends commands to the K40 controller to move the laser head and control the laser accordingly. K40 Whisperer does not require a USB key (dongle) to function.

The official K40 Whisperer and instructions are at Scorchworks:

> http://www.scorchworks.com/K40whisperer/k40whisperer.html

This fork is merely to add packaging for macOS systems, creating a clickable application that can be installed on any macOS system. This eliminates having to run K40 Whisperer from a Terminal prompt.

## Running The Packaged Application

K40 Whisperer requires a few dependencies that are not installed as part of the application bundle. You will need to install these yourself to have a functioning application.

* [libusb](https://libusb.info) for access to the USB port(s)
* [inkscape](https://inkscape.org) for drawing and rasterization

The dependencies are best installed with [Homebrew](https://brew.sh/) in a `Terminal` window as follows

```
# Install HomeBrew (only if you don't have it)
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

# Install Dependencies
brew install libusb
brew cask install inkscape
```

You need not read any further in this document. You should be albe to run K40 Whisperer.

## Rebuilding from Source (macOS)

In the main directory run `build_macOS.sh`. This will create a clickable macOS Application in the `./dist` directory named `K40 Whisperer.app` that can then be distributed or moved to your Applications folder.

If your default `python` is the macOS default system Python, read below. You have work to do first. If you are using one of the most excellent [Homebrew](https://brew.sh/) versions of Python, you are not only a wonderful person, but life will be easy for you. This build process has been tested on `Python 3.7.2` and 'Python 2.7.15`

NOTE: When installing Homebrew Python, you should `--enable-framework`.

### Python 3.7.2 (preferred)

Set up Python 3.7.2. Something like the following

```
PYTHON_CONFIGURE_OPTS="--enable-framework" pyenv install 3.7.2
pyenv global 3.7.2
rehash
```

Then a simple build should work

```
./build_macOS.sh
```

NOTE: I get the error below from `py2app` but the application bundle still seems to function properly. Please do let me know if you know how to solve this one. It seems I need to install Python in a deeper path on my system so the `macho` header can be rewritten properly. I haven't tried this yet.

```
ValueError: New Mach-O header is too large to relocate in ... dist/K40 Whisperer.app/Contents/Resources/lib/python3.7/PIL/.dylibs/liblcms2.2.dylib' (new size=1688, max size=1680, delta=48)
```

### Python 3.6

Don't.

Compiling with `py2app-0.18` under Homebrew Python 3.6.6 results in:

```
ValueError: character U+6573552f is not in range [U+0000; U+10ffff]
```

### Python 2.7.15 (not preferred)

Set up Python 3.7.2. Something like the following

```
PYTHON_CONFIGURE_OPTS="--enable-framework" pyenv install 2.7.15
pyenv global 2.7.15
rehash
```

Then a simple build should work

```
./build_macOS.sh
```

NOTE: This gets a similar 'Mach-O' error as 3.7.2. See above. Still seems to work.

### macOS System Python (not preferred)

If you build K40 Whisperer with the default system Python there are a few complications with compilation that are not (cannot be) addressed directly in the `build_macOS.sh` script and need to be handled manually before compiling. These stem from the _System Integrity Protection_ on macOS (since 10.10) and the system Python packager, `py2app`.

A solution that has worked for my system is documented on Stack Overflow in [py2app Operation Not Permitted][http://stackoverflow.com/questions/33197412/py2app-operation-not-permitted] and there is a detailed discusson on [Apple's Developer Forums][https://forums.developer.apple.com/thread/6987].

Solution:
* Boot in recovery mode and open a command-line or Terminal
* Run `csrutil disable`
* Reboot and open a command-line or Terminal
* Run `sudo chflags -R norestricted /System/Library/Frameworks/Python.framework`
* Reboot into recovery mode and open a command-line or Terminal
* Run `csrutil enable`
* Reboot and build...

You need to do that before this will work!

I've been able to compile everything on a freshly installed macOS 10.14.2 (January 2019) system after installing the dependencies listed below.

## macOS Build Notes

This fork adds the following files to Scorch's work

* `build_macOS.sh` -- bash build script to build and create application bundle.
* `py2app_setup.py` -- `py2app` setup script that creates the application bundle.
* `K40-Whisperer-Icon.*` -- Icons for macOS application bundle.
* `macOS.patch` -- tweaks to Scorch's source for macOS

### Button Text Doesn't Wrap Properly

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

macOS Majove has a strange Tkinter problem where button text is blank until you resize the application window with Python 3.7.2. I don't see the same problem with Python 2.7.15. A simple code fix from StackOverflow [button text of tkinter not works in mojave][https://stackoverflow.com/questions/52529403/button-text-of-tkinter-not-works-in-mojave] is as follows. 
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

This one is not yet in the `.patch` file.

## macOS Development Notes

To create a new patch file to be used by `update-macOS.sh`, when needed, which should be rarely:

```
diff -Naur k40_whisperer.py ~/Downloads/K40_Whisperer-0.29_src/k40_whisperer.py >  macOS.patch
```

### The .icns Icon file

I came up with the Icon file for the app as Scorch does not yet have one in his distribution. The original Photoshop file and a PNG are included in this repository.

The original [Laser Symbol](https://commons.wikimedia.org/wiki/File:Laser-symbol.svg) is from Wiki Media Commons. The modifications are by me [Stephen Houser][https://stephenhouser.com] plopping Scorch's icon on there and masking out

[Using sips to create an icns file from a png file](https://stackoverflow.com/questions/44506713/using-sips-to-create-an-icns-file-from-a-png-file)

```
sips -s format icns K40-Whisperer-Icon.png --out K40-Whisperer-Icon.icns
```