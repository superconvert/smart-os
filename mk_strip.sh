#!/bin/sh

strip_dir() {
  for file in `ls $1`
  do
    if [ -d $1"/"$file ]; then
      strip_dir $1"/"$file
    else
      if [ -x $1"/"$file ]; then
        case "$file" in
	  *.a);;
	  *.la);;
	  *)strip $1"/"$file; continue;;
        esac	  
      fi
      case "$file" in
        *.a) strip -g -S -d $1"/"$file;;
	*.so) strip $1"/"$file;;
	*.so.*) strip $1"/"$file;;
	*);;
      esac
    fi
  done
}

# strip glibc
rm -rf work/glibc_install/usr/share
strip_dir work/glibc_install 

# strip busybox
rm -rf work/busybox_install/linuxrc
strip work/busybox_install/bin/busybox 

# strip gcc
#rm -rf work/libgcc_install/usr/share
strip_dir work/libgcc_install

# strip binutils
#rm -rf work/binutils_install/usr/share
strip_dir work/binutils_install

