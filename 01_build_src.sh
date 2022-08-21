#!/bin/sh

#-----------------------------------------------
#
# 导入公共变量
#
#-----------------------------------------------
. ./common.sh

#LINUX_SRC_URL=https://kernel.org/pub/linux/kernel/v4.x/linux-4.14.9.tar.xz
LINUX_SRC_URL=https://mirror.bjtu.edu.cn/kernel/linux/kernel/v4.x/linux-4.14.9.tar.xz
#GLIBC_SRC_URL=https://ftp.gnu.org/gnu/glibc/glibc-2.32.tar.bz2
GLIBC_SRC_URL=https://mirrors.ustc.edu.cn/gnu/glibc/glibc-2.32.tar.bz2
BUSYBOX_SRC_URL=https://busybox.net/downloads/busybox-1.34.1.tar.bz2
#GCC_SRC_URL=https://ftpmirror.gnu.org/gcc/gcc-7.5.0/gcc-7.5.0.tar.xz
GCC_SRC_URL=https://mirrors.ustc.edu.cn/gnu/gcc/gcc-7.5.0/gcc-7.5.0.tar.xz
#BINUTILS_SRC_URL=https://ftp.gnu.org/gnu/binutils/binutils-2.36.tar.xz
BINUTILS_SRC_URL=https://mirrors.ustc.edu.cn/gnu/binutils/binutils-2.36.tar.xz

export CFLAGS="-Os -s -fno-stack-protector -fomit-frame-pointer -U_FORTIFY_SOURCE"

#----------------------------------------------
#
# 下载源码
#
#----------------------------------------------
mkdir -pv source
cd source
LINUX_SRC_NAME=$(download_src ${LINUX_SRC_URL})
GLIBC_SRC_NAME=$(download_src ${GLIBC_SRC_URL})
BUSYBOX_SRC_NAME=$(download_src ${BUSYBOX_SRC_URL})
GCC_SRC_NAME=$(download_src ${GCC_SRC_URL})
BINUTILS_SRC_NAME=$(download_src ${BINUTILS_SRC_URL})
cd ..

#---------------------------------------------
#
# 解压源码 
#
#---------------------------------------------
mkdir -pv ${build_dir} 

LINUX_SRC_DIR=$(unzip_src ".tar.xz" ${LINUX_SRC_NAME}); echo "unzip ${LINUX_SRC_NAME} source code"
GLIBC_SRC_DIR=$(unzip_src ".tar.bz2" ${GLIBC_SRC_NAME}); echo "unzip ${GLIBC_SRC_NAME} source code"
BUSYBOX_SRC_DIR=$(unzip_src ".tar.bz2" ${BUSYBOX_SRC_NAME}); echo "unzip ${BUSYBOX_SRC_NAME} source code"
GCC_SRC_DIR=$(unzip_src ".tar.xz" ${GCC_SRC_NAME}); echo "unzip ${GCC_SRC_NAME} source code"
BINUTILS_SRC_DIR=$(unzip_src ".tar.xz" ${BINUTILS_SRC_NAME}); echo "unzip ${BINUTILS_SRC_NAME} source code"

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
  cd ${build_dir} 
  rm -rf linux_install glibc_install busybox_install gcc_install binutils_install
  # 编译内核, 最终所有模块都装到目录 /lib/modules/4.14.9
  if [ ! -d "linux_install" ]; then
    mkdir -pv linux_install && cd ${LINUX_SRC_DIR} 
    make INSTALL_HDR_PATH=${linux_install} headers_install -j8 && cp arch/x86_64/boot/bzImage ${linux_install} && cd ..
  fi

  # 编译glibc
  if [ ! -d "glibc_install" ]; then
    mkdir -pv glibc_install && cd ${GLIBC_SRC_DIR} 
    mkdir -pv build && cd build
    make install -j8 DESTDIR=${glibc_install} && cd .. && cd ..
  fi

  # 编译 busybox 
  if [ ! -d "busybox_install" ]; then
    mkdir -pv busybox_install && cd ${BUSYBOX_SRC_DIR}
    make CONFIG_PREFIX=${busybox_install} install && cd ..
  fi

  # 编译 libgcc
  if [ ! -d "gcc_install" ]; then
    mkdir -pv gcc_install && cd ${GCC_SRC_DIR}
    make install -j8 DESTDIR=${gcc_install} && cd ..
  fi

  # 编译 binutils
  if [ ! -d "binutils_install" ]; then
    mkdir -pv binutils_install && cd ${BINUTILS_SRC_DIR}
    make install -j8 DESTDIR=${binutils_install} && cd ..
  fi  
  cd ..
  exit
fi


#---------------------------------------------
#
# 编译源码 
#
#---------------------------------------------
cd ${build_dir}

# 编译内核, 最终所有模块都装到目录 /lib/modules/4.14.9
if [ ! -d "linux_install" ]; then 
  mkdir -pv linux_install && cd ${LINUX_SRC_DIR} && make mrproper && make x86_64_defconfig
  # Enable the VESA framebuffer for graphics support.
  sed -i "s/.*CONFIG_FB_VESA.*/CONFIG_FB_VESA=y/" .config 
  # 网络需要 TUN/TAP 驱动 [ Device Drivers ] ---> [ Network device support ] ---> [ Universal TUN/TAP device driver support ]
  make bzImage -j8
  #cd linux-4.14.9 && make x86_64_defconfig && make bzImage -j8 && make modules && make modules_install && cd ..
  make INSTALL_HDR_PATH=${linux_install} headers_install -j8 && cp arch/x86_64/boot/bzImage ${linux_install} && cd ..
fi

# 编译glibc
if [ ! -d "glibc_install" ]; then
  mkdir -pv glibc_install && cd ${GLIBC_SRC_DIR}
  mkdir -pv build && cd build && make distclean
  ../configure --prefix=/usr \
    --with-headers=${linux_install}/include \
    --enable-kernel=4.0.1 \
    --without-selinux \
    --disable-werror \
    --disable-werror \
    CFLAGS="$CFLAGS"
  make -j8 && make install -j8 DESTDIR=${glibc_install} && cd .. && cd ..
fi

# 编译 busybox 
if [ ! -d "busybox_install" ]; then
  mkdir -pv busybox_install && cd ${BUSYBOX_SRC_DIR} && make distclean && make defconfig
  # 静态编译 sed -i "s/# CONFIG_STATIC is not set/CONFIG_STATIC=y/g" .config
  sed -i "s|.*CONFIG_SYSROOT.*|CONFIG_SYSROOT=\"${glibc_install}\"|" .config
  sed -i "s|.*CONFIG_EXTRA_CFLAGS.*|CONFIG_EXTRA_CFLAGS=\"-I${linux_install}/include -I${glibc_install}/include -L${glibc_install}/usr/lib64 $CFLAGS\"|" .config
  make busybox -j8 && make CONFIG_PREFIX=${busybox_install} install && cd ..
fi

# 编译 gcc
if [ ! -d "gcc_install" ]; then 
  mkdir -pv gcc_install && cd ${GCC_SRC_DIR} && make distclean && rm ./config.cache
  ./contrib/download_prerequisites
  ./configure --prefix=/usr --enable-languages=c,c++ --disable-multilib --disable-static --disable-libquadmath --enable-shared
  CFLAGS="-L${glibc_install}/lib64 $CFLAGS" make -j8 && make install -j8 DESTDIR=${gcc_install} && cd ..
fi

# 编译 binutils
if [ ! -d "binutils_install" ]; then
  mkdir -pv binutils_install && cd ${BINUTILS_SRC_DIR} && make distclean
  ./configure --prefix=/usr
  CFLAGS="-L${glibc_install}/lib64 $CFLAGS" make -j8 && make install -j8 DESTDIR=${binutils_install} && cd ..
fi

cd ..

# 编译 xorg [ no same time with xfce ]
if [ "${with_xorg}" = true ]; then
  ./mk_xorg.sh
fi

# 编译 xfce [ no same time with xorg ]
if [ "${with_xfce}" = true ]; then
  ./mk_xfce.sh
fi

echo "Run the next script: 02_build_img.sh"
