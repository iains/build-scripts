# This contains a number of scripts that support GCC build and test on macOS.

It is assumed that you will be starting from the latest available Xcode command line tools available on the OS version you are testing on.

The main script is `make-gcc-build-deps` which builds and installs a number of exes that are needed for GCC build and test.

A secondary script `update-build-scripts` installs the actual build and test scripts.

NOTE: At the moment these assume a specific layout of paths etc (although the install prefix can be changed).

TODO; this is a completely inadequate description .. 

Tested on:

|   Darwin/macOS     | powerpc | i686 | x86_64 | aarch64 |
| ------------------ | ------- | ---- | ------ | ------- |
| 24 / Sequoia       |  N/A    | N/A  |  Yes   |         |
| 23 / Sonoma        |  N/A    | N/A  |  Yes   |  Yes    |
| 22 / Ventura       |  N/A    | N/A  |        |  Yes    |
| 21 / Monterey      |  N/A    | N/A  |  Yes   |  Yes    |
| 20 / Big Sur       |  N/A    | N/A  |  Yes   |         |
| 19 / Catalina      |  N/A    | N/A  |  Yes   |  N/A    |
| 18 / Mojave        |  N/A    | N/A  |  Yes   |  N/A    |
| 17 / High Sierra   |  N/A    | Yes  |  Yes   |  N/A    |
| 16 / Sierra        |  N/A    |      |  Yes   |  N/A    |
| 15 / El Capitan    |  N/A    |      |  Yes   |  N/A    |
| 14 / Yosemite      |  N/A    |      |        |  N/A    |
| 13 / Mavericks     |  N/A    |      |        |  N/A    |
| 12 / Mountain Lion |  N/A    |      |        |  N/A    |
| 11 / Lion          |  N/A    |      |        |  N/A    |
| 10 / Snow Leopard  |         |      |        |  N/A    |
|  9 / Leopard       |         |      |        |  N/A    |
|  8 / Tiger         |         |      |        |  N/A    |
