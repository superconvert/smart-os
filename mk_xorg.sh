#!/bin/sh

# 预装工具
if [ -f "/usr/bin/apt" ]; then
  apt install git autoconf libtool gcc g++ gettext pkg-config m4 python-xcbgen -y
  apt install xutils-dev xtrans-dev libpixman-1-dev libdrm-dev libx11-dev libgl-dev libgcrypt-dev libxkbfile-dev libxfont-dev libpciaccess-dev libepoxy-dev libgbm-dev libegl1-mesa-dev -y
fi

if [ -f "/usr/bin/yum" ]; then
  yum install git autoconf libtool gcc g++ gettext pkg-config m4 xcb-util -y
  yum install xutils-dev xtrans-dev libpixman-1-dev libdrm-dev libx11-dev libgl-dev libgcrypt-dev libxkbfile-dev libxfont-dev libpciaccess-dev libepoxy-dev libgbm-dev libegl1-mesa-dev -y
fi

#-----------------------------------------------
#
# 导入公共变量
#
#-----------------------------------------------
. ./common.sh

xserver_dir=${xorg_install}"/xclient"
xclient_dir=${xorg_install}"/xclient"
XSVR_SRC_URL=https://www.x.org/archive/individual/xserver/xorg-server-1.20.11.tar.bz2

#----------------------------
#
# 下载源码
#
#----------------------------
mkdir -pv source
cd source
XSVR_SRC_NAME=$(download_src ${XSVR_SRC_URL})
cd ..

#---------------------------
#
# 解压源码
#
#---------------------------
mkdir -pv ${build_dir}
XSVR_SRC_DIR=$(unzip_src ".tar.bz2" ${XSVR_SRC_NAME}); echo "unzip ${XSVR_SRC_NAME} source code"

#---------------------------------------------
#
# 编译 xserver 
#
#---------------------------------------------
cd ${build_dir}

# 编译
if [ ! -d "xorg_install" ]; then
  mkdir -pv xorg_install && cd ${XSVR_SRC_DIR} && make distclean && ./autogensh 
  ./configure ${CFGOPT}
  CFLAGS="-L${glibc_install}/lib64 $CFLAGS" make -j8 && make install -j8 DESTDIR=${xserver_dir} && cd ..
fi

#--------------------------------------------
#
# 编译 xclient
#
#--------------------------------------------

# 解决 libxcb 编译问题
mkdir -pv ${xclient_dir}/usr/share/aclocal
mkdir -pv ${xclient_dir}/usr/local/share/aclocal

export CFGOPT="--prefix=/usr --with-sysroot=${xclient_dir} --with-build-sysroot=${xclient_dir}"
export CFLAGS="-I${xclient_dir}/usr/include"
export LDFLAGS="-L${xclient_dir}/usr/lib"
export ACLOCAL="aclocal -I /usr/share/aclocal -I ${xclient_dir}/usr/share/aclocal -I ${xclient_dir}/usr/local/share/aclocal"

# 解决 libxcb 编译问题
export PKG_CONFIG_SYSROOT_DIR="${xclient_dir}"
export PKG_CONFIG_PATH="${xclient_dir}/usr/share/pkgconfig:${xclient_dir}/usr/lib/pkgconfig:${xclient_dir}/usr/local/lib/pkgconfig"
export XCBPROTO_XCBINCLUDEDIR="${xclient_dir}/usr/share/xcb"
export PYTHONPATH="${xclient_dir}/usr/lib/python2.7/dist-packages"

# 采用 cache 机制，禁止每次都重新下载源码
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
  #rm -rf macros xcbproto xorgproto libxau libxcb libxtrans libx11 libice libsm libxt libxext libxmu libxpm libxaw libxdmcp xload
  rm -rf libxcb libxtrans libx11 libice libsm libxt libxext libxmu libxpm libxaw libxdmcp xload
  tar zxf xclient.tar.gz 
fi

#---------------------------
# 公共编译函数定义
#---------------------------
xorg_build() {
  local name=$1
  echo "${GREEN}build ${name} begin${NC}" && cd ${name}
  if [ "${name}" = "libxcb" ]; then
    # 解决 libxcb 编译问题
    sed -i "8 i reload(sys)" src/c_client.py
    sed -i "9 i sys.setdefaultencoding('utf8')" src/c_client.py
  fi
  ./autogen.sh && ./configure ${CFGOPT}
  make -j8 && make install DESTDIR=${xclient_dir} && echo "${GREEN}build ${name} success${NC}"
  cd .. && sleep 1
}

xorg_build macros
xorg_build xcbproto
xorg_build xorgproto
xorg_build libxau
xorg_build libxcb
xorg_build libxtrans
xorg_build libx11
xorg_build libice
xorg_build libsm
xorg_build libxt
xorg_build libxext
xorg_build libxmu
xorg_build libxpm
xorg_build libxaw
xorg_build libxdmcp
xorg_build xload

cd ..
