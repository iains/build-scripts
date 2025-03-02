# This contains a number of scripts that support GCC build and test on macOS.

It is assumed that you will be starting from the latest available Xcode command line tools available on the OS version you are testing on.

The main script is `make-gcc-build-deps` which builds and installs a number of exes that are needed for GCC build and test.

A secondary script `update-build-scripts` installs the actual build and test scripts.

NOTE: At the moment these assume a specific layout of paths etc (although the install prefix can be changed).

TODO; this is a completely inadequate description .. 

