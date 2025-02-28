#! /bin/bash

find . -d -name autom4te.cache -exec rm -fr {} >/dev/null \; -ls

rootdir=`pwd`
printf "doing %s \n" $rootdir
autoreconf -I. -Iconfig

cd gcc 
printf "doing %s\n" `pwd`
autoreconf -I. -I../config -I.. 
cd $rootdir

# fixincludes
for dir in c++tools gnattools intl libada libatomic libbacktrace libcc1 ; do
  cd $dir
  printf "doing %s \n" $dir
  autoreconf -I. -I.. -I../config
  cd $rootdir
done

for dir in libcody libcpp libdecnumber libffi libgcc libiberty; do
  cd $dir
  printf "doing %s \n" $dir
  autoreconf -I. -I.. -I../config
  cd $rootdir
done

for dir in libitm libobjc libphobos libquadmath libssp; do
  cd $dir
  printf "doing %s \n" $dir
  autoreconf -I. -I.. -I../config
  cd $rootdir
done

cd libobjc 
printf "doing %s\n" `pwd`
autoreconf -I. -I../config -I.. 
cd $rootdir

for dir in libstdc++-v3 libvtv lto-plugin zlib; do
  cd $dir
  printf "doing %s \n" $dir
  autoreconf -I. -I.. -I../config
  cd $rootdir
done

# these do not like being given the -I
cd liboffloadmic
printf "doing %s \n" liboffloadmic libgo gotools
autoreconf
cd $rootdir

# these produce lots of warnings
for dir in libbacktrace libgomp libgfortran libsanitizer; do
  cd $dir
  printf "doing %s \n" $dir
  autoreconf -I. -I.. -I../config 2>/dev/null
  cd $rootdir
done

find . -d -name autom4te.cache -exec rm -fr {} >/dev/null \; -ls
