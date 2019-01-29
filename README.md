# K40 Whisperer

Packaging of Scorchworks K40 Whisperer as an OSX Application.

    K40 Whisperer is an alternative to the the Laser Draw (LaserDRW) program that comes with the cheap Chinese laser cutters available on E-Bay and Amazon. K40 Whisperer reads SVG and DXF files, interprets the data and sends commands to the K40 controller to move the laser head and control the laser accordingly. K40 Whisperer does not require a USB key (dongle) to function.

The official K40 Whisperer and instructions are at Scorchworks:

http://www.scorchworks.com/K40whisperer/k40whisperer.html

This fork is merely to add packaging for macOS systems, creating a clickable 'Applicaion' that can be installed on any macOS system. This eliminates having to run K40 Whisperer from a Terminal prompt.

## macOS Build

This fork adds the following files to Scorch's work

* `build_macOS.sh` -- bash build script to build and create application bundle.
* `py2app_setup.py` -- `py2app` setup script that creates the application bundle.
* `K40-Whisperer-Icon.*` -- Icons for macOS application bundle.

## Compiling

In the main directory run `build_macOS.sh`. This will create a clickable macOS Application in the `./dist` directory named `K40 Whisperer.app` that can then be distributed or moved to your Applications folder.

### System Default Python

If you build K40 Whisperer with the default system Python there are a few complications with compilation that are not (cannot be) addressed directly in the macOS build_macOS.sh script and need to be handled manually before compiling. These stem from the System Integrity Protection on macOS (since 10.10) and the system Python packager, py2app.

A solution that has worked for my system is documented on Stack Overflow in py2app Operation Not Permitted and there is a detailed discusson on Apple's Developer Forums

Solution:

Boot in recovery mode and open a command-line or Terminal
Run csrutil disable
Reboot and open a command-line or Terminal
Run sudo chflags -R norestricted /System/Library/Frameworks/Python.framework
Reboot into recovery mode and open a command-line or Terminal
Run csrutil enable
Reboot and build...
You need to do that before this will work!

I've been able to compile everything on a freshly installed macOS 10.14.2 (January 2019) system after installing the dependencies listed below.

### The .icns Icon file

I came up with the Icon file for the app as Scorch does not yet have one in his distribution. The original Photoshop file and a PNG are included in this repository.

The original [Laser Symbol](https://commons.wikimedia.org/wiki/File:Laser-symbol.svg) is from Wiki Media Commons. The modifications are by me [Stephen Houser][https://stephenhouser.com] plopping Scorch's icon on there and masking out

[Using sips to create an icns file from a png file](https://stackoverflow.com/questions/44506713/using-sips-to-create-an-icns-file-from-a-png-file)

```
sips -s format icns K40-Whisperer-Icon.png --out K40-Whisperer-Icon.icns
```