# macOS / Darwin build scripts.

This contains a number of scripts that support GCC build and test on macOS.

## Background

I test GCC on versions of macOS from MacOSX 10.5 (Leopard) through macOS 15 (Sequoia) on several architectures and on a mixture of hardware and VMs.  These scripts support this by keeping a consistent set of build tools.

There are a few requirements:

 * It is assumed that the latest available Xcode command line tools are installed on the OS version you are building/testing on.

 * It is assumed that for out-of-support OS versions you are using the last available OS security and bug-fix updates.

 * These tools are either the minimum version needed for modern GCC, or ones that Xcode does not provide.  In some cases these need to override the version provided on the system where it is too old or has critical bugs.

 * As far as possible to keep the recipe the same across the OS versions (for this reason they are written for `/bin/sh` rather than `bash` or `python`).

 * To avoid installing a distribution to do this - so the number of tools is kept to minimum.

 * To be stand-alone and self-contained - there are no dependencies outside of this (other than the OS libraries).

## Executables to support build, test and common development tasks.

By default these are installed in `/opt/iains/<build-system-triple>/gcc-build-tools`.  However, the build script does support `--prefix ` to install them to a different path.  Note that, if you want to support `Rosetta` (i.e. build x86_64 on Arm64, or powerpc on x86_64) or both `i686` and `x86_64` on relevant systems, you might want to stick with a similar scheme of identifying the build system triple in the installation.

From the following packages:

 * `autoconf-2.69` (not provided by Xcode)
 * `automake-1.15.1` (not provided by Xcode)
 * `gperf-3.1` (the version provided on the system is too old)
 * `m4-1.4.19` (installed version does not support --gnu)
 * `tcl-8.6.14` (improved stack usage over the installed 8.5)
 * `darwin-expect-5-45r3` (there are various bugs in several of the installed expect versions.  This is patched to better support macOS.)
 * `dejagnu-1.6.2` (not provided by Xcode)
 * `texinfo-6.7` (the installed version is too old)
 * `iconv-1.18` (Support for gettext; some OS versions have a bug in the installed library)
 * `libunistring-1.3` (Support for gettext).
 * `gettext-0.22.5` (not provided by Xcode, needed to support i18n).
 * `autogen-5-18-16` (not provided by Xcode)

These are built by `make-gcc-build-deps` which takes the following options:
```
make-gcc-build-deps [options]
options:
 --prefix    : specify the prefix
 --compiler  : specify the compiler
 --arch      : specify a different arch from the kernel
 --jobs/-j   : number of jobs for make and check.
 --force/-f  : continue on non-fatal error.
 --help/-h   : this output.
```

NOTE1: These are all statically linked to their dependent libraries so that we
do not have dylibs installed that might differ from the system versions.

NOTE2: `autogen` has a lot of dependencies both on tools and libraries that macOS does not have by default.  These are not currently installed as per the intention to minimise the footprint of this toolset. 

## Build and test scripts

These are installed by `update-build-scripts` which takes the following options:
```
update-build-scripts [options]
options:
 --prefix    : specify the prefix
 --arch      : specify a different arch from the kernel
 --force/-f  : continue on non-fatal error.
 --help/-h   : this output.
```

NOTE1: As noted above these scripts make a lot of assumptions about system layout

TODO1; customise this...
TODO2; this is a completely inadequate description .. 

## Testing of these scripts

* gettext and guile needs C++11 compiler, and so Darwin <= 12 needs to use a more recent one than provided by XCode (the tests here used gcc-7-5).

* Not able to build guile-2.2.7 with Rosetta (PowerPC) on Darwin9 or 10, however guile-2.0.14 does build and is sufficient.

* Not able to build coreutils-9.6 for x86_64 on Darwin9 (it seems to use some unsupported insns unconditionally).  However coreutils-8.32 builds and is sufficient.

* No available PowerPC h/w so no native tests or tests for powerpc64-apple-darwin9.

Tested on:

|   Darwin/macOS     | powerpc | i686 | x86_64 | aarch64 |
| ------------------ | :-----: | :--: | :----: | :-----: |
| 24 / Sequoia       |  N/A    | N/A  |  Yes   |   ?     |
| 23 / Sonoma        |  N/A    | N/A  |  Yes   |  Yes    |
| 22 / Ventura       |  N/A    | N/A  |   ?    |  Yes    |
| 21 / Monterey      |  N/A    | N/A  |  Yes   |  Yes    |
| 20 / Big Sur       |  N/A    | N/A  |  Yes   |   ?     |
| 19 / Catalina      |  N/A    | N/A  |  Yes   |  N/A    |
| 18 / Mojave        |  N/A    | N/A  |  Yes   |  N/A    |
| 17 / High Sierra   |  N/A    | Yes  |  Yes   |  N/A    |
| 16 / Sierra        |  N/A    | Yes  |  Yes   |  N/A    |
| 15 / El Capitan    |  N/A    | Yes  |  Yes   |  N/A    |
| 14 / Yosemite      |  N/A    | Yes  |  Yes   |  N/A    |
| 13 / Mavericks     |  N/A    | Yes  |  Yes   |  N/A    |
| 12 / Mountain Lion |  N/A    | Yes  |  Yes   |  N/A    |
| 11 / Lion          |  N/A    | Yes  |  Yes   |  N/A    |
| 10 / Snow Leopard  | Yes(r1) | Yes  |  Yes   |  N/A    |
|  9 / Leopard       | Yes(r1) | Yes  |  Yes   |  N/A    |
|  8 / Tiger         |         |      |        |  N/A    |

? = no hardware available here to test this version
(r1) = Rosetta1.
