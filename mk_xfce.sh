#!/bin/sh

# 预装工具
if [ -f "/usr/bin/apt" ]; then
  apt install intltool -y
fi

if [ -f "/usr/bin/yum" ]; then
  echo "xxx"
fi

#-----------------------------------------------
#
# 导入公共变量
#
#-----------------------------------------------
. ./common.sh

GLIB_SRC_URL=https://download.gnome.org/sources/glib/2.72/glib-2.72.3.tar.xz
XFCE_SRC_URL=https://archive.xfce.org/xfce/4.16/fat_tarballs/xfce-4.16.tar.bz2

#----------------------------
#
# 下载源码
#
#----------------------------
mkdir -pv source
cd source

XFCE_SRC_NAME=$(file_name ${XFCE_SRC_URL})
if [ ! -f ${XFCE_SRC_NAME} ]; then
  wget -c -t 0 $XFCE_SRC_URL
fi

cd ..

#---------------------------
#
# 解压源码
#
#---------------------------
mkdir -pv ${build_dir}

XFCE_SRC_DIR=${build_dir}"/"$(file_dirname ${XFCE_SRC_NAME} .tar.bz2)
if [ ! -d ${XFCE_SRC_DIR} ]; then
  echo "unzip ${XFCE_SRC_NAME} source code"
  tar xf source/${XFCE_SRC_NAME} -C ${build_dir} 
  echo $XFCE_SRC_DIR
  mkdir -pv $XFCE_SRC_DIR
  tar xf ${build_dir}/src/exo-4.16.0.tar.bz2 -C ${XFCE_SRC_DIR}
  tar xf ${build_dir}/src/thunar-4.16.0.tar.bz2 -C ${XFCE_SRC_DIR}
  tar xf ${build_dir}/src/xfce4-dev-tools-4.16.0.tar.bz2 -C ${XFCE_SRC_DIR}
  tar xf ${build_dir}/src/xfce4-settings-4.16.0.tar.bz2 -C ${XFCE_SRC_DIR}
  tar xf ${build_dir}/src/garcon-0.8.0.tar.bz2 -C ${XFCE_SRC_DIR}
  tar xf ${build_dir}/src/thunar-volman-4.16.0.tar.bz2 -C ${XFCE_SRC_DIR}
  tar xf ${build_dir}/src/xfce4-panel-4.16.0.tar.bz2 -C ${XFCE_SRC_DIR}
  tar xf ${build_dir}/src/xfconf-4.16.0.tar.bz2 -C ${XFCE_SRC_DIR}
  tar xf ${build_dir}/src/libxfce4ui-4.16.0.tar.bz2 -C ${XFCE_SRC_DIR}
  tar xf ${build_dir}/src/tumbler-4.16.0.tar.bz2 -C ${XFCE_SRC_DIR}
  tar xf ${build_dir}/src/xfce4-power-manager-4.16.0.tar.bz2 -C ${XFCE_SRC_DIR}
  tar xf ${build_dir}/src/xfdesktop-4.16.0.tar.bz2 -C ${XFCE_SRC_DIR}
  tar xf ${build_dir}/src/libxfce4util-4.16.0.tar.bz2 -C ${XFCE_SRC_DIR}
  tar xf ${build_dir}/src/xfce4-appfinder-4.16.0.tar.bz2 -C ${XFCE_SRC_DIR}
  tar xf ${build_dir}/src/xfce4-session-4.16.0.tar.bz2 -C ${XFCE_SRC_DIR}
  tar xf ${build_dir}/src/xfwm4-4.16.0.tar.bz2 -C ${XFCE_SRC_DIR}
  rm -rf ${build_dir}/src
fi

#---------------------------------------------
#
# 编译 xfce 
#
#---------------------------------------------
cd ${build_dir}

# 编译
if [ ! -d "xfce_install" ]; then
  mkdir -pv xfce_install && cd ${XFCE_SRC_DIR}

  echo $(pwd)
  
  cd exo-4.16.0 && make distclean && ./autogensh 
  ./configure ${CFGOPT}
  CFLAGS="-L${glibc_install}/lib64 $CFLAGS" make -j8 && make install -j8 DESTDIR=${build_dir}"/xfce_install" && cd ..
  
  cd thunar-4.16.0 && make distclean && ./autogensh 
  ./configure ${CFGOPT}
  CFLAGS="-L${glibc_install}/lib64 $CFLAGS" make -j8 && make install -j8 DESTDIR=${build_dir}"/xfce_install" && cd ..
  
  cd xfce4-dev-tools-4.16.0 && make distclean && ./autogensh 
  ./configure ${CFGOPT}
  CFLAGS="-L${glibc_install}/lib64 $CFLAGS" make -j8 && make install -j8 DESTDIR=${build_dir}"/xfce_install" && cd ..
  
  cd xfce4-settings-4.16.0 && make distclean && ./autogensh 
  ./configure ${CFGOPT}
  CFLAGS="-L${glibc_install}/lib64 $CFLAGS" make -j8 && make install -j8 DESTDIR=${build_dir}"/xfce_install" && cd ..

  cd garcon-0.8.0 && make distclean && ./autogensh 
  ./configure ${CFGOPT}
  CFLAGS="-L${glibc_install}/lib64 $CFLAGS" make -j8 && make install -j8 DESTDIR=${build_dir}"/xfce_install" && cd ..
  
  cd thunar-volman-4.16.0 && make distclean && ./autogensh 
  ./configure ${CFGOPT}
  CFLAGS="-L${glibc_install}/lib64 $CFLAGS" make -j8 && make install -j8 DESTDIR=${build_dir}"/xfce_install" && cd ..
  
  cd xfce4-panel-4.16.0 && make distclean && ./autogensh 
  ./configure ${CFGOPT}
  CFLAGS="-L${glibc_install}/lib64 $CFLAGS" make -j8 && make install -j8 DESTDIR=${build_dir}"/xfce_install" && cd ..
  
  cd xfconf-4.16.0 && make distclean && ./autogensh 
  ./configure ${CFGOPT}
  CFLAGS="-L${glibc_install}/lib64 $CFLAGS" make -j8 && make install -j8 DESTDIR=${build_dir}"/xfce_install" && cd ..
  
  cd libxfce4ui-4.16.0 && make distclean && ./autogensh 
  ./configure ${CFGOPT}
  CFLAGS="-L${glibc_install}/lib64 $CFLAGS" make -j8 && make install -j8 DESTDIR=${build_dir}"/xfce_install" && cd ..
  
  cd tumbler-4.16.0 && make distclean && ./autogensh 
  ./configure ${CFGOPT}
  CFLAGS="-L${glibc_install}/lib64 $CFLAGS" make -j8 && make install -j8 DESTDIR=${build_dir}"/xfce_install" && cd ..
  
  cd xfce4-power-manager-4.16.0 && make distclean && ./autogensh 
  ./configure ${CFGOPT}
  CFLAGS="-L${glibc_install}/lib64 $CFLAGS" make -j8 && make install -j8 DESTDIR=${build_dir}"/xfce_install" && cd ..
  
  cd xfdesktop-4.16.0 && make distclean && ./autogensh 
  ./configure ${CFGOPT}
  CFLAGS="-L${glibc_install}/lib64 $CFLAGS" make -j8 && make install -j8 DESTDIR=${build_dir}"/xfce_install" && cd ..
  
  cd libxfce4util-4.16.0 && make distclean && ./autogensh 
  ./configure ${CFGOPT}
  CFLAGS="-L${glibc_install}/lib64 $CFLAGS" make -j8 && make install -j8 DESTDIR=${build_dir}"/xfce_install" && cd ..
  
  cd xfce4-appfinder-4.16.0 && make distclean && ./autogensh 
  ./configure ${CFGOPT}
  CFLAGS="-L${glibc_install}/lib64 $CFLAGS" make -j8 && make install -j8 DESTDIR=${build_dir}"/xfce_install" && cd ..
  
  cd xfce4-session-4.16.0 && make distclean && ./autogensh 
  ./configure ${CFGOPT}
  CFLAGS="-L${glibc_install}/lib64 $CFLAGS" make -j8 && make install -j8 DESTDIR=${build_dir}"/xfce_install" && cd ..
  
  cd xfwm4-4.16.0 && make distclean && ./autogensh 
  ./configure ${CFGOPT}
  CFLAGS="-L${glibc_install}/lib64 $CFLAGS" make -j8 && make install -j8 DESTDIR=${build_dir}"/xfce_install" && cd ..
fi

cd ..
