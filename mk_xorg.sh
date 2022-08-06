#!/bin/sh

# 预装工具
apt install git autoconf libtool gcc g++ gettext pkg-config m4 -y
apt install xutils-dev xtrans-dev libpixman-1-dev libdrm-dev libx11-dev libgl-dev libgcrypt-dev libxkbfile-dev libxfont-dev libpciaccess-dev libepoxy-dev libgbm-dev libegl1-mesa-dev -y

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
  wget -c -t 0 $XORG_SRC_URL
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
xserver_dir=${xorg_install}"/xclient"
xclient_dir=${xorg_install}"/xclient"

# 编译
if [ ! -d "xorg_install" ]; then
  mkdir -pv xorg_install && cd ${XORG_SRC_DIR} && make distclean && ./autogensh 
  ./configure ${CFGOPT}
  CFLAGS="-L${glibc_install}/lib64 $CFLAGS" make -j8 && make install -j8 DESTDIR=${xserver_dir} && cd ..
fi

#--------------------------------------------
#
# 编译 xclient
#
#--------------------------------------------
export CFGOPT="--prefix=/usr --with-sysroot=${xorg_install}/xclient --with-build-sysroot=${xorg_install}/xclient"
export CFLAGS="-I${xorg_install}/xclient/usr/include"
export LDFLAGS="-L${xorg_install}/xclient/usr/lib"
export ACLOCAL="aclocal -I /usr/share/aclocal:${xorg_install}/xclient/usr/share/aclocal"
export PKG_CONFIG_PATH="${xorg_install}/xclient/usr/share/pkgconfig:${xorg_install}/xclient/usr/lib/pkgconfig"

if [ ! -f xclient.tar.gz ]; then
  git clone https://gitlab.freedesktop.org/xorg/util/macros.git
  git clone https://gitlab.freedesktop.org/xorg/proto/xcbproto.git
  git clone https://gitlab.freedesktop.org/xorg/proto/xorgproto.git
  git clone https://gitlab.freedesktop.org/xorg/lib/libxau.git
  git clone https://gitlab.freedesktop.org/xorg/lib/libxcb.git
  git clone https://gitlab.freedesktop.org/xorg/lib/libxtrans.git
  git clone https://gitlab.freedesktop.org/xorg/lib/libx11.git
  git clone https://gitlab.freedesktop.org/xorg/lib/libice.git
  git clone https://gitlab.freedesktop.org/xorg/lib/libsm.git
  git clone https://gitlab.freedesktop.org/xorg/lib/libxt.git
  git clone https://gitlab.freedesktop.org/xorg/lib/libxext.git
  git clone https://gitlab.freedesktop.org/xorg/lib/libxmu.git
  git clone https://gitlab.freedesktop.org/xorg/lib/libxpm.git
  git clone https://gitlab.freedesktop.org/xorg/lib/libxaw.git
  git clone https://gitlab.freedesktop.org/xorg/lib/libxdmcp.git
  git clone https://gitlab.freedesktop.org/xorg/app/xload.git
  tar zcf xclient.tar.gz macros xcbproto xorgproto libxau libxcb libxtrans libx11 libice libsm libxt libxext libxmu libxpm libxaw libxdmcp xload
else
  rm -rf macros xcbproto xorgproto libxau libxcb libxtrans libx11 libice libsm libxt libxext libxmu libxpm libxaw libxdmcp xload
  tar zxf xclient.tar.gz 
fi

echo "${GREEN}build macros begin${NC}"
cd macros
./autogen.sh && ./configure ${CFGOPT} && make -j8 && make install -j8 DESTDIR=${xclient_dir} && echo "${GREEN}build macros success${NC}"
cd .. && sleep 1

echo "${GREEN}build xcbproto begin${NC}"
cd xcbproto
./autogen.sh && ./configure ${CFGOPT} && make -j8 && make install -j8 DESTDIR=${xclient_dir} && echo "${GREEN}build xcbproto success${NC}"
cd .. && sleep 1

echo "${GREEN}build xorgproto begin${NC}"
cd xorgproto
./autogen.sh && ./configure ${CFGOPT} && make -j8 && make install -j8 DESTDIR=${xclient_dir} && echo "${GREEN}build xorgproto success${NC}"
cd .. && sleep 1

echo "${GREEN}build libxau begin${NC}"
cd libxau
./autogen.sh && ./configure ${CFGOPT} && make -j8 && make install -j8 DESTDIR=${xclient_dir} && echo "${GREEN}build libxau success${NC}"
cd .. && sleep 1

echo "${GREEN}build libxcb begin${NC}"
cd libxcb
./autogen.sh && ./configure ${CFGOPT} && make -j8 && make install -j8 DESTDIR=${xclient_dir} && echo "${GREEN}build libxcb success${NC}"
cd .. && sleep 1

echo "${GREEN}build libxtrans begin${NC}"

cd libxtrans
./autogen.sh && ./configure ${CFGOPT} && make -j8 && make install -j8 DESTDIR=${xclient_dir} && echo "${GREEN}build libxtrans success${NC}"
cd .. && sleep 1

echo "${GREEN}build libx11 begin${NC}"
cd libx11
./autogen.sh && ./configure ${CFGOPT} && make -j8 && make install -j8 DESTDIR=${xclient_dir} && echo "${GREEN}build libx11 success${NC}"
cd .. && sleep 1

echo "${GREEN}build libice begin${NC}"
cd libice
./autogen.sh && ./configure ${CFGOPT} && make -j8 && make install -j8 DESTDIR=${xclient_dir} && echo "${GREEN}build libice success${NC}"
cd .. && sleep 1

echo "${GREEN}build libsm begin${NC}"

cd libsm
./autogen.sh && ./configure ${CFGOPT} && make -j8 && make install -j8 DESTDIR=${xclient_dir} && echo "${GREEN}build libsm success${NC}"
cd .. && sleep 1

echo "${GREEN}build libxt begin${NC}"

cd libxt
./autogen.sh && ./configure ${CFGOPT} && make -j8 && make install -j8 DESTDIR=${xclient_dir} && echo "${GREEN}build libxt success${NC}"
cd .. && sleep 1

echo "${GREEN}build libxext begin${NC}"

cd libxext
./autogen.sh && ./configure ${CFGOPT} && make -j8 && make install -j8 DESTDIR=${xclient_dir} && echo "${GREEN}build libxext success${NC}"
cd .. && sleep 1

echo "${GREEN}build libxmu begin${NC}"

cd libxmu
./autogen.sh && ./configure ${CFGOPT} && make -j8 && make install -j8 DESTDIR=${xclient_dir} && echo "${GREEN}build libxmu success${NC}"
cd .. && sleep 1

echo "${GREEN}build libxpm begin${NC}"

cd libxpm
./autogen.sh && ./configure ${CFGOPT} && make -j8 && make install -j8 DESTDIR=${xclient_dir} && echo "${GREEN}build libxpm success${NC}"
cd .. && sleep 1

echo "${GREEN}build libxaw begin${NC}"

cd libxaw
./autogen.sh && ./configure ${CFGOPT} && make -j8 && make install -j8 DESTDIR=${xclient_dir} && echo "${GREEN}build libxaw success${NC}"
cd .. && sleep 1

echo "${GREEN}build libxdmcp begin${NC}"

cd libxdmcp
./autogen.sh && ./configure ${CFGOPT} && make -j8 && make install -j8 DESTDIR=${xclient_dir} && echo "${GREEN}build libxdmcp success${NC}"
cd .. && sleep 1

echo "${GREEN}build xload begin${NC}"

cd xload
./autogen.sh && ./configure ${CFGOPT} && make -j8 && make install -j8 DESTDIR=${xclient_dir} && echo "${GREEN}build xload success${NC}"
cd .. && sleep 1

cd ..
