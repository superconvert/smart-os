#!/bin/sh

SYSROOT=`pwd`"/rootfs"

#----------------------------------------------
#
# 下载源码
#
#----------------------------------------------
mkdir -pv source
cd source

#KERNEL_SOURCE_URL=https://kernel.org/pub/linux/kernel/v4.x/linux-4.14.9.tar.xz
KERNEL_SOURCE_URL=https://mirror.bjtu.edu.cn/kernel/linux/kernel/v4.x/linux-4.14.9.tar.xz
if [ ! -f "linux-4.14.9.tar.xz" ]; then 
  wget $KERNEL_SOURCE_URL 
fi

GLIBC_SOURCE_URL=https://ftp.gnu.org/gnu/glibc/glibc-2.32.tar.bz2
if [ ! -f "glibc-2.32.tar.bz2" ]; then
  wget $GLIBC_SOURCE_URL
fi

BUSYBOX_SOURCE_URL=https://busybox.net/downloads/busybox-1.34.1.tar.bz2
if [ ! -f "busybox-1.34.1.tar.bz2" ]; then 
  wget $BUSYBOX_SOURCE_URL 
fi

GCC_SOURCE_URL=https://ftpmirror.gnu.org/gcc/gcc-7.5.0/gcc-7.5.0.tar.xz
if [ ! -f "gcc-7.5.0.tar.xz" ]; then 
  wget $GCC_SOURCE_URL 
fi

cd ..

#---------------------------------------------
#
# 解压源码 
#
#---------------------------------------------
mkdir -pv work

if [ ! -d "./work/linux-4.14.9" ]; then
  tar xvf source/linux-4.14.9.tar.xz -C work/
fi

if [ ! -d "./work/glibc-2.32" ]; then
  tar xvf source/glibc-2.32.tar.bz2 -C work/
fi

if [ ! -d "./work/busybox-1.34.1" ]; then
  tar xvf source/busybox-1.34.1.tar.bz2 -C work/
fi

if [ ! -d "./work/gcc-7.5.0" ]; then
  tar xvf source/gcc-7.5.0.tar.xz -C work/
fi

#---------------------------------------------
#
# 编译源码 
#
#---------------------------------------------
cd work

kernel_install=`pwd`"/kernel_install"
glibc_install=`pwd`"/glibc_install"
busybox_install=`pwd`"/busybox_install"
libgcc_install=`pwd`"/libgcc_install"

# 编译内核, 最终所有模块都装到目录 /lib/modules/4.14.9
if [ ! -d "kernel_install" ]; then 
  mkdir -pv kernel_install && cd linux-4.14.9
  # Enable the VESA framebuffer for graphics support.
  # 网络需要 TUN/TAP 驱动 [ Device Drivers ] ---> [ Network device support ] ---> [ Universal TUN/TAP device driver support ]
  make x86_64_defconfig && sed -i "s/.*CONFIG_FB_VESA.*/CONFIG_FB_VESA=y/" .config && make bzImage -j8
  #cd linux-4.14.9 && make x86_64_defconfig && make bzImage -j8 && make modules && make modules_install && cd ..
  make INSTALL_HDR_PATH=${kernel_install} headers_install -j8 && cp arch/x86_64/boot/bzImage ${kernel_install} 
  cd ..
fi

# 编译glibc
if [ ! -d "glibc_install" ]; then
  echo $PATH
  mkdir -pv glibc_install && cd glibc-2.32
  mkdir -pv build && cd build && make distclean
  ../configure --prefix= \
    --with-headers=${kernel_install}/include/ \
    --without-gd \
    --without-selinux \
    --disable-werror
  make -j8 && make install -j8 DESTDIR=${glibc_install}
  cd .. && cd ..
fi

# 编译 busybox 
if [ ! -d "busybox_install" ]; then
  mkdir -pv busybox_install && cd busybox-1.34.1 && make distclean && make defconfig
  # 静态编译 sed -i "s/# CONFIG_STATIC is not set/CONFIG_STATIC=y/g" .config
  sed -i "s|.*CONFIG_SYSROOT.*|CONFIG_SYSROOT=\"${glibc_install}\"|" .config
  sed -i "s|.*CONFIG_EXTRA_CFLAGS.*|CONFIG_EXTRA_CFLAGS=\"$CFLAGS -I${kernel_install}/include -I${glibc_install}/include -L${glibc_install}/lib\"|" .config
  export PATH=/sbin:/bin:/usr/sbin:/usr/bin
  make busybox -j8 && make CONFIG_PREFIX=${busybox_install} install && cd ..
fi

# 编译 libgcc
if [ ! -d "libgcc_install" ]; then 
  mkdir -pv libgcc_install && cd gcc-7.5.0
  ./contrib/download_prerequisites
  ./configure --prefix=${libgcc_install} --enable-languages=c,c++ --disable-multilib --disable-static --disable-libquadmath --enable-shared
  CFLAGS="-L${glibc_install}/lib $CFLAGS" make -j8 all-gcc && make -j8 && make install -j8
  cd ..
fi

cd ..
