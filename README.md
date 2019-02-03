ObjFW is a portable, lightweight framework for the Objective C language. It
enables you to write an application in Objective C that will run on any
platform supported by ObjFW without having to worry about differences between
operating systems or various frameworks that you would otherwise need if you
want to be portable.

See https://heap.zone/objfw for more information.


Installation
============

  To install ObjFW, just run the following commands:

    $ ./configure
    $ make
    $ make install

  In case you checked out ObjFW from the Git repository, you need to run the
  following command first:

    $ ./autogen.sh

macOS and iOS
-------------

### Building as a framework

  When building for macOS or iOS, everything is built as a `.framework` by
  default if `--disable-shared` has not been specified to `configure`.

  To build for iOS, use something like this:

    $ clang="clang --sysroot $(xcrun --sdk iphoneos --show-sdk-path)"
    $ export OBJC="$clang -arch armv7 -arch arm64"
    $ export OBJCPP="$clang -arch armv7 -E"
    $ export IPHONEOS_DEPLOYMENT_TARGET="10.0"
    $ ./configure --prefix=/usr/local/ios --host=arm-apple-darwin

  To build for the iOS simulator, use something like this:

    $ clang="clang --sysroot $(xcrun --sdk iphonesimulator --show-sdk-path)"
    $ export OBJC="$clang -arch i386 -arch x86_64"
    $ export OBJCPP="$clang -arch i386 -E"
    $ export IPHONEOS_DEPLOYMENT_TARGET="10.0"
    $ ./configure --prefix=/usr/local/iossim --host=i386-apple-darwin

### Using the macOS or iOS framework in Xcode

  To use the macOS framework in Xcode, you need to add the `.framework`s to
  your project and add the following flags to `Other C Flags`:

    -fconstant-string-class=OFConstantString -fno-constant-cfstrings

Windows
-------

  Windows is only officially supported when following these instructions, as
  there are many MinGW versions that behave slightly differently and often
  cause problems.

### Getting MSYS2

  The first thing to install is [MSYS2](https://msys2.github.io) to provide a
  basic UNIX-like environment for Windows. Unfortunately, the binaries are not
  signed and there is no way to verify their integrity, so only download this
  from a trusted connection. Everything else you will download using MSYS2
  later will be cryptographically signed.

### Updating MSYS2

  The first thing to do is updating MSYS2. It is important to update things in
  a certain order, as `pacman` (the package manager MSYS2 uses, which comes
  from ArchLinux) does not know about a few things that are special on Windows.

  First, update the mirror list:

    $ pacman -Sy pacman-mirrors

  Then proceed to update the `msys2-runtime` itself, `bash` and `pacman`:

    $ pacman -S msys2-runtime bash pacman mintty

  Now close the current window and restart MSYS2, as the current window is now
  defunct. In a new MSYS2 window, update the rest of MSYS2:

    $ pacman -Su

  Now you have a fully updated MSYS2. Whenever you want to update MSYS2,
  proceed in this order. Notice that the first `pacman` invocation includes
  `-y` to actually fetch a new list of packages.

### Installing MinGW-w64 using MSYS2

  Now it's time to install MinGW-w64. If you want to build 32 bit binaries:

    $ pacman -S mingw-w64-i686-clang mingw-w64-i686-gcc-objc

  For 64 bit binaries:

    $ pacman -S mingw-w64-x86_64-clang mingw-w64-x86_64-gcc-objc

  There is nothing wrong with installing them both, as MSYS2 has created two
  entries in your start menu: `MinGW-w64 Win32 Shell` and `MinGW-w64 Win64
  Shell`. So if you want to build for 32 or 64 bit, you just start the correct
  shell.

  Finally, install a few more things needed to build ObjFW:

    $ pacman -S autoconf automake git make

### Getting, building and installing ObjFW

  Start the MinGW-w64 Win32 or Win64 Shell (depening on what version you want
  to build - do *not* use the MSYS2 Shell shortcut, but use the MinGW-w64 Win32
  or Win64 Shell shortcut instead!) and check out ObjFW:

    $ git clone https://heap.zone/git/objfw.git

  You can also download a release tarball if you want. Now go to the newly
  checked out repository and build and install it:

    $ ./autogen.sh && ./configure && make -j16 install

  If everything was successfully, you can now build projects using ObjFW for
  Windows using the normal `objfw-compile` and friends.


Bugs and feature requests
=========================

  If you find any bugs or have feature requests, feel free to send a mail to
  js@heap.zone!


Commercial use
==============

  If for whatever reason neither the terms of the QPL nor those of the GPL work
  for you, a proprietary license for ObjFW including support is available upon
  request. Just write a mail to js@heap.zone and we can find a reasonable
  solution for both parties.
