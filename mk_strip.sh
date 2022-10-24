#!/bin/sh

# 导入公共环境
. ./common.sh

# 对指定的目录进行 strip
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
strip_dir ${busybox_install}/bin/busybox

# strip lshw
strip_dir ${lshw_install}

# strip pciutils_install
strip_dir ${pciutils_install}

# strip lsof
strip_dir ${lsof_install}

# strip strace
strip_dir ${strace_install}

# strip openssl
strip_dir ${openssl_install}

# strip openssh
strip_dir ${openssh_install}

# strip gcc
#rm -rf work/libgcc_install/usr/share
strip_dir ${gcc_install}

# strip binutils
#rm -rf work/binutils_install/usr/share
strip_dir ${binutils_install}

# strip xfce
if [ "${with_xfce}" = true ]; then
    strip_dir ${xfce_install}
fi
