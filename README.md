# macOS / Darwin build scripts.

This contains a number of scripts that support GCC build and test on macOS.

Changelog.

0.9 : March 2025 : Initial public branch


## 1 Background

I test GCC on versions of macOS from MacOSX 10.5 (Leopard) through macOS 15 (Sequoia) on several architectures and on a mixture of hardware and VMs.  These scripts support this by keeping a consistent set of build tools.

There are a few requirements:

 * It is assumed that the latest available Xcode command line tools are installed on the OS version you are building/testing on.

 * It is assumed that for out-of-support OS versions you are using the last available OS security and bug-fix updates.

 * These tools are either the minimum version needed for modern GCC, or ones that Xcode does not provide.  In some cases these need to override the version provided on the system where it is too old or has critical bugs.

 * As far as possible to keep the recipe the same across the OS versions (for this reason they are written for `/bin/sh` rather than `bash` or `python`).

 * To avoid installing a distribution to do this - so the number of tools is kept to minimum.

 * To be stand-alone and self-contained - there are no dependencies outside of this (other than the OS libraries).

## 2 How to use these scripts

The scripts here allow for the case that you might want to have, for example, installs for aarch64 (Arm64) + x86_64 (rosetta2) or x86_64 + i686 [or even i686 + x86_64 + powerpc (rosetta1) on MacOSX 10.5 or 10.6].

To do that the installs are identified by build triple (and you can override that to specify secondary or subsequent case).  So the paths below should be considered `root` paths.

If you omit any `--arch` setting, the installation will reflect the kernel architecture.

1. First decide where you want to put source checkouts, builds and installs
2. Edit the "paths" script to reflect the choices at 1.

initial paths:

`$src_local_path` is where we expect to find checkouts of GCC branches.
  By default, we expect those to be named `gcc-master` and `gcc-git-<major>` for release branches.
  NOTE1: you can override repository checkout paths - this is just the defaults.
  NOTE2: it also makes sense to checkout these scripts there too.

`$scratch_path`
  This is the root of where we build the compilers.
  It probably makes sense to run the builds for these scripts there too.
  NOTE: We actually work in `$scratch_path/<OS identifier>/gcc-<version>` and using the same OS identifier makes sense for other cases - it allows cross-builds etc without too much confusion.  OS Identifiers are listed in section 6 below.

`$install_path`
  This is the root of the prefix(es) for the compilers - it needs to be writable by the user running the scripts.

Having made the choices then create the executables per section 3 below.
Install the scripts per section 4 below.

**Then put `$install_path/$build_triple/gcc-build-tools/bin` first in your path.  This is important, since we need to overide some of the system-provided tools which are now too old to be used.**

## 3 Executables and scripts to support build, test and common development tasks.

By default these are installed in `$install_path/<build-system-triple>/gcc-build-tools`.  However, the build script does support `--prefix ` to install them to a different path.  Note that, if you want to support `Rosetta` (i.e. build x86_64 on Arm64, or powerpc on x86_64) or both `i686` and `x86_64` on relevant systems, you might want to stick with a similar scheme of identifying the build system triple in the installation.

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
  Installs into 'gcc-build-tools' at the chosen prefix.
options:
 --prefix     : specify prefix (default $install_path/<build-triple>).
 --compiler   : specify the compiler
 --arch       : specify a different arch from the kernel
 --jobs/-j    : number of jobs for make and check.
 --force/-f   : continue on non-fatal error.
 --help/-h    : this output.
 --version/-v : scripts version.
```

NOTE1: These are all statically linked to their dependent libraries so that we
do not have dylibs installed that might differ from the system versions.

NOTE2: `autogen` has a lot of dependencies both on tools and libraries that macOS does not have by default.  These are not currently installed as per the intention to minimise the footprint of this toolset. 

## 4 Build and test scripts

### 4.1 Installation

These are installed by `update-build-scripts` which takes the following options:
```
update-build-scripts [options]
  Installs into 'gcc-build-tools' at the chosen prefix.
options:
 --prefix     : specify prefix (default $install_path/<build-triple>).
 --arch       : specify a different arch from the kernel
 --force/-f   : continue on non-fatal error.
 --help/-h    : this output.
 --version/-v : scripts version.
```

### 4.2 GCC build and test

This is the main work script that collects the common steps.

`gcc-bootstrap-and-test`
  - removes the previous build and install
  - configures and bootstraps the chosen compiler
  - runs the testsuite
  - collects the test result summary into "summ.txt"

It is quite customisable - but for the simple case that one is working on the tip of trunk the invocation can be `gcc-bootstrap-and-test`; defaults will be picked.

My most frequent options are "-u -f" to force an update of the branch before starting the build and "--install" if I want to use the resulting compiler.

The current set of options here:
```
gcc-bootstrap-and-test [options] [gcc-version [bootstrap compiler]]
  gcc-version is either 'master'/'trunk' or a major release number (default 'master')
  If a branch is not specified and different branch (to the one implied
  by gcc-version) is checked out in the relevant source directory the script will halt.
  If no bootstrap compiler is specified, the script will try to figure it out.
options:
 --update/-u  : update the source tree before starting (stop if unchanged).
 --repo       : repository path (default /src-local/<gcc-master,gcc-git-major>).
 --branch     : repository branch (default 'master' or 'releases/gcc-major').
 --blddir     : build directory (default /scratch/OS-ver[rosetta]/<gcc-master or gcc-major>).
 --prefix     : specify prefix (default /opt/iains//gcc-<base-ver>).
 --langs      : specify comma-separated list of languages to build (default = all).
 --sysroot    : specify sysroot (default depends on OS version).
 --config     : supply extra configure parms (e.g. cpu, tune etc).
 --arch       : specify a different arch from the kernel
 --hostshr    : enable host shared on 32b hosts.
 --jobs/-j    : number of jobs for make and check.
 --force/-f   : continue on non-fatal error.
 --install/-i : install the compiler before testing.
 --pch        : build libstdc++ PCH (default = no).
 --help/-h    : this output.
 --version/-v : script version.
```

### 4.3 Managing test output

TODO

### 4.4 Other scripts

* Update LAST_UPDATED gcc/REVISON for a checkout

`gcc-branch-rev`
  This is useful to update the LAST_UPDATED and gcc/REVISON of a checkout.
  It does not update the checkout in any other way (that is, the output reflects the current state of the branch).

  It produces output like:
```
$ gcc-branch-rev                                                                                                                                                                   build system is aarch64-apple-darwin21
[master revision r15-7902-ge8c2f3a427a9]
```

* Create a 2Gb ramdisk and assign it as tmp (this could be useful if you do not want to stress your filesystem).

`ramdisk`

* Reconfigure GCC

`gcc-autoreconf.sh`

## 5 Testing of these scripts

I have been using versions of these for several years, they occasionally get upgrades and/or improvements in factoring out common tasks. So they are pretty well tested in *my environments*.

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

## 6 OS Identifiers

$rosetta is attached to the path if the GCC build script figures out that you are doing a bootstrap under rosetta (either 1 [powerpc on x86] or 2 [x86_64 on aarch64])

|   Darwin/macOS     | OS build directory |
| ------------------ | :----------------- |
| 24 / Sequoia       | $scratch_path/15-seq$rosetta |
| 23 / Sonoma        | $scratch_path/14-son$rosetta |
| 22 / Ventura       | $scratch_path/13-ven$rosetta |
| 21 / Monterey      | $scratch_path/12-mon$rosetta |
| 20 / Big Sur       | $scratch_path/11-sur$rosetta |
| 19 / Catalina      | $scratch_path/10-15-cat |
| 18 / Mojave        | $scratch_path/10-14-moj |
| 17 / High Sierra   | $scratch_path/10-13-his |
| 16 / Sierra        | $scratch_path/10-12-sie |
| 15 / El Capitan    | $scratch_path/10-11-elcap |
| 14 / Yosemite      | $scratch_path/10-10-yos |
| 13 / Mavericks     | $scratch_path/10-9-mav |
| 12 / Mountain Lion | $scratch_path/10-8-ml |
| 11 / Lion          | $scratch_path/10-7-lion |
| 10 / Snow Leopard  | $scratch_path/10-6-sno$rosetta |
|  9 / Leopard       | $scratch_path/10-5-leo$rosetta |
|  8 / Tiger         | $scratch_path/10-4-tig |

