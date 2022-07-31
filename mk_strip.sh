#!/bin/sh

# 导入公共环境
. ./common.sh

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
rm -rf ${glibc_install}/usr/share
strip_dir ${glibc_install}

# strip busybox
rm -rf ${busybox_install}/linuxrc
strip ${busybox_install}/bin/busybox 

# strip gcc
#rm -rf work/libgcc_install/usr/share
strip_dir ${gcc_install}

# strip binutils
#rm -rf work/binutils_install/usr/share
strip_dir ${binutils_install}

