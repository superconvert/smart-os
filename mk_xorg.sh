#!/bin/sh

# 预装工具
apt install xutils-dev libtool m4 pkg-config xtrans-dev libpixman-1-dev libdrm-dev libx11-dev libgl-dev libgcrypt-dev libxkbfile-dev libxfont-dev libpciaccess-dev libepoxy-dev libgbm-dev libegl1-mesa-dev -y

#-----------------------------------------------
#
# 导入公共变量
#
#-----------------------------------------------
. ./common.sh

XORG_SRC_URL=https://www.x.org/archive/individual/xserver/xorg-server-1.20.11.tar.bz2

#----------------------------
#
# 下载源码
#
#----------------------------
mkdir -pv source
cd source

XORG_SRC_NAME=$(file_name ${XORG_SRC_URL})
if [ ! -f ${XORG_SRC_NAME} ]; then
  wget $XORG_SRC_URL
fi

cd ..

#---------------------------
#
# 解压源码
#
#---------------------------
mkdir -pv ${build_dir}

XORG_SRC_DIR=${build_dir}"/"$(file_dirname ${XORG_SRC_NAME} .tar.bz2)
if [ ! -d ${XORG_SRC_DIR} ]; then
  echo "unzip ${XORG_SRC_NAME} source code"
  tar xf source/${XORG_SRC_NAME} -C ${build_dir}
fi

#---------------------------------------------
#
# 编译源码 
#
#---------------------------------------------
cd ${build_dir}

# 编译
if [ ! -d "xorg_install" ]; then
  mkdir -pv xorg_install && cd ${XORG_SRC_DIR} && make distclean && ./autogensh 
  ./configure --prefix=/usr
  CFLAGS="-L${glibc_install}/lib64 $CFLAGS" make -j8 && make install -j8 DESTDIR=${xorg_install} && cd ..
fi

cd ..
