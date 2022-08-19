#!/bin/sh

#set -e
# 所有的编译基于 Ubuntu 18.04.6 LTS 编译通过, 其它系统请自行调整脚本

# 预装工具
if [ -f "/usr/bin/apt" ]; then
  apt install cmake gperf bison flex intltool libtool libxml2-utils gobject-introspection gtk-doc-tools libgirepository1.0-dev python3.8-dev python3.8-dbg python3-pip python-docutils libatk1.0-dev libxrender-dev libsm-dev libxext-dev libpng-dev libthai-dev libxkbcommon-dev libpcre2-dev libgudev-1.0-dev libnotify-dev libupower-glib-dev libstartup-notification0-dev -y
  # 安装 OpenGL
  apt-get install libgl1-mesa-dev libglu1-mesa-dev libglut-dev -y
  # 安装 gstreamer
  apt-get install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-doc gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio -y
  # gtk+ 编译
  apt install libcups2-dev libxrandr-dev libxi-dev libatk-bridge2.0-dev libxinerama-dev libvulkan-dev -y
  # xfce 编译
  apt install x11-xserver-utils libxcb-util-dev libudev-dev -y
fi

if [ -f "/usr/bin/yum" ]; then
  echo "xxx"
fi

# undefined symbol: Py_InitModule4_64 需要安装高版本的 python3.8-dbg

pip3 install ninja
pip3 install meson
pip3 install gi-docgen

#-----------------------------------------------
#
# 导入公共变量
#
#-----------------------------------------------
. ./common.sh

GETTEXT_SRC_URL=https://ftp.gnu.org/pub/gnu/gettext/gettext-0.21.tar.gz
LIBFFI_SRC_URL=https://github.com/libffi/libffi/releases/download/v3.4.2/libffi-3.4.2.tar.gz
LIBMNT_SRC_URL=https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v2.36/util-linux-2.36.tar.xz
GLIB_SRC_URL=https://download.gnome.org/sources/glib/2.62/glib-2.62.0.tar.xz
PIXMAN_SRC_URL=https://www.cairographics.org/releases/pixman-0.40.0.tar.gz
CAIRO_SRC_URL=https://www.cairographics.org/releases/cairo-1.16.0.tar.xz
FREETYPE_SRC_URL=https://nchc.dl.sourceforge.net/project/freetype/freetype2/2.12.0/freetype-2.12.0.tar.xz
FONTCFG_SRC_URL=https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.13.96.tar.xz
HARFBUZZ_SRC_URL=https://github.com/harfbuzz/harfbuzz/releases/download/5.1.0/harfbuzz-5.1.0.tar.xz
FRIBIDI_SRC_URL=https://github.com/fribidi/fribidi/releases/download/v1.0.12/fribidi-1.0.12.tar.xz
PANGO_SRC_URL=https://download.gnome.org/sources/pango/1.48/pango-1.48.9.tar.xz
GDKPIXBUF_SRC_URL=https://gitlab.gnome.org/GNOME/gdk-pixbuf/-/archive/2.42.8/gdk-pixbuf-2.42.8.tar.gz
LIBEPOXY_SRC_URL=https://github.com/anholt/libepoxy/archive/refs/tags/1.5.10.tar.gz
GRAPHENE_SRC_URL=https://github.com/ebassi/graphene/archive/refs/tags/1.10.8.tar.gz
GOBJINTROSPE_SRC_URL=https://github.com/GNOME/gobject-introspection/archive/refs/tags/1.72.0.tar.gz
STARTUPNOTI_SRC_URL=http://www.freedesktop.org/software/startup-notification/releases/startup-notification-0.12.tar.gz
WAYLANDPROT_SRC_URL=https://gitlab.freedesktop.org/wayland/wayland-protocols/-/archive/1.25/wayland-protocols-1.25.tar.gz
LIBGUDEV_SRC_URL=https://gitlab.gnome.org/GNOME/libgudev/-/archive/236/libgudev-236.tar.gz
UPOWER_SRC_URL=https://gitlab.freedesktop.org/upower/upower/-/archive/v1.90.0/upower-v1.90.0.tar.gz
LIBWNCK_SRC_URL=https://download.gnome.org/sources/libwnck/3.36/libwnck-3.36.0.tar.xz
GTKX_SRC_URL=https://download.gnome.org/sources/gtk%2B/3.24/gtk%2B-3.24.9.tar.xz
XFCE_SRC_URL=https://archive.xfce.org/xfce/4.16/fat_tarballs/xfce-4.16.tar.bz2

#----------------------------
#
# 下载源码
#
#----------------------------
mkdir -pv source
cd source

LIBFFI_SRC_NAME=$(file_name ${LIBFFI_SRC_URL})
if [ ! -f ${LIBFFI_SRC_NAME} ]; then
  wget -c -t 0 $LIBFFI_SRC_URL
fi

LIBMNT_SRC_NAME=$(file_name ${LIBMNT_SRC_URL})
if [ ! -f ${LIBMNT_SRC_NAME} ]; then
  wget -c -t 0 $LIBMNT_SRC_URL
fi

GLIB_SRC_NAME=$(file_name ${GLIB_SRC_URL})
if [ ! -f ${GLIB_SRC_NAME} ]; then
  wget -c -t 0 $GLIB_SRC_URL
fi

PIXMAN_SRC_NAME=$(file_name ${PIXMAN_SRC_URL})
if [ ! -f ${PIXMAN_SRC_NAME} ]; then
  wget -c -t 0 $PIXMAN_SRC_URL
fi

FREETYPE_SRC_NAME=$(file_name ${FREETYPE_SRC_URL})
if [ ! -f ${FREETYPE_SRC_NAME} ]; then
  wget -c -t 0 $FREETYPE_SRC_URL
fi

CAIRO_SRC_NAME=$(file_name ${CAIRO_SRC_URL})
if [ ! -f ${CAIRO_SRC_NAME} ]; then
  wget -c -t 0 $CAIRO_SRC_URL
fi

FONTCFG_SRC_NAME=$(file_name ${FONTCFG_SRC_URL})
if [ ! -f ${FONTCFG_SRC_NAME} ]; then
  wget -c -t 0 $FONTCFG_SRC_URL
fi

HARFBUZZ_SRC_NAME=$(file_name ${HARFBUZZ_SRC_URL})
if [ ! -f ${HARFBUZZ_SRC_NAME} ]; then
  wget -c -t 0 $HARFBUZZ_SRC_URL
fi

FRIBIDI_SRC_NAME=$(file_name ${FRIBIDI_SRC_URL})
if [ ! -f ${FRIBIDI_SRC_NAME} ]; then
  wget -c -t 0 $FRIBIDI_SRC_URL
fi

PANGO_SRC_NAME=$(file_name ${PANGO_SRC_URL})
if [ ! -f ${PANGO_SRC_NAME} ]; then
  wget -c -t 0 $PANGO_SRC_URL
fi

GDKPIXBUF_SRC_NAME=$(file_name ${GDKPIXBUF_SRC_URL})
if [ ! -f ${GDKPIXBUF_SRC_NAME} ]; then
  wget -c -t 0 $GDKPIXBUF_SRC_URL
fi

LIBEPOXY_SRC_NAME="libepoxy-"$(file_name ${LIBEPOXY_SRC_URL})
if [ ! -f ${LIBEPOXY_SRC_NAME} ]; then
  wget -c -t 0 $LIBEPOXY_SRC_URL -O $LIBEPOXY_SRC_NAME
fi

GRAPHENE_SRC_NAME="graphene-"$(file_name ${GRAPHENE_SRC_URL})
if [ ! -f ${GRAPHENE_SRC_NAME} ]; then
  wget -c -t 0 $GRAPHENE_SRC_URL -O $GRAPHENE_SRC_NAME
fi

GETTEXT_SRC_NAME=$(file_name ${GETTEXT_SRC_URL})
if [ ! -f ${GETTEXT_SRC_NAME} ]; then
  wget -c -t 0 $GETTEXT_SRC_URL
fi

WAYLANDPROT_SRC_NAME=$(file_name ${WAYLANDPROT_SRC_URL})
if [ ! -f ${WAYLANDPROT_SRC_NAME} ]; then
  wget -c -t 0 $WAYLANDPROT_SRC_URL
fi

STARTUPNOTI_SRC_NAME=$(file_name ${STARTUPNOTI_SRC_URL})
if [ ! -f ${STARTUPNOTI_SRC_NAME} ]; then
  wget -c -t 0 $STARTUPNOTI_SRC_URL
fi

LIBGUDEV_SRC_NAME=$(file_name ${LIBGUDEV_SRC_URL})
if [ ! -f ${LIBGUDEV_SRC_NAME} ]; then
  wget -c -t 0 $LIBGUDEV_SRC_URL
fi

UPOWER_SRC_NAME=$(file_name ${UPOWER_SRC_URL})
if [ ! -f ${UPOWER_SRC_NAME} ]; then
  wget -c -t 0 $UPOWER_SRC_URL
fi

GOBJINTROSPE_SRC_NAME="gobject-introspection-"$(file_name ${GOBJINTROSPE_SRC_URL})
if [ ! -f ${GOBJINTROSPE_SRC_NAME} ]; then
  wget -c -t 0 $GOBJINTROSPE_SRC_URL -O $GOBJINTROSPE_SRC_NAME
fi

LIBWNCK_SRC_NAME=$(file_name ${LIBWNCK_SRC_URL})
if [ ! -f ${LIBWNCK_SRC_NAME} ]; then
  wget -c -t 0 $LIBWNCK_SRC_URL
fi

GTKX_SRC_NAME=$(echo $(file_name ${GTKX_SRC_URL}) | sed 's/%2B/+/')
if [ ! -f ${GTKX_SRC_NAME} ]; then
  wget -c -t 0 $GTKX_SRC_URL
fi

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

LIBFFI_SRC_DIR=${build_dir}"/"$(file_dirname ${LIBFFI_SRC_NAME} .tar.gz)
if [ ! -d ${LIBFFI_SRC_DIR} ]; then
  echo "unzip ${LIBFFI_SRC_NAME} source code" && tar xf source/${LIBFFI_SRC_NAME} -C ${build_dir}
fi

LIBMNT_SRC_DIR=${build_dir}"/"$(file_dirname ${LIBMNT_SRC_NAME} .tar.xz)
if [ ! -d ${LIBMNT_SRC_DIR} ]; then
  echo "unzip ${LIBMNT_SRC_NAME} source code" && tar xf source/${LIBMNT_SRC_NAME} -C ${build_dir}
fi

GLIB_SRC_DIR=${build_dir}"/"$(file_dirname ${GLIB_SRC_NAME} .tar.xz)
if [ ! -d ${GLIB_SRC_DIR} ]; then
  echo "unzip ${GLIB_SRC_NAME} source code" && tar xf source/${GLIB_SRC_NAME} -C ${build_dir}
fi

PIXMAN_SRC_DIR=${build_dir}"/"$(file_dirname ${PIXMAN_SRC_NAME} .tar.gz)
if [ ! -d ${PIXMAN_SRC_DIR} ]; then
  echo "unzip ${PIXMAN_SRC_NAME} source code" && tar xf source/${PIXMAN_SRC_NAME} -C ${build_dir}
fi

FREETYPE_SRC_DIR=${build_dir}"/"$(file_dirname ${FREETYPE_SRC_NAME} .tar.xz)
if [ ! -d ${FREETYPE_SRC_DIR} ]; then
  echo "unzip ${FREETYPE_SRC_NAME} source code" && tar xf source/${FREETYPE_SRC_NAME} -C ${build_dir}
fi

CAIRO_SRC_DIR=${build_dir}"/"$(file_dirname ${CAIRO_SRC_NAME} .tar.xz)
if [ ! -d ${CAIRO_SRC_DIR} ]; then
  echo "unzip ${CAIRO_SRC_NAME} source code" && tar xf source/${CAIRO_SRC_NAME} -C ${build_dir}
fi

FONTCFG_SRC_DIR=${build_dir}"/"$(file_dirname ${FONTCFG_SRC_NAME} .tar.xz)
if [ ! -d ${FONTCFG_SRC_DIR} ]; then
  echo "unzip ${FONTCFG_SRC_NAME} source code" && tar xf source/${FONTCFG_SRC_NAME} -C ${build_dir}
fi

HARFBUZZ_SRC_DIR=${build_dir}"/"$(file_dirname ${HARFBUZZ_SRC_NAME} .tar.xz)
if [ ! -d ${HARFBUZZ_SRC_DIR} ]; then
  echo "unzip ${HARFBUZZ_SRC_NAME} source code" && tar xf source/${HARFBUZZ_SRC_NAME} -C ${build_dir}
fi

FRIBIDI_SRC_DIR=${build_dir}"/"$(file_dirname ${FRIBIDI_SRC_NAME} .tar.xz)
if [ ! -d ${FRIBIDI_SRC_DIR} ]; then
  echo "unzip ${FRIBIDI_SRC_NAME} source code" && tar xf source/${FRIBIDI_SRC_NAME} -C ${build_dir}
fi

PANGO_SRC_DIR=${build_dir}"/"$(file_dirname ${PANGO_SRC_NAME} .tar.xz)
if [ ! -d ${PANGO_SRC_DIR} ]; then
  echo "unzip ${PANGO_SRC_NAME} source code" && tar xf source/${PANGO_SRC_NAME} -C ${build_dir}
fi

GDKPIXBUF_SRC_DIR=${build_dir}"/"$(file_dirname ${GDKPIXBUF_SRC_NAME} .tar.gz)
if [ ! -d ${GDKPIXBUF_SRC_DIR} ]; then
  echo "unzip ${GDKPIXBUF_SRC_NAME} source code" && tar xf source/${GDKPIXBUF_SRC_NAME} -C ${build_dir}
fi

LIBEPOXY_SRC_DIR=${build_dir}"/"$(file_dirname ${LIBEPOXY_SRC_NAME} .tar.gz)
if [ ! -d ${LIBEPOXY_SRC_DIR} ]; then
  echo "unzip ${LIBEPOXY_SRC_NAME} source code" && tar xf source/${LIBEPOXY_SRC_NAME} -C ${build_dir}
fi

GRAPHENE_SRC_DIR=${build_dir}"/"$(file_dirname ${GRAPHENE_SRC_NAME} .tar.gz)
if [ ! -d ${GRAPHENE_SRC_DIR} ]; then
  echo "unzip ${GRAPHENE_SRC_NAME} source code" && tar xf source/${GRAPHENE_SRC_NAME} -C ${build_dir}
fi

GETTEXT_SRC_DIR=${build_dir}"/"$(file_dirname ${GETTEXT_SRC_NAME} .tar.gz)
if [ ! -d ${GETTEXT_SRC_DIR} ]; then
  echo "unzip ${GETTEXT_SRC_NAME} source code" && tar xf source/${GETTEXT_SRC_NAME} -C ${build_dir}
fi

WAYLANDPROT_SRC_DIR=${build_dir}"/"$(file_dirname ${WAYLANDPROT_SRC_NAME} .tar.gz)
if [ ! -d ${WAYLANDPROT_SRC_DIR} ]; then
  echo "unzip ${WAYLANDPROT_SRC_NAME} source code" && tar xf source/${WAYLANDPROT_SRC_NAME} -C ${build_dir}
fi

STARTUPNOTI_SRC_DIR=${build_dir}"/"$(file_dirname ${STARTUPNOTI_SRC_NAME} .tar.gz)
if [ ! -d ${STARTUPNOTI_SRC_DIR} ]; then
  echo "unzip ${STARTUPNOTI_SRC_NAME} source code" && tar xf source/${STARTUPNOTI_SRC_NAME} -C ${build_dir}
fi

LIBGUDEV_SRC_DIR=${build_dir}"/"$(file_dirname ${LIBGUDEV_SRC_NAME} .tar.gz)
if [ ! -d ${LIBGUDEV_SRC_DIR} ]; then
  echo "unzip ${LIBGUDEV_SRC_NAME} source code" && tar xf source/${LIBGUDEV_SRC_NAME} -C ${build_dir}
fi

UPOWER_SRC_DIR=${build_dir}"/"$(file_dirname ${UPOWER_SRC_NAME} .tar.gz)
if [ ! -d ${UPOWER_SRC_DIR} ]; then
  echo "unzip ${UPOWER_SRC_NAME} source code" && tar xf source/${UPOWER_SRC_NAME} -C ${build_dir}
fi

GOBJINTROSPE_SRC_DIR=${build_dir}"/"$(file_dirname ${GOBJINTROSPE_SRC_NAME} .tar.gz)
if [ ! -d ${GOBJINTROSPE_SRC_DIR} ]; then
  echo "unzip ${GOBJINTROSPE_SRC_NAME} source code" && tar xf source/${GOBJINTROSPE_SRC_NAME} -C ${build_dir}
fi

LIBWNCK_SRC_DIR=${build_dir}"/"$(file_dirname ${LIBWNCK_SRC_NAME} .tar.xz)
if [ ! -d ${LIBWNCK_SRC_DIR} ]; then
  echo "unzip ${LIBWNCK_SRC_NAME} source code" && tar xf source/${LIBWNCK_SRC_NAME} -C ${build_dir}
fi

GTKX_SRC_DIR=${build_dir}"/"$(file_dirname ${GTKX_SRC_NAME} .tar.xz)
if [ ! -d ${GTKX_SRC_DIR} ]; then
  echo "unzip ${GTKX_SRC_NAME} source code" && tar xf source/${GTKX_SRC_NAME} -C ${build_dir}
fi

XFCE_SRC_DIR=${build_dir}"/"$(file_dirname ${XFCE_SRC_NAME} .tar.bz2)
if [ ! -d ${XFCE_SRC_DIR} ]; then
  echo "unzip ${XFCE_SRC_NAME} source code" && tar xf source/${XFCE_SRC_NAME} -C ${build_dir}
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

xfce_install=${build_dir}"/xfce_install"

xfce_inc=${xfce_install}/usr/include
xfce_loc_inc=${xfce_install}/usr/local/include
xfce_x86_64_inc=${xfce_install}/usr/lib/x86_64-linux-gnu

include_path=" \
  -I${xfce_inc} \
  -I${xfce_inc}/glib-2.0 \
  -I${xfce_inc}/harfbuzz \
  -I${xfce_inc}/libmount \
  -I${xfce_inc}/gtk-3.0 \
  -I${xfce_inc}/pango-1.0 \
  -I${xfce_inc}/harfbuzz \
  -I${xfce_inc}/libwnck-3.0 \
  -I${xfce_inc}/gdk-pixbuf-2.0 \
  -I${xfce_loc_inc} \
  -I${xfce_loc_inc}/cairo \
  -I${xfce_loc_inc}/exo-2 \
  -I${xfce_loc_inc}/pixman-1 \
  -I${xfce_loc_inc}/freetype2 \
  -I${xfce_loc_inc}/thunarx-3 \
  -I${xfce_loc_inc}/garcon-1 \
  -I${xfce_loc_inc}/garcon-gtk3-1 \
  -I${xfce_x86_64_inc} \
  -I/usr/include/dbus-1.0 \
  -I/usr/include/atk-1.0 \
  -I/usr/include/at-spi2-atk/2.0 \
  -I/usr/include/gstreamer-1.0 \
  -I/usr/include/libpng16 \
  -I/usr/include/python3.8 \
  -I/usr/include/startup-notification-1.0 \
  -I/usr/lib/x86_64-linux-gnu/dbus-1.0/include"

xfce_lib=${xfce_install}/usr/lib
xfce_share=${xfce_install}/usr/share
xfce_loc_lib=${xfce_install}/usr/local/lib
xfce_loc_share=${xfce_install}/usr/local/share

library_path=" \
  -L${glibc_install}/lib64 \
  -L${xfce_lib} \
  -L${xfce_loc_lib} \
  -L${xfce_lib}/x86_64-linux-gnu"

CFGOPT="--with-sysroot=${xfce_install}"
pkgcfg1="${xfce_lib}/pkgconfig"
pkgcfg2="${xfce_share}/pkgconfig"
pkgcfg3="${xfce_loc_lib}/pkgconfig"
pkgcfg4="${xfce_lib}/x86_64-linux-gnu/pkgconfig"

export CFLAGS="${include_path}"
export CXXFLAGS="${include_path}"
export LDFLAGS="${library_path}"

# xfce 组件的编译需要这个设置
# export PLATFORM_CFLAGS="${include_path}"
# export PLATFORM_CPPFLAGS="${include_path}"
# export PLATFORM_LDFLAGS="${library_path}"

export PKG_CONFIG_SYSROOT_DIR="${xfce_install}"
export PKG_CONFIG_TOP_BUILD_DIR="${xfce_install}"
export PKG_CONFIG_PATH="${pkgcfg1}:${pkgcfg2}:${pkgcfg3}:${pkgcfg4}"

# 编译过程中有工具需要 libffi.so.8 库的，需要加载一下，否则会出现找不到 libffi.so.8
export LD_LIBRARY_PATH="${xfce_lib}:${xfce_loc_lib}:${xfce_lib}/x86_64-linux-gnu:$LD_LIBRARY_PATH"
ldconfig

# 编译过程中会寻找 *.gir 的文件，.gir 的目录就是这个
export XDG_DATA_DIRS="${xfce_share}:${xfce_loc_share}:${xfce_share}/gir-1.0:$XDG_DATA_DIRS"
export GDK_PIXBUF_PIXDATA="${xfce_install}/usr/bin/gdk-pixbuf-pixdata"

# python 模块的搜寻目录
# export PYTHONPATH="${xfce_lib}/x86_64-linux-gnu/gobject-introspection:${PYTHONPATH}"

#---------------------------------------------------------------------------------------------------------------
#
# xfce 库编译时用到 g-ir-scanner 工具，由于设置了 PKG_CONFIG_SYSROOT_DIR , 导致 xfce 调用 g-ir-scanner
# 的路径变成了 ${sysroot}/usr/bin/g-ir-scanner，这个路径下肯定没有 g-ir-scanner，它只存在 /usr/bin 下，
# 所以只能做一个软链过来, PKG_CONFIG_SYSROOT_DIR 不能去掉或设置为空，因为编译 gtk+ 以及依赖库都需要设置这个变量
#
#----------------------------------------------------------------------------------------------------------------
for i in $(find /usr/bin -name "g-ir-*")
do
  if [ -f ${xfce_install}${i} ]; then
    continue
  fi
  ln -s ${i} ${xfce_install}${i}
done

gi_makefile=/usr/share/gobject-introspection-1.0/Makefile.introspection
mkdir -pv ${xfce_share}/gobject-introspection-1.0
if [ ! -f ${xfce_install}${gi_makefile} ]; then
  ln -s ${gi_makefile} ${xfce_install}${gi_makefile}
fi

#---------------------------------------------------------------------------
#
# meson 的配置选项
# meson 编译参数一览 https://mesonbuild.com/Reference-tables.html
#
#---------------------------------------------------------------------------
ms_flag="--sysroot=${xfce_install}"
ms_link="-Wl,-rpath-link=${xfce_loc_lib}"

# if [ ! -d "xfce_install" ]; then
  # 编译 glib
  mkdir -pv xfce_install

  # 编译 libffi, 替换系统的
  if [ ! -f .libffi ]; then
    echo "${CYAN}build libffi begin${NC}" && cd ${LIBFFI_SRC_DIR} && ./configure
    make -j8 && make install && echo "ok" > ../.libffi || exit
    cd .. && echo "${GREEN}build libffi end${NC}"
  fi

  # 编译 util-linux ( libmount )
  if [ ! -f .libmnt ]; then
    echo "${CYAN}build libmount begin${NC}" && cd ${LIBMNT_SRC_DIR} && ./configure ${CFGOPT}
    make -j8 && make install DESTDIR=${xfce_install} && echo "ok" > ../.libmnt || exit
    cd .. && echo "${GREEN}build libmount end${NC}"
  fi
  
  # 编译 glib
  if [ ! -f .glib ]; then
    echo "${CYAN}build glib begin${NC}" && cd ${GLIB_SRC_DIR}
    mkdir -pv build
    meson setup build --prefix=/usr --pkg-config-path=${PKG_CONFIG_PATH}
    meson compile -C build
    meson install -C build --destdir=${xfce_install} && echo "ok" > ../.glib || exit
    cd .. && echo "${GREEN}build glib end${NC}"
  fi

  # 编译 pixman
  if [ ! -f .pixman ]; then
    echo "${CYAN}build pixman begin${NC}" && cd ${PIXMAN_SRC_DIR} && ./configure ${CFGOPT} --enable-libpng=yes
    make -j8 && make install DESTDIR=${xfce_install} && echo "ok" > ../.pixman || exit
    cd .. && echo "${GREEN}build pixman end${NC}"
  fi

  # 编译 freetype
  if [ ! -f .freetype ]; then
    echo "${CYAN}build freetype begin${NC}" && cd ${FREETYPE_SRC_DIR} && ./configure ${CFGOPT} --with-harfbuzz=no
    make -j8 && make install DESTDIR=${xfce_install} || exit
    cd .. && echo "${GREEN}build freetype end${NC}"
  fi

  # 编译 harfbuzz
  if [ ! -f .harfbuzz ]; then
    echo "${CYAN}build harfbuzz begin${NC}" && cd ${HARFBUZZ_SRC_DIR}
    rm -rf build && mkdir -pv build
    meson setup build --prefix=/usr --pkg-config-path=${PKG_CONFIG_PATH} -Dcairo=disabled
    meson compile -C build
    meson install -C build --destdir=${xfce_install} || exit
    cd .. && echo "${GREEN}build harfbuzz end${NC}"
  fi

  # 编译 freetype
  if [ ! -f .freetype ]; then
    echo "${CYAN}build freetype begin${NC}" && cd ${FREETYPE_SRC_DIR} && ./configure ${CFGOPT} --with-harfbuzz=yes
    make -j8 && make install DESTDIR=${xfce_install} && echo "ok" > ../.freetype || exit
    cd .. && echo "${GREEN}build freetype end${NC}"
  fi

  # 编译 fontconfig
  if [ ! -f .fontconfig ]; then
    echo "${CYAN}build fontconfig begin${NC}" && cd ${FONTCFG_SRC_DIR} && ./configure ${CFGOPT}
    make -j8 && make install DESTDIR=${xfce_install} && echo "ok" > ../.fontconfig || exit
    cd .. && echo "${GREEN}build fontconfig end${NC}"
  fi

  # 编译 cairo
  if [ ! -f .cairo ]; then
    echo "${CYAN}build cairo begin${NC}" && cd ${CAIRO_SRC_DIR}
    cairo_opt="--with-x --enable-png=yes --enable-xlib=yes --enable-xlib-xrender=yes --enable-ft=yes --enable-fc=yes"
    ./autogen.sh && ./configure ${CFGOPT} ${cairo_opt}
    make -j8 && make install DESTDIR=${xfce_install} && echo "ok" > ../.cairo || exit
    cd .. && echo "${GREEN}build cairo end${NC}"
  fi

  # 编译 harfbuzz
  if [ ! -f .harfbuzz ]; then
    echo "${CYAN}build harfbuzz begin${NC}" && cd ${HARFBUZZ_SRC_DIR}
    rm -rf build && mkdir -pv build
    meson setup build --prefix=/usr --pkg-config-path=${PKG_CONFIG_PATH} -Dcairo=enabled
    meson compile -C build
    meson install -C build --destdir=${xfce_install} && echo "ok" > ../.harfbuzz || exit
    cd .. && echo "${GREEN}build harfbuzz end${NC}"
  fi

  # 编译 fribidi
  if [ ! -f .fribidi ]; then
    echo "${CYAN}build fribidi begin${NC}" && cd ${FRIBIDI_SRC_DIR}
    rm -rf build && mkdir -pv build
    meson setup build --prefix=/usr --pkg-config-path=${PKG_CONFIG_PATH}
    meson compile -C build
    meson install -C build --destdir=${xfce_install} && echo "ok" > ../.fribidi || exit
    cd .. && echo "${GREEN}build fribidi end${NC}"
  fi

  # 编译 pango
  if [ ! -f .pango ]; then
    echo "${CYAN}build pango begin${NC}" && cd ${PANGO_SRC_DIR}
    rm -rf build && mkdir -pv build
    meson setup build --prefix=/usr --pkg-config-path=${PKG_CONFIG_PATH}
    meson compile -C build
    meson install -C build --destdir=${xfce_install} && echo "ok" > ../.pango || exit
    cd .. && echo "${GREEN}build pango end${NC}"
  fi

  # 编译 gobject-introspection
  # if [ ! -f .gobject-introspection ]; then
  #    echo "${CYAN}build gobject-introspection begin${NC}" && cd ${GOBJINTROSPE_SRC_DIR}
  #    mkdir -pv build
  #    meson setup build --prefix=/usr -Dc_flags=${ms_flag} -Dc_link_args=${ms_link}
  #    meson compile -C build
  #    meson install -C build --destdir=${xfce_install} && echo "ok" > ../.gobject-introspection || exit
  #    cd .. && echo "${GREEN}build gobject-introspection end${NC}"
  # fi

  # 编译 gdkpixbuf
  if [ ! -f .gdkpixbuf ]; then
    echo "${CYAN}build gdkpixbuf begin${NC}" && cd ${GDKPIXBUF_SRC_DIR}
    mkdir -pv build
    meson setup build --prefix=/usr --pkg-config-path=${PKG_CONFIG_PATH}
    meson compile -C build
    meson install -C build --destdir=${xfce_install} && echo "ok" > ../.gdkpixbuf || exit
    cd .. && echo "${GREEN}build gdkpixbuf end${NC}"
  fi
  
  # 编译 libepoxy
  if [ ! -f .libepoxy ]; then
    echo "${CYAN}build libepoxy begin${NC}" && cd ${LIBEPOXY_SRC_DIR}
    mkdir -pv build
    meson setup build --prefix=/usr --pkg-config-path=${PKG_CONFIG_PATH}
    meson compile -C build
    meson install -C build --destdir=${xfce_install} && echo "ok" > ../.libepoxy || exit
    cd .. && echo "${GREEN}build libepoxy end${NC}"
  fi

  # 编译 graphene
  if [ ! -f .graphene ]; then
    echo "${CYAN}build graphene begin${NC}" && cd ${GRAPHENE_SRC_DIR}
    mkdir -pv build
    meson setup build --prefix=/usr --pkg-config-path=${PKG_CONFIG_PATH}
    meson compile -C build
    meson install -C build --destdir=${xfce_install} && echo "ok" > ../.graphene || exit
    cd .. && echo "${GREEN}build graphene end${NC}"
  fi

  # 编译 wayland-protocols
  if [ ! -f .wayland-protocols ]; then
    echo "${CYAN}build wayland-protocols begin${NC}" && cd ${WAYLANDPROT_SRC_DIR}
    mkdir -pv build
    meson setup build --prefix=/usr --pkg-config-path=${PKG_CONFIG_PATH}
    meson compile -C build
    meson install -C build --destdir=${xfce_install} && echo "ok" > ../.wayland-protocols || exit
    cd .. && echo "${GREEN}build wayland-protocols end${NC}"
  fi

  # 编译 libstartup-notification0 ( 很多 xfce4 应用依赖此库, 依赖: libxcb-util-dev )
  if [ ! -f .startupnoti ]; then
    echo "${CYAN}build libstartup-notification0 begin${NC}" && cd ${STARTUPNOTI_SRC_DIR}
    ./configure ${CFGOPT}
    make -j8 && make install DESTDIR=${xfce_install} && echo "ok" > ../.startupnoti || exit
    cd .. && echo "${GREEN}build libstartup-notification0 end${NC}"
  fi

  # 编译 libgudev ( upower 依赖此库, 依赖: apt install libudev-dev )
  if [ ! -f .libgudev ]; then
    echo "${CYAN}build libgudev begin${NC}" && cd ${LIBGUDEV_SRC_DIR}
    mkdir -pv build
    meson setup build --prefix=/usr --pkg-config-path=${PKG_CONFIG_PATH}
    meson compile -C build
    meson install -C build --destdir=${xfce_install} && echo "ok" > ../.libgudev || exit
    cd .. && echo "${GREEN}build libgudev end${NC}"
  fi

  # 编译 upower ( xfce4-power-manager 依赖此库， 依赖: libgudev )
  if [ ! -f .upower ]; then
    echo "${CYAN}build upower begin${NC}" && cd ${UPOWER_SRC_DIR}
    up_flags="-DENOTSUP=95"
    mkdir -pv build
    meson setup build --prefix=/usr --pkg-config-path=${PKG_CONFIG_PATH} -Dc_args=${up_flags}
    meson compile -C build
    meson install -C build --destdir=${xfce_install} && echo "ok" > ../.upower || exit
    cd .. && echo "${GREEN}build upower end${NC}"
  fi

  # 编译 gettext 解决 libintl 的问题 gtk+
  if [ ! -f .gettext ]; then
    echo "${CYAN}build gettext begin${NC}" && cd ${GETTEXT_SRC_DIR}/gettext-runtime
    ./configure ${CFGOPT} --with-PACKAGE=gettext-runtime
    make -j8 && make install DESTDIR=${xfce_install} && echo "ok" > ../../.gettext || exit
    cd ../.. && echo "${GREEN}build gettext end${NC}"
  fi

  # 编译 gtk+
  if [ ! -f .gtk+ ]; then
    echo "${CYAN}build gtk+ begin${NC}" && cd ${GTKX_SRC_DIR}
    mkdir -pv build
    meson setup build --prefix=/usr --pkg-config-path=${PKG_CONFIG_PATH}
    meson compile -C build
    meson install -C build --destdir=${xfce_install} && echo "ok" > ../.gtk+ || exit
    cd .. && echo "${GREEN}build gtk+ end${NC}"
  fi

  # 在编译机上测试 xfce4 是否能正常工作
  if [ "${with_xfce_test}" = true ]; then
    tar zcf tmp.tar.gz ${xfce_install}
  fi

  # 编译 libwnck
  if [ ! -f .libwnck ]; then
    echo "${CYAN}build libwnck begin${NC}" && cd ${LIBWNCK_SRC_DIR}
    mkdir -pv build
    meson setup build --prefix=/usr --pkg-config-path=${PKG_CONFIG_PATH}
    meson compile -C build
    meson install -C build --destdir=${xfce_install} && echo "ok" > ../.libwnck || exit
    cd .. && echo "${GREEN}build libwnck end${NC}"
  fi

  # 编译 xfce
  cd ${XFCE_SRC_DIR}

  # 必须去掉这个，否则 xfce 编译不过，做的还是有点差，和 gtk+ 的编译还是差一个档次
  unset PKG_CONFIG_SYSROOT_DIR
  unset PKG_CONFIG_TOP_BUILD_DIR
  base_inc="${xfce_inc}/gtk-3.0:${xfce_inc}/pango-1.0:${xfce_inc}/harfbuzz:${xfce_inc}/gdk-pixbuf-2.0"
  garcon_inc="${xfce_loc_inc}/garcon-1:${xfce_loc_inc}/garcon-gtk3-1:${xfce_loc_inc}/xfce4/libxfce4panel-2.0"
  xfce_mod_inc="${xfce_loc_inc}/xfce4:${xfce_loc_inc}/xfce4/xfconf-0:${xfce_loc_inc}/xfce4/libxfce4kbd-private-3:${xfce_loc_inc}/xfce4/libxfce4ui-2"
  other_mod_inc="${xfce_inc}/libwnck-3.0:${xfce_loc_inc}/cairo:${xfce_loc_inc}/exo-2:${xfce_loc_inc}/thunarx-3"
  export C_INCLUDE_PATH="${base_inc}:${garcon_inc}:${xfce_mod_inc}:${other_mod_inc}"
  #export XDG_DATA_DIRS="${xfce_share}:${xfce_loc_share}"

  if [ ! -f .xfce4-dev-tools ]; then
    echo "${CYAN}build xfce4-dev-tools begin${NC}" && cd xfce4-dev-tools-4.16.0 && ./configure ${CFGOPT}
    make -j8 && make install DESTDIR=${xfce_install} && echo "ok" > ../.xfce4-dev-tools || exit
    cd .. && echo "${GREEN}build xfce4-dev-tools end${NC}"
  fi

  if [ ! -f .xlibxfce4util ]; then
    echo "${CYAN}build libxfce4util begin${NC}" && cd libxfce4util-4.16.0 && ./configure ${CFGOPT}
    make -j8 && make install DESTDIR=${xfce_install} && echo "ok" > ../.xlibxfce4util || exit
    cd .. && echo "${GREEN}build libxfce4util end${NC}"
  fi

  if [ ! -f .xfconf ]; then
    echo "${CYAN}build xfconf begin${NC}" && cd xfconf-4.16.0 && ./configure ${CFGOPT}
    make -j8 && make install DESTDIR=${xfce_install} && echo "ok" > ../.xfconf || exit
    cd .. && echo "${GREEN}build xfconf end${NC}"
  fi

  if [ ! -f .libxfce4ui ]; then
    echo "${CYAN}build libxfce4ui begin${NC}" && cd libxfce4ui-4.16.0 && ./configure ${CFGOPT}
    printenv && make -j8 && make install DESTDIR=${xfce_install} && echo "ok" > ../.libxfce4ui || exit
    cd .. && echo "${GREEN}build libxfce4ui end${NC}"
  fi

  if [ ! -f .garcon ]; then
    echo "${CYAN}build garcon begin${NC}" && cd garcon-0.8.0 && ./configure ${CFGOPT}
    make -j8 && make install DESTDIR=${xfce_install} && echo "ok" > ../.garcon || exit
    cd .. && echo "${GREEN}build garcon end${NC}"
  fi

  if [ ! -f .exo ]; then
    echo "${CYAN}build exo begin${NC}" && cd exo-4.16.0 && ./configure ${CFGOPT}
    make -j8 && make install DESTDIR=${xfce_install} && echo "ok" > ../.exo || exit
    cd .. && echo "${GREEN}build exo end${NC}"
  fi

  if [ ! -f .xfce4-panel ]; then
    echo "${CYAN}build xfce4-panel begin${NC}" && cd xfce4-panel-4.16.0 && ./configure ${CFGOPT}
    make -j8 && make install DESTDIR=${xfce_install} && echo "ok" > ../.xfce4-panel || exit
    cd .. && echo "${GREEN}build xfce4-panel end${NC}"
  fi

  if [ ! -f .thunar ]; then
    echo "${CYAN}build thunar begin${NC}" && cd thunar-4.16.0 && ./configure ${CFGOPT}
    make -j8 && make install DESTDIR=${xfce_install} && echo "ok" > ../.thunar || exit
    cd .. && echo "${GREEN}build thunar end${NC}"
  fi

  if [ ! -f .xfce4-settings ]; then
    echo "${CYAN}build xfce4-settings begin${NC}" && cd xfce4-settings-4.16.0 && ./configure ${CFGOPT}
    make -j8 && make install DESTDIR=${xfce_install} && echo "ok" > ../.xfce4-settings || exit
    cd .. && echo "${GREEN}build xfce4-settings end${NC}"
  fi
  
  if [ ! -f .xfce4-session ]; then
    echo "${CYAN}build xfce4-session begin${NC}" && cd xfce4-session-4.16.0 && ./configure ${CFGOPT}
    make -j8 && make install DESTDIR=${xfce_install} && echo "ok" > ../.xfce4-session || exit
    cd .. && echo "${GREEN}build xfce4-session end${NC}"
  fi

  if [ ! -f .xfwm4 ]; then
    echo "${CYAN}build xfwm4 begin${NC}" && cd xfwm4-4.16.0 && ./configure ${CFGOPT}
    make -j8 && make install DESTDIR=${xfce_install} && echo "ok" > ../.xfwm4 || exit
    cd .. && echo "${GREEN}build xfwm4 end${NC}"
  fi

  if [ ! -f .xfdesktop ]; then
    echo "${CYAN}build xfdesktop begin${NC}" && cd xfdesktop-4.16.0 && ./configure ${CFGOPT}
    make -j8 && make install DESTDIR=${xfce_install} && echo "ok" > ../.xfdesktop || exit
    cd .. && echo "${GREEN}build xfdesktop end${NC}"
  fi

  if [ ! -f .thunar-volman ]; then
    echo "${CYAN}build thunar-volman begin${NC}" && cd thunar-volman-4.16.0 && ./configure ${CFGOPT}
    make -j8 && make install DESTDIR=${xfce_install} && echo "ok" > ../.thunar-volman || exit
    cd .. && echo "${GREEN}build thunar-volman end${NC}"
  fi
  
  if [ ! -f .tumbler ]; then
    echo "${CYAN}build tumbler begin${NC}" && cd tumbler-4.16.0 && ./configure ${CFGOPT}
    make -j8 && make install DESTDIR=${xfce_install} && echo "ok" > ../.tumbler || exit
    cd .. && echo "${GREEN}build tumbler end${NC}"
  fi
  
  if [ ! -f .xfce4-power-manager ]; then
    echo "${CYAN}build xfce4-power-manager begin${NC}" && cd xfce4-power-manager-4.16.0 && ./configure ${CFGOPT}
    make -j8 && make install DESTDIR=${xfce_install} && echo "ok" > ../.xfce4-power-manager || exit
    cd .. && echo "${GREEN}build xfce4-power-manager end${NC}"
  fi

  if [ ! -f .xfce4-appfinder ]; then
    echo "${CYAN}build xfce4-appfinder begin${NC}" && cd xfce4-appfinder-4.16.0 && ./configure ${CFGOPT}
    make -j8 && make install DESTDIR=${xfce_install} && echo "ok" > ../.xfce4-appfinder || exit
    cd .. && echo "${GREEN}build xfce4-appfinder end${NC}"
  fi

# fi

cd ..

# 此开关选项可以在编译机器上，体验桌面系统了 ( Ubuntu Server 18.04 )
if [ "${with_xfce_test}" = true ]; then

  # gtk+ 之前 compile 的库不能覆盖系统目录，否则可能导致系统启动失败，或者 xfce4 不能正常运行，只能通过 ld.so.conf.d 加载
  mkdir -pv test/a test/b
  tar zxf tmp.tar.gz -C test/a
  mv test/a/${xfce_install}/* test/a
  rm test/a/root -rf
  cp ${xfce_install}/* test/b -rf

  # 删除 to 目录中，与 from 目录中路径一模一样的文件
  from_dir=test/a
  to_dir=test/b

  # 删除缓存文件
  if [ -f tmpfile.txt ]; then
    rm tmpfile.txt -rf
  fi

  # 从目录中删除重复文件，只保持 xfce4 的文件
  ls_dir $from_dir $from_dir
  for line in $(cat tmpfile.txt)
  do
    file=$to_dir$line
    if [ -f $file ]; then
      rm $file -rf
      echo "delete repeat file : $file"
    fi
  done

  # 删除空目录，去掉冗余目录
  find $to_dir -type d -empty -delete

  # 拷贝 xfce4 到系统目录
  cd $to_dir
  cp ./ / -r -n
  cd ..

  # 预装运行环境
  apt install dbus-x11 -y
  apt install xrdp -y

  #apt install libstartup-notification0 -y
  #apt install libupower-glib3 -y

  # xfdesktop 需要库的路径, xfdesktop 不能运行，基本上桌面就是黑屏了，可能有 dock 栏和最上面的状态栏
  libdir=`pwd`"/a/usr"
  echo "LD_LIBRARY_PATH=\"${libdir}/lib:${libdir}/local/lib:${libdir}/lib/x86_64-linux-gnu\" xfce4-session" > ~/.xsession

  # 重启系统，然后可以利用 windows 下 remote desktop 体验最新版本的 xfce4 了, 最新版本的 xfce4 还是很漂亮的
  # reboot

fi

echo "${CYAN}build all success - [${GREEN} ok ${CYAN}]${NC}"
