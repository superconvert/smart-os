#!/bin/sh

core_num=`nproc`
kernel_install=`pwd`"/work/kernel_install"
glibc_install=`pwd`"/work/glibc_install"
busybox_install=`pwd`"/work/busybox_install"
libgcc_install=`pwd`"/work/libgcc_install"
binutils_install=`pwd`"/work/binutils_install"

export CFLAGS="-Os -s -fno-stack-protector -fomit-frame-pointer -U_FORTIFY_SOURCE"

#-----------------------------------------------
#
# 重新生成目标文件
#
#----------------------------------------------- 
if [ "$1" != "" ]; then
  if [ $1 != "rebuild" ]; then
    exit
  fi
  echo "rebuild"
  cd work
  rm -rf kernel_install glibc_install busybox_install libgcc_install binutils_install
  # 编译内核, 最终所有模块都装到目录 /lib/modules/4.14.9
  if [ ! -d "kernel_install" ]; then
    mkdir -pv kernel_install && cd linux-4.14.9 
    make INSTALL_HDR_PATH=${kernel_install} headers_install -j8 && cp arch/x86_64/boot/bzImage ${kernel_install} && cd ..
  fi

  # 编译glibc
  if [ ! -d "glibc_install" ]; then
    mkdir -pv glibc_install && cd glibc-2.32
    mkdir -pv build && cd build
    make install -j8 DESTDIR=${glibc_install} && cd .. && cd ..
  fi

  # 编译 busybox 
  if [ ! -d "busybox_install" ]; then
    mkdir -pv busybox_install && cd busybox-1.34.1
    make CONFIG_PREFIX=${busybox_install} install && cd ..
  fi

  # 编译 libgcc
  if [ ! -d "libgcc_install" ]; then
    mkdir -pv libgcc_install && cd gcc-7.5.0
    make install -j8 DESTDIR=${libgcc_install} && cd ..
  fi

  # 编译 binutils
  if [ ! -d "binutils_install" ]; then
    mkdir -pv binutils_install && cd binutils-2.36
    make install -j8 DESTDIR=${binutils_install} && cd ..
  fi  
  cd ..
  exit
fi

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

#GLIBC_SOURCE_URL=https://ftp.gnu.org/gnu/glibc/glibc-2.32.tar.bz2
GLIBC_SOURCE_URL=https://mirrors.ustc.edu.cn/gnu/glibc/glibc-2.32.tar.bz2
if [ ! -f "glibc-2.32.tar.bz2" ]; then
  wget $GLIBC_SOURCE_URL
fi

BUSYBOX_SOURCE_URL=https://busybox.net/downloads/busybox-1.34.1.tar.bz2
if [ ! -f "busybox-1.34.1.tar.bz2" ]; then 
  wget $BUSYBOX_SOURCE_URL 
fi

#GCC_SOURCE_URL=https://ftpmirror.gnu.org/gcc/gcc-7.5.0/gcc-7.5.0.tar.xz
GCC_SOURCE_URL=https://mirrors.ustc.edu.cn/gnu/gcc/gcc-7.5.0/gcc-7.5.0.tar.xz
if [ ! -f "gcc-7.5.0.tar.xz" ]; then 
  wget $GCC_SOURCE_URL 
fi

#BINUTILS_SOURCE_URL=https://ftp.gnu.org/gnu/binutils/binutils-2.36.tar.xz
BINUTILS_SOURCE_URL=https://mirrors.ustc.edu.cn/gnu/binutils/binutils-2.36.tar.xz
if [ ! -f "binutils-2.36.tar.xz" ]; then
  wget $BINUTILS_SOURCE_URL
fi

cd ..

#---------------------------------------------
#
# 解压源码 
#
#---------------------------------------------
mkdir -pv work

if [ ! -d "./work/linux-4.14.9" ]; then
  echo "unzip kernel source"
  tar xf source/linux-4.14.9.tar.xz -C work/
fi

if [ ! -d "./work/glibc-2.32" ]; then
  echo "unzip glibc source"
  tar xf source/glibc-2.32.tar.bz2 -C work/
fi

if [ ! -d "./work/busybox-1.34.1" ]; then
  echo "unzip busybox source"
  tar xf source/busybox-1.34.1.tar.bz2 -C work/
fi

if [ ! -d "./work/gcc-7.5.0" ]; then
  echo "unzip gcc source"
  tar xf source/gcc-7.5.0.tar.xz -C work/
fi

if [ ! -d "./work/binutils-2.36" ]; then
  echo "unzip binutils source"
  tar xf source/binutils-2.36.tar.xz -C work/
fi

#---------------------------------------------
#
# 编译源码 
#
#---------------------------------------------
cd work

# 编译内核, 最终所有模块都装到目录 /lib/modules/4.14.9
if [ ! -d "kernel_install" ]; then 
  mkdir -pv kernel_install && cd linux-4.14.9 && make mrproper && make x86_64_defconfig
  # Enable the VESA framebuffer for graphics support.
  sed -i "s/.*CONFIG_FB_VESA.*/CONFIG_FB_VESA=y/" .config 
  # 网络需要 TUN/TAP 驱动 [ Device Drivers ] ---> [ Network device support ] ---> [ Universal TUN/TAP device driver support ]
  make bzImage -j8
  #cd linux-4.14.9 && make x86_64_defconfig && make bzImage -j8 && make modules && make modules_install && cd ..
  make INSTALL_HDR_PATH=${kernel_install} headers_install -j8 && cp arch/x86_64/boot/bzImage ${kernel_install} && cd ..
fi

# 编译glibc
if [ ! -d "glibc_install" ]; then
  mkdir -pv glibc_install && cd glibc-2.32
  mkdir -pv build && cd build && make distclean
  ../configure --prefix=/usr \
    --with-headers=${kernel_install}/include \
    --enable-kernel=4.0.1 \
    --without-selinux \
    --disable-werror \
    --disable-werror \
    CFLAGS="$CFLAGS"
  make -j8 && make install -j8 DESTDIR=${glibc_install} && cd .. && cd ..
fi

# 编译 busybox 
if [ ! -d "busybox_install" ]; then
  mkdir -pv busybox_install && cd busybox-1.34.1 && make distclean && make defconfig
  # 静态编译 sed -i "s/# CONFIG_STATIC is not set/CONFIG_STATIC=y/g" .config
  sed -i "s|.*CONFIG_SYSROOT.*|CONFIG_SYSROOT=\"${glibc_install}\"|" .config
  sed -i "s|.*CONFIG_EXTRA_CFLAGS.*|CONFIG_EXTRA_CFLAGS=\"-I${kernel_install}/include -I${glibc_install}/include -L${glibc_install}/usr/lib64 $CFLAGS\"|" .config
  make busybox -j8 && make CONFIG_PREFIX=${busybox_install} install && cd ..
fi

# 编译 libgcc
if [ ! -d "libgcc_install" ]; then 
  mkdir -pv libgcc_install && cd gcc-7.5.0 && make distclean && rm ./config.cache
  ./contrib/download_prerequisites
  ./configure --prefix=/usr --enable-languages=c,c++ --disable-multilib --disable-static --disable-libquadmath --enable-shared
  CFLAGS="-L${glibc_install}/lib64 $CFLAGS" make -j8 && make install -j8 DESTDIR=${libgcc_install} && cd ..
fi

# 编译 binutils
if [ ! -d "binutils_install" ]; then
  mkdir -pv binutils_install && cd binutils-2.36 && make distclean
  ./configure --prefix=/usr
  CFLAGS="-L${glibc_install}/lib64 $CFLAGS" make -j8 && make install -j8 DESTDIR=${binutils_install} && cd ..
  cd ..
fi

cd ..

echo "Run the next script: 02_build_img.sh"
