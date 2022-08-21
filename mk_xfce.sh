#!/bin/sh

# set +e
# 所有的编译基于 Ubuntu 18.04.6 LTS 编译通过, 其它系统请自行调整脚本

# 预装工具
if [ -f "/usr/bin/apt" ]; then
  apt install cmake gperf bison flex intltool libtool libxml2-utils gobject-introspection gtk-doc-tools libgirepository1.0-dev python3.8-dev python3.8-dbg python3-pip python-docutils libxrender-dev libsm-dev libxext-dev libthai-dev libxkbcommon-dev libdbus-1-dev libxtst-dev docbook-xsl -y
  # 安装 OpenGL
  apt-get install libgl1-mesa-dev libglu1-mesa-dev libglut-dev -y
  # 安装 gstreamer
  apt-get install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-doc gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-qt5 gstreamer1.0-pulseaudio -y
  # gtk+ 编译
  apt install libcups2-dev libxrandr-dev libxi-dev libxinerama-dev libvulkan-dev -y
  # xfce 编译
  apt install x11-xserver-utils libxcb-util-dev libudev-dev docbook-xsl-ns libwayland-client0 libwayland-egl-backend-dev libelf-dev-y
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
LIBPNG_SRC_URL=https://nchc.dl.sourceforge.net/project/libpng/libpng16/1.6.37/libpng-1.6.37.tar.xz
LIBZIP_SRC_URL=https://libzip.org/download/libzip-1.9.2.tar.xz
LIBPCRE2_SRC_URL=https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.40/pcre2-10.40.tar.gz
LIBNOTIFY_SRC_URL=https://download.gnome.org/sources/libnotify/0.8/libnotify-0.8.0.tar.xz
GLIB_SRC_URL=https://download.gnome.org/sources/glib/2.62/glib-2.62.0.tar.xz
PIXMAN_SRC_URL=https://www.cairographics.org/releases/pixman-0.40.0.tar.gz
CAIRO_SRC_URL=https://www.cairographics.org/releases/cairo-1.16.0.tar.xz
FREETYPE_SRC_URL=https://nchc.dl.sourceforge.net/project/freetype/freetype2/2.12.0/freetype-2.12.0.tar.xz
FONTCFG_SRC_URL=https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.13.96.tar.xz
HARFBUZZ_SRC_URL=https://github.com/harfbuzz/harfbuzz/releases/download/5.1.0/harfbuzz-5.1.0.tar.xz
FRIBIDI_SRC_URL=https://github.com/fribidi/fribidi/releases/download/v1.0.12/fribidi-1.0.12.tar.xz
PANGO_SRC_URL=https://download.gnome.org/sources/pango/1.48/pango-1.48.9.tar.xz
GDKPIXBUF_SRC_URL=https://gitlab.gnome.org/GNOME/gdk-pixbuf/-/archive/2.42.8/gdk-pixbuf-2.42.8.tar.gz
LIBATK_SRC_URL=https://gitlab.gnome.org/GNOME/atk/-/archive/2.38.0/atk-2.38.0.tar.gz
LIBEPOXY_SRC_URL=https://github.com/anholt/libepoxy/archive/refs/tags/1.5.10.tar.gz
LIBXML_SRC_URL=https://download.gnome.org/sources/libxml2/2.9/libxml2-2.9.8.tar.xz
LIBATK_CORE_SRC_URL=https://download.gnome.org/sources/at-spi2-core/2.38/at-spi2-core-2.38.0.tar.xz
LIBATK_BRIDGE_SRC_URL=https://download.gnome.org/sources/at-spi2-atk/2.38/at-spi2-atk-2.38.0.tar.xz
PCIACCESS_SRC_URL=https://github.com/freedesktop/xorg-libpciaccess/archive/refs/tags/libpciaccess-0.16.tar.gz
LIBDRM_SRC_URL=https://dri.freedesktop.org/libdrm/libdrm-2.4.110.tar.xz
MESA_SRC_URL=https://gitlab.freedesktop.org/mesa/mesa/-/archive/mesa-20.0.0-rc3/mesa-mesa-20.0.0-rc3.tar.gz
GRAPHENE_SRC_URL=https://github.com/ebassi/graphene/archive/refs/tags/1.10.8.tar.gz
GOBJINTROSPE_SRC_URL=https://github.com/GNOME/gobject-introspection/archive/refs/tags/1.72.0.tar.gz
STARTUPNOTI_SRC_URL=http://www.freedesktop.org/software/startup-notification/releases/startup-notification-0.12.tar.gz
WAYLANDPROT_SRC_URL=https://gitlab.freedesktop.org/wayland/wayland-protocols/-/archive/1.25/wayland-protocols-1.25.tar.gz
LIBGUDEV_SRC_URL=https://gitlab.gnome.org/GNOME/libgudev/-/archive/236/libgudev-236.tar.gz
UPOWER_SRC_URL=https://gitlab.freedesktop.org/upower/upower/-/archive/v1.90.0/upower-v1.90.0.tar.gz
LIBWNCK_SRC_URL=https://download.gnome.org/sources/libwnck/3.36/libwnck-3.36.0.tar.xz
GSTREAMER_SRC_URL=https://gstreamer.freedesktop.org/src/gstreamer/gstreamer-1.20.2.tar.xz
GTKX_SRC_URL=https://download.gnome.org/sources/gtk%2B/3.24/gtk%2B-3.24.9.tar.xz
XFCE_SRC_URL=https://archive.xfce.org/xfce/4.16/fat_tarballs/xfce-4.16.tar.bz2

#----------------------------
#
# 下载源码
#
#----------------------------
mkdir -pv source
cd source

LIBFFI_SRC_NAME=$(download_src ${LIBFFI_SRC_URL})
LIBXML_SRC_NAME=$(download_src ${LIBXML_SRC_URL})
LIBMNT_SRC_NAME=$(download_src ${LIBMNT_SRC_URL})
LIBPNG_SRC_NAME=$(download_src ${LIBPNG_SRC_URL})
LIBZIP_SRC_NAME=$(download_src ${LIBZIP_SRC_URL})
LIBPCRE2_SRC_NAME=$(download_src ${LIBPCRE2_SRC_URL})
LIBNOTIFY_SRC_NAME=$(download_src ${LIBNOTIFY_SRC_URL})
GLIB_SRC_NAME=$(download_src ${GLIB_SRC_URL})
PIXMAN_SRC_NAME=$(download_src ${PIXMAN_SRC_URL})
FREETYPE_SRC_NAME=$(download_src ${FREETYPE_SRC_URL})
CAIRO_SRC_NAME=$(download_src ${CAIRO_SRC_URL})
FONTCFG_SRC_NAME=$(download_src ${FONTCFG_SRC_URL})
HARFBUZZ_SRC_NAME=$(download_src ${HARFBUZZ_SRC_URL})
FRIBIDI_SRC_NAME=$(download_src ${FRIBIDI_SRC_URL})
PANGO_SRC_NAME=$(download_src ${PANGO_SRC_URL})
GDKPIXBUF_SRC_NAME=$(download_src ${GDKPIXBUF_SRC_URL})
LIBATK_SRC_NAME=$(download_src ${LIBATK_SRC_URL})
GETTEXT_SRC_NAME=$(download_src ${GETTEXT_SRC_URL})
WAYLANDPROT_SRC_NAME=$(download_src ${WAYLANDPROT_SRC_URL})
STARTUPNOTI_SRC_NAME=$(download_src ${STARTUPNOTI_SRC_URL})
LIBGUDEV_SRC_NAME=$(download_src ${LIBGUDEV_SRC_URL})
UPOWER_SRC_NAME=$(download_src ${UPOWER_SRC_URL})
LIBWNCK_SRC_NAME=$(download_src ${LIBWNCK_SRC_URL})
LIBATK_CORE_SRC_NAME=$(download_src ${LIBATK_CORE_SRC_URL})
LIBATK_BRIDGE_SRC_NAME=$(download_src ${LIBATK_BRIDGE_SRC_URL})
XFCE_SRC_NAME=$(download_src ${XFCE_SRC_URL})
MESA_SRC_NAME=$(download_src ${MESA_SRC_URL})
LIBDRM_SRC_NAME=$(download_src ${LIBDRM_SRC_URL})
GSTREAMER_SRC_NAME=$(download_src ${GSTREAMER_SRC_URL})
LIBEPOXY_SRC_NAME=$(download_src ${LIBEPOXY_SRC_URL} "libepoxy-")
GRAPHENE_SRC_NAME=$(download_src ${GRAPHENE_SRC_URL} "graphene-")
PCIACCESS_SRC_NAME=$(download_src ${PCIACCESS_SRC_URL} "xorg-libpciaccess-")
GOBJINTROSPE_SRC_NAME=$(download_src ${GOBJINTROSPE_SRC_URL} "gobject-introspection-")
# gtk 因为 + 号，需要特殊处理
GTKX_SRC_NAME=$(echo $(file_name ${GTKX_SRC_URL}) | sed 's/%2B/+/')
if [ ! -f ${GTKX_SRC_NAME} ]; then
  wget -c -t 0 $GTKX_SRC_URL
fi

cd ..

#---------------------------
#
# 解压源码
#
#---------------------------
mkdir -pv ${build_dir}

LIBFFI_SRC_DIR=$(unzip_src ".tar.gz" ${LIBFFI_SRC_NAME}); echo "unzip ${LIBFFI_SRC_NAME} source code"
LIBXML_SRC_DIR=$(unzip_src ".tar.xz" ${LIBXML_SRC_NAME}); echo "unzip ${LIBXML_SRC_NAME} source code"
LIBMNT_SRC_DIR=$(unzip_src ".tar.xz" ${LIBMNT_SRC_NAME}); echo "unzip ${LIBMNT_SRC_NAME} source code"
LIBPNG_SRC_DIR=$(unzip_src ".tar.xz" ${LIBPNG_SRC_NAME}); echo "unzip ${LIBPNG_SRC_NAME} source code"
LIBZIP_SRC_DIR=$(unzip_src ".tar.xz" ${LIBZIP_SRC_NAME}); echo "unzip ${LIBZIP_SRC_NAME} source code"
LIBPCRE2_SRC_DIR=$(unzip_src ".tar.gz" ${LIBPCRE2_SRC_NAME}); echo "unzip ${LIBPCRE2_SRC_NAME} source code"
LIBNOTIFY_SRC_DIR=$(unzip_src ".tar.xz" ${LIBNOTIFY_SRC_NAME}); echo "unzip ${LIBNOTIFY_SRC_NAME} source code"
GLIB_SRC_DIR=$(unzip_src ".tar.xz" ${GLIB_SRC_NAME}); echo "unzip ${GLIB_SRC_NAME} source code"
PIXMAN_SRC_DIR=$(unzip_src ".tar.gz" ${PIXMAN_SRC_NAME}); echo "unzip ${PIXMAN_SRC_NAME} source code"
FREETYPE_SRC_DIR=$(unzip_src ".tar.xz" ${FREETYPE_SRC_NAME}); echo "unzip ${FREETYPE_SRC_NAME} source code"
CAIRO_SRC_DIR=$(unzip_src ".tar.xz" ${CAIRO_SRC_NAME}); echo "unzip ${CAIRO_SRC_NAME} source code"
FONTCFG_SRC_DIR=$(unzip_src ".tar.xz" ${FONTCFG_SRC_NAME}); echo "unzip ${FONTCFG_SRC_NAME} source code"
HARFBUZZ_SRC_DIR=$(unzip_src ".tar.xz" ${HARFBUZZ_SRC_NAME}); echo "unzip ${HARFBUZZ_SRC_NAME} source code"
FRIBIDI_SRC_DIR=$(unzip_src ".tar.xz" ${FRIBIDI_SRC_NAME}); echo "unzip ${FRIBIDI_SRC_NAME} source code"
PANGO_SRC_DIR=$(unzip_src ".tar.xz" ${PANGO_SRC_NAME}); echo "unzip ${PANGO_SRC_NAME} source code"
GDKPIXBUF_SRC_DIR=$(unzip_src ".tar.gz" ${GDKPIXBUF_SRC_NAME}); echo "unzip ${GDKPIXBUF_SRC_NAME} source code"
LIBATK_SRC_DIR=$(unzip_src ".tar.gz" ${LIBATK_SRC_NAME}); echo "unzip ${LIBATK_SRC_NAME} source code"
LIBEPOXY_SRC_DIR=$(unzip_src ".tar.gz" ${LIBEPOXY_SRC_NAME}); echo "unzip ${LIBEPOXY_SRC_NAME} source code"
LIBATK_CORE_SRC_DIR=$(unzip_src ".tar.xz" ${LIBATK_CORE_SRC_NAME}); echo "unzip ${LIBATK_CORE_SRC_NAME} source code"
LIBATK_BRIDGE_SRC_DIR=$(unzip_src ".tar.xz" ${LIBATK_BRIDGE_SRC_NAME}); echo "unzip ${LIBATK_BRIDGE_SRC_NAME} source code"
GRAPHENE_SRC_DIR=$(unzip_src ".tar.gz" ${GRAPHENE_SRC_NAME}); echo "unzip ${GRAPHENE_SRC_NAME} source code"
GETTEXT_SRC_DIR=$(unzip_src ".tar.gz" ${GETTEXT_SRC_NAME}); echo "unzip ${GETTEXT_SRC_NAME} source code"
WAYLANDPROT_SRC_DIR=$(unzip_src ".tar.gz" ${WAYLANDPROT_SRC_NAME}); echo "unzip ${WAYLANDPROT_SRC_NAME} source code"
STARTUPNOTI_SRC_DIR=$(unzip_src ".tar.gz" ${STARTUPNOTI_SRC_NAME}); echo "unzip ${STARTUPNOTI_SRC_NAME} source code"
LIBGUDEV_SRC_DIR=$(unzip_src ".tar.gz" ${LIBGUDEV_SRC_NAME}); echo "unzip ${LIBGUDEV_SRC_NAME} source code"
UPOWER_SRC_DIR=$(unzip_src ".tar.gz" ${UPOWER_SRC_NAME}); echo "unzip ${UPOWER_SRC_NAME} source code"
GOBJINTROSPE_SRC_DIR=$(unzip_src ".tar.gz" ${GOBJINTROSPE_SRC_NAME}); echo "unzip ${GOBJINTROSPE_SRC_NAME} source code"
LIBWNCK_SRC_DIR=$(unzip_src ".tar.xz" ${LIBWNCK_SRC_NAME}); echo "unzip ${LIBWNCK_SRC_NAME} source code"
GSTREAMER_SRC_DIR=$(unzip_src ".tar.xz" ${GSTREAMER_SRC_NAME}); echo "unzip ${GSTREAMER_SRC_NAME} source code"
LIBDRM_SRC_DIR=$(unzip_src ".tar.xz" ${LIBDRM_SRC_NAME}); echo "unzip ${LIBDRM_SRC_NAME} source code"
PCIACCESS_SRC_DIR=$(unzip_src ".tar.gz" ${PCIACCESS_SRC_NAME}); echo "unzip ${PCIACCESS_SRC_NAME} source code"
MESA_SRC_DIR=$(unzip_src ".tar.gz" ${MESA_SRC_NAME}); echo "unzip ${MESA_SRC_NAME} source code"
GTKX_SRC_DIR=$(unzip_src ".tar.xz" ${GTKX_SRC_NAME}); echo "unzip ${GTKX_SRC_NAME} source code"
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

xfce_inc=${xfce_install}/usr/include
xfce_loc_inc=${xfce_install}/usr/local/include
xfce_x86_64_inc=${xfce_install}/usr/lib/x86_64-linux-gnu
include_path=" \
  -I${xfce_inc} \
  -I${xfce_inc}/glib-2.0 \
  -I${xfce_inc}/harfbuzz \
  -I${xfce_inc}/libmount \
  -I${xfce_inc}/atk-1.0 \
  -I${xfce_inc}/gtk-3.0 \
  -I${xfce_inc}/gudev-1.0 \
  -I${xfce_inc}/pango-1.0 \
  -I${xfce_inc}/harfbuzz \
  -I${xfce_inc}/libwnck-3.0 \
  -I${xfce_inc}/gdk-pixbuf-2.0 \
  -I${xfce_inc}/libupower-glib \
  -I${xfce_loc_inc} \
  -I${xfce_loc_inc}/cairo \
  -I${xfce_loc_inc}/exo-2 \
  -I${xfce_loc_inc}/libxml2 \
  -I${xfce_loc_inc}/pixman-1 \
  -I${xfce_loc_inc}/freetype2 \
  -I${xfce_loc_inc}/thunarx-3 \
  -I${xfce_loc_inc}/garcon-1 \
  -I${xfce_loc_inc}/garcon-gtk3-1 \
  -I${xfce_x86_64_inc} \
  -I/usr/include/dbus-1.0 \
  -I/usr/include/python3.8 \
  -I/usr/include/gstreamer-1.0 \
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

cfg_opt="--with-sysroot=${xfce_install}"
pkg_cfg1="${xfce_lib}/pkgconfig"
pkg_cfg2="${xfce_share}/pkgconfig"
pkg_cfg3="${xfce_loc_lib}/pkgconfig"
pkg_cfg4="${xfce_lib}/x86_64-linux-gnu/pkgconfig"

export CFLAGS="${include_path}"
export CXXFLAGS="${include_path}"
export LDFLAGS="${library_path}"

export PKG_CONFIG_SYSROOT_DIR="${xfce_install}"
export PKG_CONFIG_TOP_BUILD_DIR="${xfce_install}"
export PKG_CONFIG_PATH="${pkg_cfg1}:${pkg_cfg2}:${pkg_cfg3}:${pkg_cfg4}"

# 编译过程中会寻找 *.gir 的文件，.gir 的目录就是这个
export XDG_DATA_DIRS="${xfce_share}:${xfce_loc_share}:${xfce_share}/gir-1.0:$XDG_DATA_DIRS"
export GDK_PIXBUF_PIXDATA="${xfce_install}/usr/bin/gdk-pixbuf-pixdata"

# 编译过程中有工具需要 libffi.so.8 库的，需要加载一下，否则会出现找不到 libffi.so.8
export LD_LIBRARY_PATH="${xfce_lib}:${xfce_loc_lib}:${xfce_lib}/x86_64-linux-gnu:$LD_LIBRARY_PATH"
ldconfig

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

#---------------------------
# meson 编译 编译参数一览 https://mesonbuild.com/Reference-tables.html
#---------------------------
meson_build() {
  local name=$1
  local srcdir=$2
  if [ ! -f .${name} ]; then
    echo "${CYAN}build ${name} begin${NC}" && cd ${srcdir} && mkdir -pv build
    meson setup build --prefix=/usr --pkg-config-path=${PKG_CONFIG_PATH} $3
    meson compile -C build
    meson install -C build --destdir=${xfce_install} && echo "ok" > ../.${name} || exit
    cd .. && echo "${GREEN}build ${name} end${NC}"
  fi
}

#--------------------------
# xfce4 编译定义
#--------------------------
xfce4_build() {
  local name=$1
  local srcdir=$2
  if [ ! -f .${name} ]; then
    echo "${CYAN}build ${name} begin${NC}" && cd ${srcdir} && ./configure ${cfg_opt}
    make -j8 && make install DESTDIR=${xfce_install} && echo "ok" > ../.${name} || exit
    cd .. && echo "${GREEN}build ${name} end${NC}"
  fi
}

#--------------------------
# 公共模块编译
#--------------------------
common_build() {
  local name=$1
  local srcdir=$2
  if [ ! -f .${name} ]; then
    echo "${CYAN}build ${name} begin${NC}" && cd ${srcdir} 
    if [ -f autogen.sh ]; then
      ./autogen.sh
    fi
    if [ -f CMakeLists.txt ]; then
      cmake .
    fi
    if [ -f ./configure ]; then
      ./configure ${cfg_opt} $3
    fi
    make -j8 && make install DESTDIR=${xfce_install} && echo "ok" > ../.${name} || exit
    cd .. && echo "${GREEN}build ${name} end${NC}"
  fi
}

#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# 编译 harfbuzz 遇到问题: linking of temporary binary failed，关闭 glibc 的链接，问题就解决了，原因推测如下：
# 目前还不支持和 glibc 同时编译，因为如果编译链接 glibc ，可能需要全部依赖都做到源码编译，否则，可能编译过程中有问题
# 因为 apt install 安装的软件可能依赖系统自带的 glibc，这边指定编译的 glibc ，就会导致链接器工作混乱。导致链接失败
# 因此编译 xfce 时，一定保证 glibc_install/lib64 目录为空，否则就会出现上面的错误 died with <Signals.SIGSEGV: 11>
#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# if [ ! -d "xfce_install" ]; then
  mkdir -pv xfce_install

  # 编译 libffi, 替换系统的
  common_build libffi ${LIBFFI_SRC_DIR}
  # 编译 libxml
  common_build libxml ${LIBXML_SRC_DIR}
  # 编译 util-linux ( libmount )
  common_build libmnt ${LIBMNT_SRC_DIR}
  # 编译 libpng
  common_build libpng ${LIBPNG_SRC_DIR}
  # 编译 libzip
  common_build libzip ${LIBZIP_SRC_DIR}
  # 编译 libpcre2
  common_build libpcre2 ${LIBPCRE2_SRC_DIR}
  # 编译 glib
  meson_build glib ${GLIB_SRC_DIR}
  # 编译 pixman
  common_build pixman ${PIXMAN_SRC_DIR} --enable-libpng=yes
  # 编译 freetype
  common_build freetype_pre ${FREETYPE_SRC_DIR} --with-harfbuzz=no
  # 编译 harfbuzz
  meson_build harfbuzz_pre ${HARFBUZZ_SRC_DIR} -Dcairo=disabled
  # 编译 freetype
  common_build freetype ${FREETYPE_SRC_DIR} --with-harfbuzz=yes
  # 编译 fontconfig
  common_build fontconfig ${FONTCFG_SRC_DIR}
  # 编译 cairo
  cairo_opt="--with-x --enable-png=yes --enable-xlib=yes --enable-xlib-xrender=yes --enable-ft=yes --enable-fc=yes"
  common_build cairo ${CAIRO_SRC_DIR} ${cairo_opt}
  # 编译 harfbuzz
  meson_build harfbuzz ${HARFBUZZ_SRC_DIR} -Dcairo=enabled
  # 编译 fribidi
  meson_build fribidi ${FRIBIDI_SRC_DIR}
  # 编译 pango
  meson_build pango ${PANGO_SRC_DIR}
  # 编译 gobject-introspection
  # ms_flag="--sysroot=${xfce_install}"
  # ms_link="-Wl,-rpath-link=${xfce_loc_lib}"
  # gobject_inttro="-Dc_flags=${ms_flag} -Dc_link_args=${ms_link}"
  # meson_build gobject-introspection ${GOBJINTROSPE_SRC_DIR} ${gobject_intro}
  # 编译 gdkpixbuf
  meson_build gdkpixbuf ${GDKPIXBUF_SRC_DIR}
  # 编译 libatk
  meson_build libatk ${LIBATK_SRC_DIR}
  # 编译 libatk-core ( 依赖: libxml )
  meson_build libatk-core ${LIBATK_CORE_SRC_DIR}
  # 编译 libatk-bridge ( 依赖: libatk-core )
  meson_build libatk-bridge ${LIBATK_BRIDGE_SRC_DIR}
  # 编译 pciaccess
  common_build pciaccess ${PCIACCESS_SRC_DIR}
  # 编译 libdrm
  meson_build libdrm ${LIBDRM_SRC_DIR}
  # 编译 libepoxy
  meson_build libepoxy ${LIBEPOXY_SRC_DIR}
  # 编译 graphene
  meson_build graphene ${GRAPHENE_SRC_DIR}
  # 编译 wayland-protocols
  meson_build wayland-protocols ${WAYLANDPROT_SRC_DIR}
  # 编译 mesa
  meson_build mesa ${MESA_SRC_DIR}
  # 编译 libstartup-notification0 ( 很多 xfce4 应用依赖此库, 依赖: libxcb-util-dev )
  common_build startupnoti ${STARTUPNOTI_SRC_DIR}
  # 编译 libgudev ( upower 依赖此库, 依赖: apt install libudev-dev )
  meson_build libgudev ${LIBGUDEV_SRC_DIR}
  # 编译 upower ( xfce4-power-manager 依赖此库， 依赖: libgudev )
  upower_flags="-DENOTSUP=95"
  meson_build upower ${UPOWER_SRC_DIR} -Dc_args=${upower_flags}
  # 编译 gettext 解决 libintl 的问题 gtk+
  common_build gettext ${GETTEXT_SRC_DIR}
  # 编译 gstreamer
  meson_build gstreamer ${GSTREAMER_SRC_DIR}
  # 编译 gtk+
  meson_build gtk+ ${GTKX_SRC_DIR}
  # 在编译机上测试 xfce4 是否能正常工作
  if [ "${with_xfce_test}" = true ]; then
    tar zcf tmp.tar.gz ${xfce_install}
  fi
  # 编译 libwnck
  meson_build libwnck ${LIBWNCK_SRC_DIR}
  # 编译 libnotify
  meson_build libnotify ${LIBNOTIFY_SRC_DIR}

  # 编译 xfce
  cd ${XFCE_SRC_DIR}

  # 必须去掉这个，否则 xfce 编译不过，做的还是有点差，和 gtk+ 的编译还是差一个档次
  unset PKG_CONFIG_SYSROOT_DIR
  unset PKG_CONFIG_TOP_BUILD_DIR
  xfce4_inc="${xfce_loc_inc}/xfce4"
  base_inc="${xfce_inc}/gtk-3.0:${xfce_inc}/pango-1.0:${xfce_inc}/harfbuzz:${xfce_inc}/atk-1.0:${xfce_inc}/gdk-pixbuf-2.0"
  garcon_inc="${xfce_loc_inc}/garcon-1:${xfce_loc_inc}/garcon-gtk3-1:${xfce_loc_inc}/xfce4/libxfce4panel-2.0"
  startup_inc="${xfce_loc_inc}/startup-notification-1.0"
  xfce_mod_inc="${xfce4_inc}:${xfce4_inc}/xfconf-0:${xfce4_inc}/libxfce4kbd-private-3:${xfce4_inc}/libxfce4ui-2"
  other_mod_inc="${xfce_inc}/libwnck-3.0:${xfce_loc_inc}/cairo:${xfce_loc_inc}/exo-2:${xfce_loc_inc}/thunarx-3"
  export C_INCLUDE_PATH="${base_inc}:${garcon_inc}:${startup_inc}:${xfce_mod_inc}:${other_mod_inc}"

  xfce4_build xfce4-dev-tools xfce4-dev-tools-4.16.0
  xfce4_build libxfce4util libxfce4util-4.16.0 
  xfce4_build xfconf xfconf-4.16.0 
  xfce4_build libxfce4ui libxfce4ui-4.16.0
  xfce4_build garcon garcon-0.8.0
  xfce4_build exo exo-4.16.0
  xfce4_build xfce4-panel xfce4-panel-4.16.0
  xfce4_build thunar thunar-4.16.0
  xfce4_build xfce4-settings xfce4-settings-4.16.0
  xfce4_build xfce4-session xfce4-session-4.16.0
  xfce4_build xfwm4 xfwm4-4.16.0 
  xfce4_build xfdesktop xfdesktop-4.16.0 
  xfce4_build thunar-volman thunar-volman-4.16.0
  xfce4_build tumbler tumbler-4.16.0 
  xfce4_build xfce4-power-manager xfce4-power-manager-4.16.0 
  xfce4_build xfce4-appfinder xfce4-appfinder-4.16.0 

  cd ..

# fi

# 此开关选项可以在编译机器上，体验桌面系统了 ( Ubuntu Server 18.04 )
if [ "${with_xfce_test}" = true ]; then

  # gtk+ 之前 compile 的库不能覆盖系统目录，否则可能导致系统启动失败，或者 xfce4 不能正常运行，只能通过 ld.so.conf.d 加载
  rm test/a test/b -rf
  mkdir -pv test/a test/b
  tar zxf tmp.tar.gz -C test/a && (mv test/a${xfce_install}/* test/a) && (rm test/a/root -rf)
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
      rm $file -rf && echo "delete repeat file : $file"
    fi
  done

  # 删除空目录，去掉冗余目录
  find $to_dir -type d -empty -delete
  # 拷贝编译后的 xfce4 到系统目录
  cd $to_dir && (cp ./ / -r -n) && cd ..

  # 预装运行环境
  apt install dbus-x11 xrdp -y

  # xfdesktop 需要库的路径, xfdesktop 不能运行，基本上桌面就是黑屏了，可能有 dock 栏和最上面的状态栏
  libdir=`pwd`"/a/usr"
  echo "LD_LIBRARY_PATH=\"${libdir}/lib:${libdir}/local/lib:${libdir}/lib/x86_64-linux-gnu\" xfce4-session" > ~/.xsession

  # 重启系统，然后可以利用 windows 下 remote desktop 体验最新版本的 xfce4 了, 最新版本的 xfce4 还是很漂亮的

fi

cd ..
echo "${CYAN}build all success - [${GREEN} ok ${CYAN}]${NC}"
