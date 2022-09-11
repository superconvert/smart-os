#!/bin/sh

# set +e
# 所有的编译基于 Ubuntu 18.04.6 LTS 编译通过, 其它系统请自行调整脚本

# 预装工具
if [ -f "/usr/bin/apt" ]; then
  apt install autoconf autoconf-archive automake libtool make nasm cmake m4 pkg-config llvm-10 clang-10 intltool -y || exit
  apt install check bison flex python3-pip python3.8-dev libpython-dev gperf gtk-doc-tools xsltproc -y || exit
  apt install libssl-dev libcurl4-openssl-dev libsqlite3-dev libmicrohttpd-dev libarchive-dev libgirepository1.0-dev -y || exit
  # 需要安装, 安装主题, 显卡驱动, 安装字库否则不能正常显示
  apt install libudev-dev libdbus-1-dev hicolor-icon-theme libgl1-mesa-dri fonts-dejavu-core -y || exit
  # dbus-launch
  apt install dbus-x11 gobject-introspection -y || exit
fi

if [ -f "/usr/bin/yum" ]; then
  echo "xxx"
fi

# undefined symbol: Py_InitModule4_64 需要安装高版本的 python3.8-dbg
pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple ninja
pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple meson
pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple gi-docgen

#-----------------------------------------------
#
# 导入公共变量
#
#-----------------------------------------------
. ./common.sh

GETTEXT_SRC_URL=https://ftp.gnu.org/pub/gnu/gettext/gettext-0.21.tar.gz
LIBMNT_SRC_URL=https://mirrors.edge.kernel.org/pub/linux/utils/util-linux/v2.36/util-linux-2.36.tar.xz
LIBZIP_SRC_URL=https://libzip.org/download/libzip-1.9.2.tar.xz
LIBELF_SRC_URL=https://sourceware.org/elfutils/ftp/0.186/elfutils-0.186.tar.bz2
CAIRO_SRC_URL=https://www.cairographics.org/releases/cairo-1.16.0.tar.xz
PIXMAN_SRC_URL=https://www.cairographics.org/releases/pixman-0.40.0.tar.gz
LIBPNG_SRC_URL=https://nchc.dl.sourceforge.net/project/libpng/libpng16/1.6.37/libpng-1.6.37.tar.xz
ZLIB_SRC_URL=https://nchc.dl.sourceforge.net/project/libpng/zlib/1.2.11/zlib-1.2.11.tar.xz
FREETYPE_SRC_URL=https://nchc.dl.sourceforge.net/project/freetype/freetype2/2.12.0/freetype-2.12.0.tar.xz
LIBJPEGTURBO_SRC_URL=https://sourceforge.net/projects/libjpeg-turbo/files/2.1.0/libjpeg-turbo-2.1.0.tar.gz
XKBCOMMON_SRC_URL=https://xkbcommon.org/download/libxkbcommon-1.4.1.tar.xz
XFCE_SRC_URL=https://archive.xfce.org/xfce/4.16/fat_tarballs/xfce-4.16.tar.bz2
XTERM_SRC_URL=https://invisible-island.net/datafiles/release/xterm.tar.gz
NCURSES_SRC_URL=https://invisible-island.net/datafiles/release/ncurses.tar.gz
MTDEV_SRC_URL=https://bitmath.org/code/mtdev/mtdev-1.1.6.tar.bz2

# download from https://github.com
LIBFFI_SRC_URL=https://github.com/libffi/libffi/releases/download/v3.4.2/libffi-3.4.2.tar.gz
LIBTHAI_SRC_URL=https://github.com/tlwg/libthai/releases/download/v0.1.29/libthai-0.1.29.tar.xz
LIBDATRIE_SRC_URL=https://github.com/tlwg/libdatrie/releases/download/v0.2.13/libdatrie-0.2.13.tar.xz
LIBPCRE2_SRC_URL=https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.40/pcre2-10.40.tar.gz
HARFBUZZ_SRC_URL=https://github.com/harfbuzz/harfbuzz/releases/download/5.1.0/harfbuzz-5.1.0.tar.xz
FRIBIDI_SRC_URL=https://github.com/fribidi/fribidi/releases/download/v1.0.12/fribidi-1.0.12.tar.xz
DBUS1_SRC_URL=https://github.com/freedesktop/dbus/archive/refs/tags/dbus-1.12.22.tar.gz
LIBEPOXY_SRC_URL=https://github.com/anholt/libepoxy/archive/refs/tags/1.5.10.tar.gz
GRAPHENE_SRC_URL=https://github.com/ebassi/graphene/archive/refs/tags/1.10.8.tar.gz
LIBPAM_SRC_URL=https://github.com/linux-pam/linux-pam/releases/download/v1.5.2/Linux-PAM-1.5.2.tar.xz
XRDP_SRC_URL=https://github.com/neutrinolabs/xrdp/releases/download/v0.9.19/xrdp-0.9.19.tar.gz
LIBWACOM_SRC_URL=https://github.com/linuxwacom/libwacom/releases/download/libwacom-2.4.0/libwacom-2.4.0.tar.xz

# download from https://gitlab.freedesktop.org
UPOWER_SRC_URL=https://gitlab.freedesktop.org/upower/upower/-/archive/v1.90.0/upower-v1.90.0.tar.gz
WAYLANDCORE_SRC_URL=https://gitlab.freedesktop.org/wayland/wayland/-/archive/1.20.93/wayland-1.20.93.tar.gz
WAYLANDPROT_SRC_URL=https://gitlab.freedesktop.org/wayland/wayland-protocols/-/archive/1.25/wayland-protocols-1.25.tar.gz
MESA_SRC_URL=https://gitlab.freedesktop.org/mesa/mesa/-/archive/mesa-20.0.0-rc3/mesa-mesa-20.0.0-rc3.tar.gz
MKFONTDIR_SRC_URL=https://gitlab.freedesktop.org/xorg/app/mkfontdir/-/archive/mkfontdir-1.0.7/mkfontdir-mkfontdir-1.0.7.tar.bz2
BDFTOPCF_SRC_URL=https://gitlab.freedesktop.org/xorg/util/bdftopcf/-/archive/bdftopcf-1.1/bdftopcf-bdftopcf-1.1.tar.gz
MKFONTSCALE_SRC_URL=https://gitlab.freedesktop.org/xorg/app/mkfontscale/-/archive/mkfontscale-1.2.2/mkfontscale-mkfontscale-1.2.2.tar.bz2

LIBDRM_SRC_URL=https://dri.freedesktop.org/libdrm/libdrm-2.4.110.tar.xz
GSTREAMER_SRC_URL=https://gstreamer.freedesktop.org/src/gstreamer/gstreamer-1.20.2.tar.xz
FONTCFG_SRC_URL=https://www.freedesktop.org/software/fontconfig/release/fontconfig-2.13.96.tar.xz
STARTUPNOTI_SRC_URL=http://www.freedesktop.org/software/startup-notification/releases/startup-notification-0.12.tar.gz
LIBEVDEV_SRC_URL=https://www.freedesktop.org/software/libevdev/libevdev-1.13.0.tar.xz
LIBINPUT_SRC_URL=https://www.freedesktop.org/software/libinput/libinput-1.19.4.tar.xz

# download from https://gitlab.gnome.org
GLIB_SRC_URL=https://download.gnome.org/sources/glib/2.62/glib-2.62.0.tar.xz
PANGO_SRC_URL=https://download.gnome.org/sources/pango/1.48/pango-1.48.9.tar.xz
GTKX_SRC_URL=https://download.gnome.org/sources/gtk%2B/3.24/gtk%2B-3.24.9.tar.xz
LIBXML_SRC_URL=https://download.gnome.org/sources/libxml2/2.9/libxml2-2.9.8.tar.xz
LIBWNCK_SRC_URL=https://download.gnome.org/sources/libwnck/3.36/libwnck-3.36.0.tar.xz
LIBNOTIFY_SRC_URL=https://download.gnome.org/sources/libnotify/0.8/libnotify-0.8.0.tar.xz
LIBATK_CORE_SRC_URL=https://download.gnome.org/sources/at-spi2-core/2.38/at-spi2-core-2.38.0.tar.xz
LIBATK_BRIDGE_SRC_URL=https://download.gnome.org/sources/at-spi2-atk/2.38/at-spi2-atk-2.38.0.tar.xz

LIBATK_SRC_URL=https://gitlab.gnome.org/GNOME/atk/-/archive/2.38.0/atk-2.38.0.tar.gz
LIBGUDEV_SRC_URL=https://gitlab.gnome.org/GNOME/libgudev/-/archive/236/libgudev-236.tar.gz
GDKPIXBUF_SRC_URL=https://gitlab.gnome.org/GNOME/gdk-pixbuf/-/archive/2.42.8/gdk-pixbuf-2.42.8.tar.gz
GOBJINTROSPE_SRC_URL=https://github.com/GNOME/gobject-introspection/archive/refs/tags/1.72.0.tar.gz

# download from https://www.x.org/releases/individual
XI_SRC_URL=https://www.x.org/releases/individual/lib/libXi-1.8.tar.gz
XTST_SRC_URL=https://www.x.org/releases/individual/lib/libXtst-1.2.3.tar.gz
LIBSM_SRC_URL=https://www.x.org/releases/individual/lib/libSM-1.2.3.tar.gz
LIBICE_SRC_URL=https://www.x.org/releases/individual/lib/libICE-1.0.10.tar.gz
LIBX11_SRC_URL=https://www.x.org/releases/individual/lib/libX11-1.8.tar.gz
LIBXCB_SRC_URL=https://www.x.org/releases/individual/lib/libxcb-1.15.tar.xz
XT_SRC_URL=https://www.x.org/releases/individual/lib/libXt-1.2.1.tar.gz
XAU_SRC_URL=https://www.x.org/releases/individual/lib/libXau-1.0.10.tar.xz
XAW_SRC_URL=https://www.x.org/releases/individual/lib/libXaw-1.0.14.tar.gz
XMU_SRC_URL=https://www.x.org/releases/individual/lib/libXmu-1.1.3.tar.gz
XPM_SRC_URL=https://www.x.org/releases/individual/lib/libXpm-3.5.13.tar.gz
XEXT_SRC_URL=https://www.x.org/releases/individual/lib/libXext-1.3.4.tar.gz
XDMCP_SRC_URL=https://www.x.org/releases/individual/lib/libXdmcp-1.1.3.tar.gz
XINERAMA_SRC_URL=https://www.x.org/releases/individual/lib/libXinerama-1.1.4.tar.gz
XFIXES_SRC_URL=https://www.x.org/releases/individual/lib/libXfixes-6.0.0.tar.gz
XTRANS_SRC_URL=https://www.x.org/releases/individual/lib/xtrans-1.4.0.tar.gz
XRANDR_SRC_URL=https://www.x.org/releases/individual/lib/libXrandr-1.5.2.tar.gz
XRENDER_SRC_URL=https://www.x.org/releases/individual/lib/libXrender-0.9.10.tar.gz
XDAMAGE_SRC_URL=https://www.x.org/releases/individual/lib/libXdamage-1.1.5.tar.gz
XXF86VM_SRC_URL=https://www.x.org/releases/individual/lib/libXxf86vm-1.1.4.tar.gz
XSHMFENCE_SRC_URL=https://www.x.org/releases/individual/lib/libxshmfence-1.3.tar.gz
PCIACCESS_SRC_URL=https://www.x.org/releases/individual/lib/libpciaccess-0.16.tar.gz
XORGMACROS_SRC_URL=https://www.x.org/releases/individual/util/util-macros-1.19.3.tar.gz
ICEAUTH_SRC_URL=https://www.x.org/releases/individual/app/iceauth-1.0.9.tar.xz
XCBUTIL_SRC_URL=https://www.x.org/releases/individual/xcb/xcb-util-0.4.0.tar.gz
KBPROTO_SRC_URL=https://www.x.org/releases/individual/proto/kbproto-1.0.7.tar.gz
LIBXPROTO_SRC_URL=https://www.x.org/releases/individual/proto/xproto-7.0.31.tar.gz
XEXTPROTO_SRC_URL=https://www.x.org/releases/individual/proto/xextproto-7.3.0.tar.gz
XCBPROTO_SRC_URL=https://www.x.org/releases/individual/proto/xcb-proto-1.15.2.tar.gz
XORGPROTO_SRC_URL=https://www.x.org/releases/individual/proto/xorgproto-2022.2.tar.xz
XKBCOMP_SRC_URL=https://www.x.org/releases/individual/app/xkbcomp-1.4.5.tar.gz
LIBXCVT_SRC_URL=https://www.x.org/releases/individual/lib/libxcvt-0.1.2.tar.xz
XKBFILE_SRC_URL=https://www.x.org/releases/individual/lib/libxkbfile-1.1.0.tar.gz
FONTENC_SRC_URL=https://www.x.org/releases/individual/lib/libfontenc-1.1.6.tar.xz
FONTUTIL_SRC_URL=https://www.x.org/releases/individual/font/font-util-1.3.3.tar.xz
FONTMISC_SRC_URL=https://www.x.org/releases/individual/font/font-misc-misc-1.1.2.tar.bz2
XFONT_SRC_URL=https://www.x.org/releases/individual/lib/libXfont2-2.0.6.tar.xz
XKBDATA_SRC_URL=https://www.x.org/releases/individual/data/xkbdata-1.0.1.tar.bz2
XKBDCFG_SRC_URL=https://www.x.org/releases/individual/data/xkeyboard-config/xkeyboard-config-2.36.tar.xz
XSERVER_SRC_URL=https://www.x.org/releases/individual/xserver/xorg-server-21.1.4.tar.xz
XF86INPUT_SRC_URL=https://www.x.org/releases/individual/driver/xf86-input-libinput-1.2.1.tar.xz

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
ZLIB_SRC_NAME=$(download_src ${ZLIB_SRC_URL})
LIBZIP_SRC_NAME=$(download_src ${LIBZIP_SRC_URL})
LIBELF_SRC_NAME=$(download_src ${LIBELF_SRC_URL})
LIBTHAI_SRC_NAME=$(download_src ${LIBTHAI_SRC_URL})
LIBDATRIE_SRC_NAME=$(download_src ${LIBDATRIE_SRC_URL})
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
WAYLANDCORE_SRC_NAME=$(download_src ${WAYLANDCORE_SRC_URL})
WAYLANDPROT_SRC_NAME=$(download_src ${WAYLANDPROT_SRC_URL})
STARTUPNOTI_SRC_NAME=$(download_src ${STARTUPNOTI_SRC_URL})
LIBGUDEV_SRC_NAME=$(download_src ${LIBGUDEV_SRC_URL})
UPOWER_SRC_NAME=$(download_src ${UPOWER_SRC_URL})
LIBWNCK_SRC_NAME=$(download_src ${LIBWNCK_SRC_URL})
LIBATK_CORE_SRC_NAME=$(download_src ${LIBATK_CORE_SRC_URL})
LIBATK_BRIDGE_SRC_NAME=$(download_src ${LIBATK_BRIDGE_SRC_URL})
LIBJPEGTURBO_SRC_NAME=$(download_src ${LIBJPEGTURBO_SRC_URL})
LIBXPROTO_SRC_NAME=$(download_src ${LIBXPROTO_SRC_URL})
XTRANS_SRC_NAME=$(download_src ${XTRANS_SRC_URL})
LIBSM_SRC_NAME=$(download_src ${LIBSM_SRC_URL})
LIBICE_SRC_NAME=$(download_src ${LIBICE_SRC_URL})
LIBX11_SRC_NAME=$(download_src ${LIBX11_SRC_URL})
XRANDR_SRC_NAME=$(download_src ${XRANDR_SRC_URL})
XINERAMA_SRC_NAME=$(download_src ${XINERAMA_SRC_URL})
XRENDER_SRC_NAME=$(download_src ${XRENDER_SRC_URL})
KBPROTO_SRC_NAME=$(download_src ${KBPROTO_SRC_URL})
XKBCOMMON_SRC_NAME=$(download_src ${XKBCOMMON_SRC_URL})
XEXT_SRC_NAME=$(download_src ${XEXT_SRC_URL})
XEXTPROTO_SRC_NAME=$(download_src ${XEXTPROTO_SRC_URL})
XCBPROTO_SRC_NAME=$(download_src ${XCBPROTO_SRC_URL})
LIBXCB_SRC_NAME=$(download_src ${LIBXCB_SRC_URL})
XCBUTIL_SRC_NAME=$(download_src ${XCBUTIL_SRC_URL})
ICEAUTH_SRC_NAME=$(download_src ${ICEAUTH_SRC_URL})
XT_SRC_NAME=$(download_src ${XT_SRC_URL})
XAU_SRC_NAME=$(download_src ${XAU_SRC_URL})
XAW_SRC_NAME=$(download_src ${XAW_SRC_URL})
XMU_SRC_NAME=$(download_src ${XMU_SRC_URL})
XPM_SRC_NAME=$(download_src ${XPM_SRC_URL})
XDMCP_SRC_NAME=$(download_src ${XDMCP_SRC_URL})
XRANDR_SRC_NAME=$(download_src ${XRANDR_SRC_URL})
XRENDER_SRC_NAME=$(download_src ${XRENDER_SRC_URL})
KBPROTO_SRC_NAME=$(download_src ${KBPROTO_SRC_URL})
XEXT_SRC_NAME=$(download_src ${XEXT_SRC_URL})
XEXTPROTO_SRC_NAME=$(download_src ${XEXTPROTO_SRC_URL})
XCBPROTO_SRC_NAME=$(download_src ${XCBPROTO_SRC_URL})
LIBXCB_SRC_NAME=$(download_src ${LIBXCB_SRC_URL})
XCBUTIL_SRC_NAME=$(download_src ${XCBUTIL_SRC_URL})
XAU_SRC_NAME=$(download_src ${XAU_SRC_URL})
XDMCP_SRC_NAME=$(download_src ${XDMCP_SRC_URL})
XORGPROTO_SRC_NAME=$(download_src ${XORGPROTO_SRC_URL})
XFIXES_SRC_NAME=$(download_src ${XFIXES_SRC_URL})
XDAMAGE_SRC_NAME=$(download_src ${XDAMAGE_SRC_URL})
XSHMFENCE_SRC_NAME=$(download_src ${XSHMFENCE_SRC_URL})
XXF86VM_SRC_NAME=$(download_src ${XXF86VM_SRC_URL})
XI_SRC_NAME=$(download_src ${XI_SRC_URL})
XTST_SRC_NAME=$(download_src ${XTST_SRC_URL})
XFCE_SRC_NAME=$(download_src ${XFCE_SRC_URL})
MESA_SRC_NAME=$(download_src ${MESA_SRC_URL})
LIBDRM_SRC_NAME=$(download_src ${LIBDRM_SRC_URL})
GSTREAMER_SRC_NAME=$(download_src ${GSTREAMER_SRC_URL})
LIBPAM_SRC_NAME=$(download_src ${LIBPAM_SRC_URL})
XRDP_SRC_NAME=$(download_src ${XRDP_SRC_URL})
XKBCOMP_SRC_NAME=$(download_src ${XKBCOMP_SRC_URL})
LIBXCVT_SRC_NAME=$(download_src ${LIBXCVT_SRC_URL})
XKBFILE_SRC_NAME=$(download_src ${XKBFILE_SRC_URL})
FONTENC_SRC_NAME=$(download_src ${FONTENC_SRC_URL})
XFONT_SRC_NAME=$(download_src ${XFONT_SRC_URL})
FONTUTIL_SRC_NAME=$(download_src ${FONTUTIL_SRC_URL})
MKFONTDIR_SRC_NAME=$(download_src ${MKFONTDIR_SRC_URL})
MKFONTSCALE_SRC_NAME=$(download_src ${MKFONTSCALE_SRC_URL})
BDFTOPCF_SRC_NAME=$(download_src ${BDFTOPCF_SRC_URL})
FONTMISC_SRC_NAME=$(download_src ${FONTMISC_SRC_URL})
XSERVER_SRC_NAME=$(download_src ${XSERVER_SRC_URL})
NCURSES_SRC_NAME=$(download_src ${NCURSES_SRC_URL})
XTERM_SRC_NAME=$(download_src ${XTERM_SRC_URL})
XKBDATA_SRC_NAME=$(download_src ${XKBDATA_SRC_URL})
XKBDCFG_SRC_NAME=$(download_src ${XKBDCFG_SRC_URL})
MTDEV_SRC_NAME=$(download_src ${MTDEV_SRC_URL})
LIBEVDEV_SRC_NAME=$(download_src ${LIBEVDEV_SRC_URL})
LIBWACOM_SRC_NAME=$(download_src ${LIBWACOM_SRC_URL})
LIBINPUT_SRC_NAME=$(download_src ${LIBINPUT_SRC_URL})
XF86INPUT_SRC_NAME=$(download_src ${XF86INPUT_SRC_URL})
DBUS1_SRC_NAME=$(download_src ${DBUS1_SRC_URL} "dbus-")
LIBEPOXY_SRC_NAME=$(download_src ${LIBEPOXY_SRC_URL} "libepoxy-")
GRAPHENE_SRC_NAME=$(download_src ${GRAPHENE_SRC_URL} "graphene-")
XORGMACROS_SRC_NAME=$(download_src ${XORGMACROS_SRC_URL})
PCIACCESS_SRC_NAME=$(download_src ${PCIACCESS_SRC_URL} "xorg-libpciaccess-")
GOBJINTROSPE_SRC_NAME=$(download_src ${GOBJINTROSPE_SRC_URL} "gobject-introspection-")
# gtk 因为 + 号，需要特殊处理
GTKX_SRC_NAME=$(echo $(file_name ${GTKX_SRC_URL}) | sed 's/%2B/+/')
if [ ! -f "${GTKX_SRC_NAME}" ]; then
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
ZLIB_SRC_DIR=$(unzip_src ".tar.xz" ${ZLIB_SRC_NAME}); echo "unzip ${ZLIB_SRC_NAME} source code"
LIBZIP_SRC_DIR=$(unzip_src ".tar.xz" ${LIBZIP_SRC_NAME}); echo "unzip ${LIBZIP_SRC_NAME} source code"
LIBELF_SRC_DIR=$(unzip_src ".tar.bz2" ${LIBELF_SRC_NAME}); echo "unzip ${LIBELF_SRC_NAME} source code"
LIBTHAI_SRC_DIR=$(unzip_src ".tar.xz" ${LIBTHAI_SRC_NAME}); echo "unzip ${LIBTHAI_SRC_NAME} source code"
LIBDATRIE_SRC_DIR=$(unzip_src ".tar.xz" ${LIBDATRIE_SRC_NAME}); echo "unzip ${LIBDATRIE_SRC_NAME} source code"
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
DBUS1_SRC_DIR=$(unzip_src ".tar.gz" ${DBUS1_SRC_NAME}); echo "unzip ${DBUS1_SRC_NAME} source code"
LIBATK_SRC_DIR=$(unzip_src ".tar.gz" ${LIBATK_SRC_NAME}); echo "unzip ${LIBATK_SRC_NAME} source code"
LIBEPOXY_SRC_DIR=$(unzip_src ".tar.gz" ${LIBEPOXY_SRC_NAME}); echo "unzip ${LIBEPOXY_SRC_NAME} source code"
LIBATK_CORE_SRC_DIR=$(unzip_src ".tar.xz" ${LIBATK_CORE_SRC_NAME}); echo "unzip ${LIBATK_CORE_SRC_NAME} source code"
LIBATK_BRIDGE_SRC_DIR=$(unzip_src ".tar.xz" ${LIBATK_BRIDGE_SRC_NAME}); echo "unzip ${LIBATK_BRIDGE_SRC_NAME} source code"
GRAPHENE_SRC_DIR=$(unzip_src ".tar.gz" ${GRAPHENE_SRC_NAME}); echo "unzip ${GRAPHENE_SRC_NAME} source code"
GETTEXT_SRC_DIR=$(unzip_src ".tar.gz" ${GETTEXT_SRC_NAME}); echo "unzip ${GETTEXT_SRC_NAME} source code"
WAYLANDCORE_SRC_DIR=$(unzip_src ".tar.gz" ${WAYLANDCORE_SRC_NAME}); echo "unzip ${WAYLANDCORE_SRC_NAME} source code"
WAYLANDPROT_SRC_DIR=$(unzip_src ".tar.gz" ${WAYLANDPROT_SRC_NAME}); echo "unzip ${WAYLANDPROT_SRC_NAME} source code"
STARTUPNOTI_SRC_DIR=$(unzip_src ".tar.gz" ${STARTUPNOTI_SRC_NAME}); echo "unzip ${STARTUPNOTI_SRC_NAME} source code"
LIBGUDEV_SRC_DIR=$(unzip_src ".tar.gz" ${LIBGUDEV_SRC_NAME}); echo "unzip ${LIBGUDEV_SRC_NAME} source code"
UPOWER_SRC_DIR=$(unzip_src ".tar.gz" ${UPOWER_SRC_NAME}); echo "unzip ${UPOWER_SRC_NAME} source code"
GOBJINTROSPE_SRC_DIR=$(unzip_src ".tar.gz" ${GOBJINTROSPE_SRC_NAME}); echo "unzip ${GOBJINTROSPE_SRC_NAME} source code"
LIBWNCK_SRC_DIR=$(unzip_src ".tar.xz" ${LIBWNCK_SRC_NAME}); echo "unzip ${LIBWNCK_SRC_NAME} source code"
GSTREAMER_SRC_DIR=$(unzip_src ".tar.xz" ${GSTREAMER_SRC_NAME}); echo "unzip ${GSTREAMER_SRC_NAME} source code"
LIBDRM_SRC_DIR=$(unzip_src ".tar.xz" ${LIBDRM_SRC_NAME}); echo "unzip ${LIBDRM_SRC_NAME} source code"
LIBJPEGTURBO_SRC_DIR=$(unzip_src ".tar.gz" ${LIBJPEGTURBO_SRC_NAME}); echo "unzip ${LIBJPEGTURBO_SRC_NAME} source code"
LIBXPROTO_SRC_DIR=$(unzip_src ".tar.gz" ${LIBXPROTO_SRC_NAME}); echo "unzip ${LIBXPROTO_SRC_NAME} source code"
LIBSM_SRC_DIR=$(unzip_src ".tar.gz" ${LIBSM_SRC_NAME}); echo "unzip ${LIBSM_SRC_NAME} source code"
LIBICE_SRC_DIR=$(unzip_src ".tar.gz" ${LIBICE_SRC_NAME}); echo "unzip ${LIBICE_SRC_NAME} source code"
LIBX11_SRC_DIR=$(unzip_src ".tar.gz" ${LIBX11_SRC_NAME}); echo "unzip ${LIBX11_SRC_NAME} source code"
XRANDR_SRC_DIR=$(unzip_src ".tar.gz" ${XRANDR_SRC_NAME}); echo "unzip ${XRANDR_SRC_NAME} source code"
XINERAMA_SRC_DIR=$(unzip_src ".tar.gz" ${XINERAMA_SRC_NAME}); echo "unzip ${XINERAMA_SRC_NAME} source code"
XRENDER_SRC_DIR=$(unzip_src ".tar.gz" ${XRENDER_SRC_NAME}); echo "unzip ${XRENDER_SRC_NAME} source code"
KBPROTO_SRC_DIR=$(unzip_src ".tar.gz" ${KBPROTO_SRC_NAME}); echo "unzip ${KBPROTO_SRC_NAME} source code"
XKBCOMMON_SRC_DIR=$(unzip_src ".tar.xz" ${XKBCOMMON_SRC_NAME}); echo "unzip ${XKBCOMMON_SRC_NAME} source code"
XEXT_SRC_DIR=$(unzip_src ".tar.gz" ${XEXT_SRC_NAME}); echo "unzip ${XEXT_SRC_NAME} source code"
XEXTPROTO_SRC_DIR=$(unzip_src ".tar.gz" ${XEXTPROTO_SRC_NAME}); echo "unzip ${XEXTPROTO_SRC_NAME} source code"
XTRANS_SRC_DIR=$(unzip_src ".tar.gz" ${XTRANS_SRC_NAME}); echo "unzip ${XTRANS_SRC_NAME} source code"
XCBPROTO_SRC_DIR=$(unzip_src ".tar.gz" ${XCBPROTO_SRC_NAME}); echo "unzip ${XCBPROTO_SRC_NAME} source code"
LIBXCB_SRC_DIR=$(unzip_src ".tar.xz" ${LIBXCB_SRC_NAME}); echo "unzip ${LIBXCB_SRC_NAME} source code"
XCBUTIL_SRC_DIR=$(unzip_src ".tar.gz" ${XCBUTIL_SRC_NAME}); echo "unzip ${XCBUTIL_SRC_NAME} source code"
ICEAUTH_SRC_DIR=$(unzip_src ".tar.xz" ${ICEAUTH_SRC_NAME}); echo "unzip ${ICEAUTH_SRC_NAME} source code"
XT_SRC_DIR=$(unzip_src ".tar.gz" ${XT_SRC_NAME}); echo "unzip ${XT_SRC_NAME} source code"
XAU_SRC_DIR=$(unzip_src ".tar.xz" ${XAU_SRC_NAME}); echo "unzip ${XAU_SRC_NAME} source code"
XAW_SRC_DIR=$(unzip_src ".tar.gz" ${XAW_SRC_NAME}); echo "unzip ${XAW_SRC_NAME} source code"
XMU_SRC_DIR=$(unzip_src ".tar.gz" ${XMU_SRC_NAME}); echo "unzip ${XMU_SRC_NAME} source code"
XPM_SRC_DIR=$(unzip_src ".tar.gz" ${XPM_SRC_NAME}); echo "unzip ${XPM_SRC_NAME} source code"
XDMCP_SRC_DIR=$(unzip_src ".tar.gz" ${XDMCP_SRC_NAME}); echo "unzip ${XDMCP_SRC_NAME} source code"
XORGPROTO_SRC_DIR=$(unzip_src ".tar.xz" ${XORGPROTO_SRC_NAME}); echo "unzip ${XORGPROTO_SRC_NAME} source code"
XFIXES_SRC_DIR=$(unzip_src ".tar.gz" ${XFIXES_SRC_NAME}); echo "unzip ${XFIXES_SRC_NAME} source code"
XDAMAGE_SRC_DIR=$(unzip_src ".tar.gz" ${XDAMAGE_SRC_NAME}); echo "unzip ${XDAMAGE_SRC_NAME} source code"
XSHMFENCE_SRC_DIR=$(unzip_src ".tar.gz" ${XSHMFENCE_SRC_NAME}); echo "unzip ${XSHMFENCE_SRC_NAME} source code"
XXF86VM_SRC_DIR=$(unzip_src ".tar.gz" ${XXF86VM_SRC_NAME}); echo "unzip ${XXF86VM_SRC_NAME} source code"
XI_SRC_DIR=$(unzip_src ".tar.gz" ${XI_SRC_NAME}); echo "unzip ${XI_SRC_NAME} source code"
XTST_SRC_DIR=$(unzip_src ".tar.gz" ${XTST_SRC_NAME}); echo "unzip ${XTST_SRC_NAME} source code"
XORGMACROS_SRC_DIR=$(unzip_src ".tar.gz" ${XORGMACROS_SRC_NAME}); echo "unzip ${XORGMACROS_SRC_NAME} source code"
PCIACCESS_SRC_DIR=$(unzip_src ".tar.gz" ${PCIACCESS_SRC_NAME}); echo "unzip ${PCIACCESS_SRC_NAME} source code"
MESA_SRC_DIR=$(unzip_src ".tar.gz" ${MESA_SRC_NAME}); echo "unzip ${MESA_SRC_NAME} source code"
GTKX_SRC_DIR=$(unzip_src ".tar.xz" ${GTKX_SRC_NAME}); echo "unzip ${GTKX_SRC_NAME} source code"
LIBPAM_SRC_DIR=$(unzip_src ".tar.xz" ${LIBPAM_SRC_NAME}); echo "unzip ${LIBPAM_SRC_NAME} source code"
XRDP_SRC_DIR=$(unzip_src ".tar.gz" ${XRDP_SRC_NAME}); echo "unzip ${XRDP_SRC_NAME} source code"
XKBCOMP_SRC_DIR=$(unzip_src ".tar.gz" ${XKBCOMP_SRC_NAME}); echo "unzip ${XKBCOMP_SRC_NAME} source code"
LIBXCVT_SRC_DIR=$(unzip_src ".tar.xz" ${LIBXCVT_SRC_NAME}); echo "unzip ${LIBXCVT_SRC_NAME} source code"
XKBFILE_SRC_DIR=$(unzip_src ".tar.gz" ${XKBFILE_SRC_NAME}); echo "unzip ${XKBFILE_SRC_NAME} source code"
FONTENC_SRC_DIR=$(unzip_src ".tar.xz" ${FONTENC_SRC_NAME}); echo "unzip ${FONTENC_SRC_NAME} source code"
XFONT_SRC_DIR=$(unzip_src ".tar.xz" ${XFONT_SRC_NAME}); echo "unzip ${XFONT_SRC_NAME} source code"
FONTUTIL_SRC_DIR=$(unzip_src ".tar.xz" ${FONTUTIL_SRC_NAME}); echo "unzip ${FONTUTIL_SRC_NAME} source code"
MKFONTDIR_SRC_DIR=$(unzip_src ".tar.bz2" ${MKFONTDIR_SRC_NAME}); echo "unzip ${MKFONTDIR_SRC_NAME} source code"
MKFONTSCALE_SRC_DIR=$(unzip_src ".tar.bz2" ${MKFONTSCALE_SRC_NAME}); echo "unzip ${MKFONTSCALE_SRC_NAME} source code"
BDFTOPCF_SRC_DIR=$(unzip_src ".tar.gz" ${BDFTOPCF_SRC_NAME}); echo "unzip ${BDFTOPCF_SRC_NAME} source code"
FONTMISC_SRC_DIR=$(unzip_src ".tar.bz2" ${FONTMISC_SRC_NAME}); echo "unzip ${FONTMISC_SRC_NAME} source code"
XSERVER_SRC_DIR=$(unzip_src ".tar.xz" ${XSERVER_SRC_NAME}); echo "unzip ${XSERVER_SRC_NAME} source code"
MTDEV_SRC_DIR=$(unzip_src ".tar.bz2" ${MTDEV_SRC_NAME}); echo "unzip ${MTDEV_SRC_NAME} source code"
LIBWACOM_SRC_DIR=$(unzip_src ".tar.xz" ${LIBWACOM_SRC_NAME}); echo "unzip ${LIBWACOM_SRC_NAME} source code"
LIBEVDEV_SRC_DIR=$(unzip_src ".tar.xz" ${LIBEVDEV_SRC_NAME}); echo "unzip ${LIBEVDEV_SRC_NAME} source code"
LIBINPUT_SRC_DIR=$(unzip_src ".tar.xz" ${LIBINPUT_SRC_NAME}); echo "unzip ${LIBINPUT_SRC_NAME} source code"
XF86INPUT_SRC_DIR=$(unzip_src ".tar.xz" ${XF86INPUT_SRC_NAME}); echo "unzip ${XF86INPUT_SRC_NAME} source code"
NCURSES_SRC_DIR=$(unzip_src ".tar.gz" ${NCURSES_SRC_NAME}); echo "unzip ${NCURSES_SRC_NAME} source code"
XTERM_SRC_DIR=$(unzip_src ".tar.gz" ${XTERM_SRC_NAME}); echo "unzip ${XTERM_SRC_NAME} source code"
XKBDCFG_SRC_DIR=$(unzip_src ".tar.xz" ${XKBDCFG_SRC_NAME}); echo "unzip ${XKBDCFG_SRC_NAME} source code"
XKBDATA_SRC_DIR=$(unzip_src ".tar.bz2" ${XKBDATA_SRC_NAME}); echo "unzip ${XKBDATA_SRC_NAME} source code"
XFCE_SRC_DIR=${build_dir}"/"$(file_dirname ${XFCE_SRC_NAME} .tar.bz2)
if [ ! -d "${XFCE_SRC_DIR}" ]; then
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
  -I${xfce_loc_inc}/dbus-1.0 \
  -I${xfce_loc_inc}/freetype2 \
  -I${xfce_loc_inc}/thunarx-3 \
  -I${xfce_loc_inc}/garcon-1 \
  -I${xfce_loc_inc}/garcon-gtk3-1 \
  -I${xfce_x86_64_inc} \
  -I/usr/include/python3.8 \
  -I/usr/include/dbus-1.0 \
  -I/usr/lib/x86_64-linux-gnu/dbus-1.0/include"

xfce_lib=${xfce_install}/usr/lib
xfce_share=${xfce_install}/usr/share
xfce_loc_lib=${xfce_install}/usr/local/lib
xfce_loc_share=${xfce_install}/usr/local/share
library_path=" \
  -L${glibc_install}/lib64 \
  -L${xfce_install}/lib64 \
  -L${xfce_lib} \
  -L${xfce_loc_lib} \
  -L${xfce_lib}/x86_64-linux-gnu \
  -L${xfce_instal}/opt/libjpeg-turbo/lib64"

pkg_cfg1="${xfce_lib}/pkgconfig"
pkg_cfg2="${xfce_share}/pkgconfig"
pkg_cfg3="${xfce_loc_lib}/pkgconfig"
pkg_cfg4="${xfce_loc_share}/pkgconfig"
pkg_cfg5="${xfce_lib}/x86_64-linux-gnu/pkgconfig"
pkg_cfg6="${xfce_install}/opt/libjpeg-turbo/lib64/pkgconfig"
pkg_cfg7="/usr/lib/pkgconfig:/usr/share/pkgconfig:/usr/local/share/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig"
cfg_opt="--with-sysroot=${xfce_install}"
xwin_opt="--x-includes=${xfce_loc_inc} --x-libraries=${xfce_loc_lib}"

export CFLAGS="${include_path}"
export CXXFLAGS="${include_path}"
export LDFLAGS="${library_path}"

export PKG_CONFIG_SYSROOT_DIR="${xfce_install}"
export PKG_CONFIG_TOP_BUILD_DIR="${xfce_install}"
export PKG_CONFIG_PATH="${pkg_cfg1}:${pkg_cfg2}:${pkg_cfg3}:${pkg_cfg4}:${pkg_cfg5}:${pkg_cfg6}:${pkg_cfg7}"

# 解决 libxcb 编译问题
mkdir -pv ${xfce_share}/aclocal
mkdir -pv ${xfce_loc_share}/aclocal

# 解决 xcb-util 编译问题
# 解决 pciaccess: must install xorg-macros 1.8 or later before running autoconf/autogen
export ACLOCAL="aclocal -I /usr/share/aclocal -I ${xfce_share}/aclocal -I ${xfce_loc_share}/aclocal"

# 编译过程中会寻找 *.gir 的文件，.gir 的目录就是这个
export XDG_DATA_DIRS="${xfce_share}:${xfce_loc_share}:${xfce_share}/gir-1.0:$XDG_DATA_DIRS"
export GDK_PIXBUF_PIXDATA="${xfce_install}/usr/bin/gdk-pixbuf-pixdata"

# 编译过程中有工具需要 libffi.so.8 库的，需要加载一下，否则会出现找不到 libffi.so.8
export PATH="${xfce_install}/usr/bin:${xfce_install}/usr/local/bin:$PATH"
export LD_LIBRARY_PATH="${xfce_lib}:${xfce_loc_lib}:${xfce_lib}/x86_64-linux-gnu:${xfce_install}/opt/libjpeg-turbo/lib64:$LD_LIBRARY_PATH"
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
setup_girtools() {
  mkdir -p ${xfce_install}"/usr/bin"
  for gir_name in $(find /usr/bin -name "g-ir-*")
  do
    if [ -f "${xfce_install}${gir_name}" ]; then
      continue
    fi
    ln -s "${gir_name}" "${xfce_install}${gir_name}" || (echo "setup tools ${gir_name} failed" && exit)
  done

  gi_makefile=/usr/share/gobject-introspection-1.0/Makefile.introspection
  mkdir -pv ${xfce_share}/gobject-introspection-1.0
  if [ ! -f "${xfce_install}${gi_makefile}" ]; then
    ln -s "${gi_makefile}" "${xfce_install}${gi_makefile}"
  fi
}
setup_girtools

#---------------------------
# meson 编译 编译参数一览 https://mesonbuild.com/Reference-tables.html
#---------------------------
meson_build() {
  local name=$1
  local srcdir=$2
  shift
  shift
  if [ ! -f .${name} ]; then
    echo "${CYAN}build ${name} begin${NC}" && cd ${srcdir} && mkdir -pv build
    meson setup build --prefix=/usr --pkg-config-path=${PKG_CONFIG_PATH} "$@"
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
    echo "${CYAN}build ${name} begin${NC}" && cd ${srcdir}
    ./configure ${cfg_opt} ${xwin_opt}
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
  shift
  shift
  if [ ! -f .${name} ]; then
    echo "${CYAN}build ${name} begin${NC}" && cd ${srcdir} 
    if [ -f autogen.sh ]; then
      #autoreconf -i
      ./autogen.sh
    fi
    if [ -f CMakeLists.txt ]; then
      cmake . -DCMAKE_INSTALL_PREFIX=/usr
    fi
    if [ -f ./configure ]; then
      ./configure ${cfg_opt} "$@" ${xwin_opt}
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
  # 编译 zlib
  common_build zlib ${ZLIB_SRC_DIR}
  # 编译 libzip
  common_build libzip ${LIBZIP_SRC_DIR}
  # 编译 libpng
  common_build libpng ${LIBPNG_SRC_DIR}
  # 编译 libelf
  common_build libelf ${LIBELF_SRC_DIR}
  # 编译 libdatrie
  common_build libdatrie ${LIBDATRIE_SRC_DIR}
  if [ ! -f "/usr/local/bin/trietool" ]; then
    ln -s ${xfce_install}/usr/local/bin/trietool /usr/local/bin/trietool
  fi
  # 编译 libthai
  common_build libthai ${LIBTHAI_SRC_DIR}
  # 编译 libpcre2
  common_build libpcre2 ${LIBPCRE2_SRC_DIR}
  # 编译 glib
  meson_build glib ${GLIB_SRC_DIR}
  if [ ! -f "/usr/bin/glib-mkenums" ]; then
    ln -s ${xfce_install}/usr/bin/glib-mkenums /usr/bin/glib-mkenums
  fi
  # 在编译机上测试 xfce4 是否能正常工作
  if [ "${with_xfce_test}" = true ]; then
    tar zcf tmp.tar.gz ${xfce_install}
  fi
  # 编译 wayland-core ( documentation 依赖 graphviz 粘连了图形库 )
  meson_build wayland-core ${WAYLANDCORE_SRC_DIR} -Ddocumentation=false
  if [ ! -f "/usr/bin/wayland-scanner" ]; then
    ln -s ${xfce_install}/usr/bin/wayland-scanner /usr/bin/wayland-scanner
  fi
  # 编译 wayland-protocols
  meson_build wayland-protocols ${WAYLANDPROT_SRC_DIR}
  # 编译 libjpeg
  common_build libjpeg-turbo ${LIBJPEGTURBO_SRC_DIR}
  # 编译 xorg-macros
  common_build xorg-macros ${XORGMACROS_SRC_DIR}
  # 编译 libxproto
  common_build libxproto ${LIBXPROTO_SRC_DIR}
  # 编译 xorgproto
  common_build xorgproto ${XORGPROTO_SRC_DIR}
  # 编译 xau
  common_build xau ${XAU_SRC_DIR}
  # 编译 xtrans
  common_build xtrans ${XTRANS_SRC_DIR}
  # 编译 xcb-proto
  common_build xcb-proto ${XCBPROTO_SRC_DIR}
  # 编译 libxcb
  common_build libxcb ${LIBXCB_SRC_DIR}
  # 编译 libice
  common_build libice ${LIBICE_SRC_DIR}
  # 编译 libsm
  common_build libsm ${LIBSM_SRC_DIR}
  # 编译 libx11
  common_build libx11 ${LIBX11_SRC_DIR} --with-keysymdefdir="${xfce_install}/usr/local/include/X11"
  # 编译 xext
  common_build xext ${XEXT_SRC_DIR}
  # 编译 xrender
  common_build xrender ${XRENDER_SRC_DIR}
  # 编译 xrandr
  common_build xrandr ${XRANDR_SRC_DIR}
  # 编译 iceauth
  common_build iceauth ${ICEAUTH_SRC_DIR}
  # 编译 libxcb-util
  common_build libxcb-util ${XCBUTIL_SRC_DIR}
  # 编译 kbproto
  common_build kbproto ${KBPROTO_SRC_DIR}
  # 编译 xextproto
  common_build xextproto ${XEXTPROTO_SRC_DIR}
  # 编译 xdmcp
  common_build xdmcp ${XDMCP_SRC_DIR}
  # 编译 xfixes
  common_build xfixes ${XFIXES_SRC_DIR}
  # 编译 xdamage
  common_build xdamage ${XDAMAGE_SRC_DIR}
  # 编译 xinerama
  common_build xinerama ${XINERAMA_SRC_DIR}
  # 编译 xshmfence
  common_build xshmfence ${XSHMFENCE_SRC_DIR}
  # 编译 xxf86vm
  common_build xxf86vm ${XXF86VM_SRC_DIR}
  # 编译 xi ( 问题解决见上面的注释 )
  common_build xi ${XI_SRC_DIR}
  # 编译 xtst
  common_build xtst ${XTST_SRC_DIR}
  # 编译 xkbcommon
  meson_build xkbcommon ${XKBCOMMON_SRC_DIR} -Denable-docs=false
  # 编译 gdkpixbuf
  meson_build gdkpixbuf ${GDKPIXBUF_SRC_DIR}
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
  # 编译 cairo ( 这个需要 x window，所以放到 libx11 之后编译 )
  cairo_opt="--with-x --enable-png=yes --enable-xlib=yes --enable-xlib-xrender=yes --enable-gtk-doc-html=no"
  common_build cairo ${CAIRO_SRC_DIR} ${cairo_opt}
  # 编译 harfbuzz
  meson_build harfbuzz ${HARFBUZZ_SRC_DIR} -Dcairo=enabled
  # 编译 fribidi
  meson_build fribidi ${FRIBIDI_SRC_DIR}
  # 编译 pango
  meson_build pango ${PANGO_SRC_DIR}
  # 编译 dbus-1( 我们的系统需要编译，如果在当前系统上运行 xfce4，需要注释掉，否则就会和系统自带的 dbus-1 冲突 )
  # common_build dbus-1 ${DBUS1_SRC_DIR} --disable-tests
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
  # 编译 graphene
  meson_build graphene ${GRAPHENE_SRC_DIR}
  # 编译 mesa
  meson_build mesa ${MESA_SRC_DIR}
  # 编译 libepoxy
  meson_build libepoxy ${LIBEPOXY_SRC_DIR}
  # 编译 libgudev ( upower 依赖此库, 依赖: apt install libudev-dev )
  meson_build libgudev ${LIBGUDEV_SRC_DIR}
  # 编译 upower ( xfce4-power-manager 依赖此库， 依赖: libgudev )
  # meson_build upower ${UPOWER_SRC_DIR} -Dc_args="-DENOTSUP=95"
  # 编译 gstreamer
  meson_build gstreamer ${GSTREAMER_SRC_DIR} -Ddoc=disabled
  # 编译 gtk+
  meson_build gtk+ ${GTKX_SRC_DIR}
  # 编译 mesa
  meson_build mesa ${MESA_SRC_DIR}
  # 编译 libepoxy
  meson_build libepoxy ${LIBEPOXY_SRC_DIR}
  # 编译 libstartup-notification0 ( 很多 xfce4 应用依赖此库, 依赖: libxcb-util-dev )
  # common_build startupnoti ${STARTUPNOTI_SRC_DIR}
  # 编译 libgudev ( upower 依赖此库, 依赖: apt install libudev-dev )
  meson_build libgudev ${LIBGUDEV_SRC_DIR}
  # 编译 upower ( xfce4-power-manager 依赖此库， 依赖: libgudev )
  meson_build upower ${UPOWER_SRC_DIR} -Dc_args="-DENOTSUP=95"
  # 编译 gettext 解决 libintl 的问题 gtk+
  #common_build gettext ${GETTEXT_SRC_DIR}
  # 编译 gstreamer
  meson_build gstreamer ${GSTREAMER_SRC_DIR}
  # 编译 gtk+
  meson_build gtk+ ${GTKX_SRC_DIR}
  # 编译 libwnck
  meson_build libwnck ${LIBWNCK_SRC_DIR}
  # 编译 libnotify
  meson_build libnotify ${LIBNOTIFY_SRC_DIR} -Dman=false -Dgtk_doc=false -Ddocbook_docs=disabled
  # 编译 libpam
  common_build libpam ${LIBPAM_SRC_DIR}
  # 编译 xrdp
  common_build xrdp ${XRDP_SRC_DIR}
  # 编译 libxcvt
  meson_build libxcvt ${LIBXCVT_SRC_DIR}
  # 编译 xkbfile
  common_build xkbfile ${XKBFILE_SRC_DIR}
  # 编译 xkbcomp
  common_build xkbcomp ${XKBCOMP_SRC_DIR}
  # 编译 fontenc
  common_build fontenc ${FONTENC_SRC_DIR}
  # 编译 xfont
  common_build xfont ${XFONT_SRC_DIR}
  # 编译 xserver
  common_build xserver ${XSERVER_SRC_DIR} --with-log-dir="/var/log"  --with-fontrootdir="/usr/local/share/fonts/X11"
  # 编译 xt ( xterm )
  common_build xt ${XT_SRC_DIR}
  # 编译 xmu ( xterm )
  common_build xmu ${XMU_SRC_DIR}
  # 编译 xpm ( xterm )
  common_build xpm ${XPM_SRC_DIR}
  # 编译 xaw ( xterm )
  common_build xaw ${XAW_SRC_DIR}
  # 编译 xkbcfg ( 键盘数据 xkbdata, Xorg need it )
  meson_build xkbcfg ${XKBDCFG_SRC_DIR}
  # 编译 xkbdata
  # common_build xkbdata ${XKBDATA_SRC_DIR}
  # 编译 ncurses 
  # common_build ncurses ${NCURSES_SRC_DIR}"-6.3"
  # 编译 xterm
  # common_build xterm ${XTERM_SRC_DIR}"-372"
  # fontutil
  common_build fontutil ${FONTUTIL_SRC_DIR}
  # mkfontdir
  common_build mkfontdir ${MKFONTDIR_SRC_DIR}
  # bdftopcf
  common_build bdftopcf ${BDFTOPCF_SRC_DIR}
  # mkfontscale
  common_build mkfontscale ${MKFONTSCALE_SRC_DIR}
  # fontmisc
  mkdir -p /usr/local/share/fonts/X11/util
  cp ${FONTUTIL_SRC_DIR}/map-* /usr/local/share/fonts/X11/util/
  common_build fontmisc ${FONTMISC_SRC_DIR}
  # mtdev ( libinput )
  common_build mtdev ${MTDEV_SRC_DIR}
  # libevdev ( libinput )
  meson_build libevdev ${LIBEVDEV_SRC_DIR} -Ddocumentation=disabled
  # libwacom ( libinput )
  meson_build libwacom ${LIBWACOM_SRC_DIR} -Ddocumentation=disabled -Dtests=disabled
  # libinput ( xf86input )
  meson_build libinput ${LIBINPUT_SRC_DIR}
  # xf86input ( xf86-input-libinput 只是 libinput 的一个封装，能够使 libinput 用于 X 上的输入设备 )
  # 代替其他用于 X 输入的软件包（即以 xf86-input- 为前缀的软件包 )
  common_build xf86input ${XF86INPUT_SRC_DIR}

  # 编译 xfce
  cd ${XFCE_SRC_DIR}

  # 必须去掉这个，否则 xfce 编译不过，做的还是有点差，和 gtk+ 的编译还是差一个档次
  #unset PKG_CONFIG_SYSROOT_DIR
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
  #apt install dbus-x11 xrdp -y
  #apt install xrdp -y

  # xfdesktop 需要库的路径, xfdesktop 不能运行，基本上桌面就是黑屏了，可能有 dock 栏和最上面的状态栏
  libdir=`pwd`"/a/usr"
  libjpegdir=`pwd`"/a/opt/libjpeg-turbo/lib64"
  echo "LD_LIBRARY_PATH=\"${libdir}/lib:${libdir}/local/lib:${libdir}/lib/x86_64-linux-gnu:${libjpegdir}\" xfce4-session" > ~/.xsession

  # 重启系统，然后可以利用 windows 下 remote desktop 体验最新版本的 xfce4 了, 最新版本的 xfce4 还是很漂亮的

fi

cd ..
echo "${CYAN}build all success - [${GREEN} ok ${CYAN}]${NC}"
