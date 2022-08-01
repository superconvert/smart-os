#!/bin/sh

wget https://www.x.org/archive/individual/xserver/xorg-server-1.20.11.tar.bz2
tar xf xorg-server-1.20.11.tar.bz2 -C ./
apt install xutils-dev libtool m4 pkg-config xtrans-dev libpixman-1-dev libdrm-dev libx11-dev libgl-dev libgcrypt-dev libxkbfile-dev libxfont-dev libpciaccess-dev libepoxy-dev libgbm-dev libegl1-mesa-dev -y
cd xorg-server-1.20.11 && ./autogen.sh
