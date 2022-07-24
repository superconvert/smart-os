#!/bin/sh

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

BUSYBOX_SOURCE_URL=https://busybox.net/downloads/busybox-1.34.1.tar.bz2
if [ ! -f "busybox-1.34.1.tar.bz2" ]; then 
  wget $BUSYBOX_SOURCE_URL 
fi

cd ..

#---------------------------------------------
#
# 制作内核和 rootfs
#
#---------------------------------------------
mkdir -pv work

if [ ! -d "./work/linux-4.14.9" ]; then
  tar xvf source/linux-4.14.9.tar.xz -C work/
fi

if [ ! -d "./work/busybox-1.34.1" ]; then
  tar xvf source/busybox-1.34.1.tar.bz2 -C work/
fi

cd work

# 编译内核, 最终所有模块都装到目录 /lib/modules/4.14.9
if [ ! -f "./linux-4.14.9/arch/x86_64/boot/bzImage" ]; then 
  # Enable the VESA framebuffer for graphics support.
  # 网络需要 TUN/TAP 驱动 [ Device Drivers ] ---> [ Network device support ] ---> [ Universal TUN/TAP device driver support ]
  cd linux-4.14.9 && make x86_64_defconfig && sed -i "s/.*CONFIG_FB_VESA.*/CONFIG_FB_VESA=y/" .config && make bzImage -j8 && cd ..
  #cd linux-4.14.9 && make x86_64_defconfig && make bzImage -j8 && make modules && make modules_install && cd ..
fi

# 编译 busybox 
if [ ! -d "./busybox-1.34.1/_install" ]; then
  # 静态编译 sed -i "s/# CONFIG_STATIC is not set/CONFIG_STATIC=y/g" .config
  cd busybox-1.34.1 && make defconfig && make -j8 && make install && cd ..
fi

cd..
