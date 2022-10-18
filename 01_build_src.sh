#!/bin/sh

if [ -f "/usr/bin/apt" ]; then
  apt -y install gcc g++ make gawk flex bison libelf-dev libssl-dev bridge-utils
fi

if [ -f "/usr/bin/yum" ]; then
  yum -y install gcc gcc-c++ make gawk flex bison elfutils-libelf libssl-dev bridge-utils
fi

#-----------------------------------------------
#
# 导入公共变量 ( xfce4 需要 5.4.0 的内核 )
#
#-----------------------------------------------
. ./common.sh

#LINUX_SRC_URL=https://kernel.org/pub/linux/kernel/v4.x/linux-4.14.9.tar.xz
LINUX_SRC_URL=https://mirror.bjtu.edu.cn/kernel/linux/kernel/v5.x/linux-5.8.6.tar.xz
#GLIBC_SRC_URL=https://ftp.gnu.org/gnu/glibc/glibc-2.32.tar.bz2
GLIBC_SRC_URL=https://mirrors.ustc.edu.cn/gnu/glibc/glibc-2.27.tar.xz
BUSYBOX_SRC_URL=https://busybox.net/downloads/busybox-1.34.1.tar.bz2
LSHW_SRC_URL=https://www.ezix.org/software/files/lshw-B.02.19.2.tar.gz
PCIUTILS_SRC_URL=http://mj.ucw.cz/download/linux/pci/pciutils-3.8.0.tar.gz
OPENSSL_SRC_URL=https://www.openssl.org/source/openssl-1.1.1q.tar.gz
OPENSSH_SRC_URL=https://cdn.openbsd.org/pub/OpenBSD/OpenSSH/portable/openssh-8.8p1.tar.gz
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
LSHW_SRC_NAME=$(download_src ${LSHW_SRC_URL})
PCIUTILS_SRC_NAME=$(download_src ${PCIUTILS_SRC_URL})
OPENSSL_SRC_NAME=$(download_src ${OPENSSL_SRC_URL})
OPENSSH_SRC_NAME=$(download_src ${OPENSSH_SRC_URL})
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
GLIBC_SRC_DIR=$(unzip_src ".tar.xz" ${GLIBC_SRC_NAME}); echo "unzip ${GLIBC_SRC_NAME} source code"
BUSYBOX_SRC_DIR=$(unzip_src ".tar.bz2" ${BUSYBOX_SRC_NAME}); echo "unzip ${BUSYBOX_SRC_NAME} source code"
LSHW_SRC_DIR=$(unzip_src ".tar.gz" ${LSHW_SRC_NAME}); echo "unzip ${LSHW_SRC_NAME} source code"
PCIUTILS_SRC_DIR=$(unzip_src ".tar.gz" ${PCIUTILS_SRC_NAME}); echo "unzip ${PCIUTILS_SRC_NAME} source code"
OPENSSL_SRC_DIR=$(unzip_src ".tar.gz" ${OPENSSL_SRC_NAME}); echo "unzip ${OPENSSL_SRC_NAME} source code"
OPENSSH_SRC_DIR=$(unzip_src ".tar.gz" ${OPENSSH_SRC_NAME}); echo "unzip ${OPENSSH_SRC_NAME} source code"
GCC_SRC_DIR=$(unzip_src ".tar.xz" ${GCC_SRC_NAME}); echo "unzip ${GCC_SRC_NAME} source code"
BINUTILS_SRC_DIR=$(unzip_src ".tar.xz" ${BINUTILS_SRC_NAME}); echo "unzip ${BINUTILS_SRC_NAME} source code"

#-----------------------------------------------
#
# 重新生成目标文件
#
#----------------------------------------------- 
if [ "$1" = "rebuild" ]; then
  echo "rebuild"
  cd ${build_dir} 
  rm -rf linux_install glibc_install busybox_install pciutils_install openssl_install openssh_install gcc_install binutils_install
  cd ..
fi

#---------------------------------------------
#
# 编译源码 
#
#---------------------------------------------
cd ${build_dir}

# 编译内核, 最终所有模块都装到目录 /lib/modules/5.8.6
if [ ! -d "linux_install" ]; then 
  mkdir -pv linux_install && cd ${LINUX_SRC_DIR} && make mrproper && make x86_64_defconfig

  # 下面的配置主要显卡相关的配置，必须开启, 内核 3d 加速 https://wiki.gentoo.org/wiki/Xorg/Hardware_3D_acceleration_guide
  # xfce4 需要 drm 支持，内核版本尽量大于等于 18.04 的，所以选取了 5.8.6 的内核
  sed -i "s/# CONFIG_X86_SYSFB is not set/CONFIG_X86_SYSFB=y/" .config

  sed -i "/CONFIG_VIRTUALIZATION=y/i\CONFIG_HAVE_KVM_IRQCHIP=y" .config
  sed -i "/CONFIG_VIRTUALIZATION=y/i\CONFIG_HAVE_KVM_IRQFD=y" .config
  sed -i "/CONFIG_VIRTUALIZATION=y/i\CONFIG_HAVE_KVM_IRQ_ROUTING=y" .config
  sed -i "/CONFIG_VIRTUALIZATION=y/i\CONFIG_HAVE_KVM_EVENTFD=y" .config
  sed -i "/CONFIG_VIRTUALIZATION=y/i\CONFIG_KVM_MMIO=y" .config
  sed -i "/CONFIG_VIRTUALIZATION=y/i\CONFIG_KVM_ASYNC_PF=y" .config
  sed -i "/CONFIG_VIRTUALIZATION=y/i\CONFIG_HAVE_KVM_MSI=y" .config
  sed -i "/CONFIG_VIRTUALIZATION=y/i\CONFIG_HAVE_KVM_CPU_RELAX_INTERCEPT=y" .config
  sed -i "/CONFIG_VIRTUALIZATION=y/i\CONFIG_KVM_VFIO=y" .config
  sed -i "/CONFIG_VIRTUALIZATION=y/i\CONFIG_KVM_GENERIC_DIRTYLOG_READ_PROTECT=y" .config
  sed -i "/CONFIG_VIRTUALIZATION=y/i\CONFIG_KVM_COMPAT=y" .config
  sed -i "/CONFIG_VIRTUALIZATION=y/i\CONFIG_HAVE_KVM_IRQ_BYPASS=y" .config
  sed -i "/CONFIG_VIRTUALIZATION=y/i\CONFIG_HAVE_KVM_NO_POLL=y" .config

  sed -i "s/# CONFIG_KVM is not set/CONFIG_KVM=y/" .config
  sed -i "/CONFIG_AS_AVX512=y/i\CONFIG_KVM_INTEL=y" .config
  sed -i "/CONFIG_AS_AVX512=y/i\CONFIG_KVM_AMD=y" .config
  sed -i "/CONFIG_AS_AVX512=y/i\CONFIG_KVM_MMU_AUDIT=y" .config

  sed -i "/CONFIG_HAVE_IOREMAP_PROT=y/i\CONFIG_USER_RETURN_NOTIFIER=y" .config
  sed -i "/CONFIG_BLK_PM=y/i\CONFIG_BLK_MQ_VIRTIO=y" .config
  sed -i "/CONFIG_ASN1=y/i\CONFIG_PREEMPT_NOTIFIERS=y" .config
  sed -i "/# CONFIG_MEMORY_HOTPLUG is not set/i\CONFIG_MEMORY_ISOLATION=y" .config
  sed -i "/CONFIG_PHYS_ADDR_T_64BIT=y/i\CONFIG_CONTIG_ALLOC=y" .config

  sed -i "s/# CONFIG_CMA is not set/CONFIG_CMA=y/" .config
  sed -i "/# CONFIG_ZPOOL is not set/i\# CONFIG_CMA_DEBUG is not set" .config
  sed -i "/# CONFIG_ZPOOL is not set/i\# CONFIG_CMA_DEBUGFS is not set" .config
  sed -i "/# CONFIG_ZPOOL is not set/i\CONFIG_CMA_AREAS=7" .config

  sed -i "/CONFIG_ARCH_USES_HIGH_VMA_FLAGS=y/i\CONFIG_HMM_MIRROR=y" .config
  sed -i "/# end of Memory Management options/i\CONFIG_MAPPING_DIRTY_HELPERS=y" .config

  sed -i "/CONFIG_ALLOW_DEV_COREDUMP=y/i\CONFIG_WANT_DEV_COREDUMP=y" .config
  sed -i "/# CONFIG_DEBUG_DRIVER is not set/i\CONFIG_DEV_COREDUMP=y" .config
  sed -i "/# CONFIG_BLK_DEV_RBD is not set/i\# CONFIG_VIRTIO_BLK is not set" .config
  sed -i "/# CONFIG_NLMON is not set/i\# CONFIG_VIRTIO_NET is not set" .config
  sed -i "/# CONFIG_IPMI_HANDLER is not set/i\# CONFIG_VIRTIO_CONSOLE is not set" .config
  sed -i "/# CONFIG_APPLICOM is not set/i\# CONFIG_HW_RANDOM_VIRTIO is not set" .config

  sed -i "s/# CONFIG_AGP_SIS is not set/CONFIG_AGP_SIS=y/" .config
  sed -i "s/# CONFIG_AGP_VIA is not set/CONFIG_AGP_VIA=y/" .config
  sed -i "s/# CONFIG_DRM_DP_AUX_CHARDEV is not set/CONFIG_DRM_DP_AUX_CHARDEV=y/" .config
  sed -i "s/# CONFIG_DRM_LOAD_EDID_FIRMWARE is not set/CONFIG_DRM_LOAD_EDID_FIRMWARE=y/" .config

  sed -i "/# CONFIG_DRM_DP_CEC is not set/a\CONFIG_DRM_TTM=y" .config
  sed -i "/CONFIG_DRM_TTM=y/a\CONFIG_DRM_TTM_DMA_PAGE_POOL=y" .config
  sed -i "/CONFIG_DRM_TTM_DMA_PAGE_POOL=y/a\CONFIG_DRM_VRAM_HELPER=y" .config
  sed -i "/CONFIG_DRM_VRAM_HELPER=y/a\CONFIG_DRM_TTM_HELPER=y" .config
  sed -i "/CONFIG_DRM_TTM_HELPER=y/a\CONFIG_DRM_GEM_SHMEM_HELPER=y" .config
  sed -i "/CONFIG_DRM_GEM_SHMEM_HELPER=y/a\CONFIG_DRM_VM=y" .config
  sed -i "/CONFIG_DRM_VM=y/a\CONFIG_DRM_SCHED=y" .config

  sed -i "/# CONFIG_DRM_RADEON is not set/d" .config
  sed -i "/# CONFIG_DRM_AMDGPU is not set/d" .config
  sed -i "/# CONFIG_DRM_NOUVEAU is not set/d" .config
  sed -i "/CONFIG_DRM_I915=y/i\CONFIG_DRM_RADEON=y" .config
  sed -i "/CONFIG_DRM_I915=y/i\CONFIG_DRM_RADEON_USERPTR=y" .config
  sed -i "/CONFIG_DRM_I915=y/i\CONFIG_DRM_AMDGPU=y" .config
  sed -i "/CONFIG_DRM_I915=y/i\CONFIG_DRM_AMDGPU_SI=y" .config
  sed -i "/CONFIG_DRM_I915=y/i\CONFIG_DRM_AMDGPU_CIK=y" .config
  sed -i "/CONFIG_DRM_I915=y/i\CONFIG_DRM_AMDGPU_USERPTR=y" .config
  sed -i "/CONFIG_DRM_I915=y/i\# CONFIG_DRM_AMDGPU_GART_DEBUGFS is not set\n" .config
  sed -i "/CONFIG_DRM_I915=y/i\#\n# ACP (Audio CoProcessor) Configuration\n#" .config
  sed -i "/CONFIG_DRM_I915=y/i\# CONFIG_DRM_AMD_ACP is not set" .config
  sed -i "/CONFIG_DRM_I915=y/i\# end of ACP (Audio CoProcessor) Configuration\n" .config
  sed -i "/CONFIG_DRM_I915=y/i\#\n# Display Engine Configuration\n#" .config
  sed -i "/CONFIG_DRM_I915=y/i\CONFIG_DRM_AMD_DC=y" .config
  sed -i "/CONFIG_DRM_I915=y/i\CONFIG_DRM_AMD_DC_DCN=y" .config
  sed -i "/CONFIG_DRM_I915=y/i\# CONFIG_DRM_AMD_DC_HDCP is not set" .config
  sed -i "/CONFIG_DRM_I915=y/i\# CONFIG_DEBUG_KERNEL_DC is not set" .config
  sed -i "/CONFIG_DRM_I915=y/i\# end of Display Engine Configuration\n" .config
  sed -i "/CONFIG_DRM_I915=y/i\CONFIG_HSA_AMD=y" .config
  sed -i "/CONFIG_DRM_I915=y/i\CONFIG_DRM_NOUVEAU=y" .config
  sed -i "/CONFIG_DRM_I915=y/i\CONFIG_NOUVEAU_LEGACY_CTX_SUPPORT=y" .config
  sed -i "/CONFIG_DRM_I915=y/i\CONFIG_NOUVEAU_DEBUG=5" .config
  sed -i "/CONFIG_DRM_I915=y/i\CONFIG_NOUVEAU_DEBUG_DEFAULT=3" .config
  sed -i "/CONFIG_DRM_I915=y/i\# CONFIG_NOUVEAU_DEBUG_MMU is not set" .config
  sed -i "/CONFIG_DRM_I915=y/i\CONFIG_DRM_NOUVEAU_BACKLIGHT=y" .config

  sed -i "s/# CONFIG_DRM_I915_GVT is not set/CONFIG_DRM_I915_GVT=y/" .config
  sed -i "s/# CONFIG_DRM_VGEM is not set/CONFIG_DRM_VGEM=y/" .config

  sed -i "s/# CONFIG_DRM_VKMS is not set/CONFIG_DRM_VKMS=y/" .config
  sed -i "s/# CONFIG_DRM_VMWGFX is not set/CONFIG_DRM_VMWGFX=y\nCONFIG_DRM_VMWGFX_FBCON=y/" .config
  sed -i "s/# CONFIG_DRM_GMA500 is not set/CONFIG_DRM_GMA500=y\nCONFIG_DRM_GMA600=y\nCONFIG_DRM_GMA3600=y/" .config
  sed -i "s/# CONFIG_DRM_MGAG200 is not set/CONFIG_DRM_MGAG200=y/" .config
  sed -i "s/# CONFIG_DRM_QXL is not set/CONFIG_DRM_QXL=y/" .config
  sed -i "s/# CONFIG_DRM_BOCHS is not set/CONFIG_DRM_BOCHS=y\n# CONFIG_DRM_VIRTIO_GPU is not set/" .config
  sed -i "s/# CONFIG_DRM_VIRTIO_GPU is not set/CONFIG_DRM_VIRTIO_GPU=y/" .config

  sed -i "s/# CONFIG_DRM_ETNAVIV is not set/CONFIG_DRM_ETNAVIV=y\nCONFIG_DRM_ETNAVIV_THERMAL=y/" .config
  sed -i "s/# CONFIG_DRM_CIRRUS_QEMU is not set/CONFIG_DRM_CIRRUS_QEMU=y/" .config
  sed -i "s/# CONFIG_DRM_GM12U320 is not set/CONFIG_DRM_GM12U320=y/" .config
  sed -i "s/# CONFIG_DRM_VBOXVIDEO is not set/CONFIG_DRM_VBOXVIDEO=y/" .config
  sed -i "s/# CONFIG_DRM_LEGACY is not set/CONFIG_DRM_LEGACY=y/" .config
  sed -i "/CONFIG_DRM_PANEL_ORIENTATION_QUIRKS=y/i\# CONFIG_DRM_TDFX is not set" .config
  sed -i "/CONFIG_DRM_PANEL_ORIENTATION_QUIRKS=y/i\# CONFIG_DRM_R128 is not set" .config
  sed -i "/CONFIG_DRM_PANEL_ORIENTATION_QUIRKS=y/i\# CONFIG_DRM_I810 is not set" .config
  sed -i "/CONFIG_DRM_PANEL_ORIENTATION_QUIRKS=y/i\# CONFIG_DRM_MGA is not set" .config
  sed -i "/CONFIG_DRM_PANEL_ORIENTATION_QUIRKS=y/i\# CONFIG_DRM_SIS is not set" .config
  sed -i "/CONFIG_DRM_PANEL_ORIENTATION_QUIRKS=y/i\# CONFIG_DRM_VIA is not set" .config
  sed -i "/CONFIG_DRM_PANEL_ORIENTATION_QUIRKS=y/i\# CONFIG_DRM_SAVAGE is not set" .config

  sed -i "s/# CONFIG_FIRMWARE_EDID is not set/CONFIG_FIRMWARE_EDID=y\nCONFIG_FB_DDC=y\nCONFIG_FB_BOOT_VESA_SUPPORT=y/" .config
  sed -i "/CONFIG_FB_MODE_HELPERS=y/i\CONFIG_FB_SVGALIB=y" .config
  sed -i "/CONFIG_FB_MODE_HELPERS=y/i\CONFIG_FB_BACKLIGHT=y" .config

  sed -i "s/# CONFIG_FB_CIRRUS is not set/CONFIG_FB_CIRRUS=y/" .config
  sed -i "s/# CONFIG_FB_VGA16 is not set/CONFIG_FB_VGA16=y/" .config
  sed -i "s/# CONFIG_FB_UVESA is not set/CONFIG_FB_UVESA=y/" .config
  sed -i "s/# CONFIG_FB_VESA is not set/CONFIG_FB_VESA=y/" .config

  sed -i "s/# CONFIG_FB_OPENCORES is not set/CONFIG_FB_OPENCORES=y/" .config

  sed -i "s/# CONFIG_FB_NVIDIA is not set/CONFIG_FB_NVIDIA=y\nCONFIG_FB_NVIDIA_I2C=y\nCONFIG_FB_NVIDIA_DEBUG=y\nCONFIG_FB_NVIDIA_BACKLIGHT=y/" .config
  sed -i "s/# CONFIG_FB_RIVA is not set/CONFIG_FB_RIVA=y\n# CONFIG_FB_RIVA_I2C is not set\n# CONFIG_FB_RIVA_DEBUG is not set\nCONFIG_FB_RIVA_BACKLIGHT=y/" .config
  sed -i "s/# CONFIG_FB_I740 is not set/CONFIG_FB_I740=y/" .config
  sed -i "s/# CONFIG_FB_RADEON is not set/CONFIG_FB_RADEON=y\nCONFIG_FB_RADEON_I2C=y\nCONFIG_FB_RADEON_BACKLIGHT=y\n# CONFIG_FB_RADEON_DEBUG is not set/" .config

  sed -i "s/# CONFIG_FB_3DFX is not set/CONFIG_FB_3DFX=y\nCONFIG_FB_3DFX_ACCEL=y\nCONFIG_FB_3DFX_I2C=y/" .config
  sed -i "s/# CONFIG_FB_VOODOO1 is not set/CONFIG_FB_VOODOO1=y/" .config
  sed -i "s/# CONFIG_FB_VT8623 is not set/CONFIG_FB_VT8623=y/" .config
  sed -i "s/# CONFIG_FB_TRIDENT is not set/CONFIG_FB_TRIDENT=y/" .config
  sed -i "s/# CONFIG_FB_IBM_GXT4500 is not set/CONFIG_FB_IBM_GXT4500=y/" .config
  sed -i "s/# CONFIG_FB_SIMPLE is not set/CONFIG_FB_SIMPLE=y/" .config

  sed -i "/CONFIG_HDMI=y/i\CONFIG_VGASTATE=y" .config
  sed -i "/# CONFIG_VIRT_DRIVERS is not set/i\CONFIG_IRQ_BYPASS_MANAGER=y" .config
  sed -i "/CONFIG_VIRTIO_MENU=y/i\CONFIG_VIRTIO=y" .config

  sed -i "s/# CONFIG_VIRTIO_PCI is not set/CONFIG_VIRTIO_PCI=y\nCONFIG_VIRTIO_PCI_LEGACY=y\n# CONFIG_VIRTIO_BALLOON is not set\n# CONFIG_VIRTIO_INPUT is not set/" .config
  sed -i "s/# CONFIG_ACPI_WMI is not set/CONFIG_ACPI_WMI=y/" .config
  sed -i "/# CONFIG_ACERHDF is not set/i\CONFIG_WMI_BMOF=y" .config
  sed -i "/# CONFIG_ACERHDF is not set/i\# CONFIG_ALIENWARE_WMI is not set" .config
  sed -i "/# CONFIG_ACERHDF is not set/i\# CONFIG_HUAWEI_WMI is not set" .config
  sed -i "/# CONFIG_ACERHDF is not set/i\# CONFIG_INTEL_WMI_SBL_FW_UPDATE is not set" .config
  sed -i "/# CONFIG_ACERHDF is not set/i\# CONFIG_INTEL_WMI_THUNDERBOLT is not set" .config
  sed -i "/# CONFIG_ACERHDF is not set/i\CONFIG_MXM_WMI=y" .config
  sed -i "/# CONFIG_ACERHDF is not set/i\# CONFIG_PEAQ_WMI is not set" .config
  sed -i "/# CONFIG_ACERHDF is not set/i\# CONFIG_XIAOMI_WMI is not set" .config

  sed -i "/# CONFIG_APPLE_GMUX is not set/i\# CONFIG_ACER_WMI is not set" .config
  sed -i "/CONFIG_EEEPC_LAPTOP=y/i\# CONFIG_ASUS_WMI is not set" .config
  sed -i "/# CONFIG_AMILO_RFKILL is not set/i\# CONFIG_DELL_WMI_AIO is not set" .config
  sed -i "/# CONFIG_AMILO_RFKILL is not set/i\# CONFIG_DELL_WMI_LED is not set" .config
  sed -i "/# CONFIG_IBM_RTL is not set/i\# CONFIG_HP_WMI is not set" .config
  sed -i "/# CONFIG_SAMSUNG_LAPTOP is not set/i\# CONFIG_MSI_WMI is not set" .config
  sed -i "/# CONFIG_ACPI_CMPC is not set/i\# CONFIG_TOSHIBA_WMI is not set" .config
  sed -i "/# CONFIG_PANASONIC_LAPTOP is not set/i\# CONFIG_LG_LAPTOP is not set" .config

  sed -i "/# CONFIG_CRYPTO_TEST is not set/a\CONFIG_CRYPTO_ENGINE=m" .config
  sed -i "/# CONFIG_CRYPTO_DEV_SAFEXCEL is not set/i\CONFIG_CRYPTO_DEV_VIRTIO=m" .config

  sed -i "/# CONFIG_DMA_API_DEBUG is not set/i\CONFIG_DMA_CMA=y\n" .config
  sed -i "/# CONFIG_DMA_API_DEBUG is not set/i\#\n# Default contiguous memory area size:\n#" .config
  sed -i "/# CONFIG_DMA_API_DEBUG is not set/i\CONFIG_CMA_SIZE_MBYTES=0" .config
  sed -i "/# CONFIG_DMA_API_DEBUG is not set/i\CONFIG_CMA_SIZE_SEL_MBYTES=y" .config
  sed -i "/# CONFIG_DMA_API_DEBUG is not set/i\# CONFIG_CMA_SIZE_SEL_PERCENTAGE is not set" .config
  sed -i "/# CONFIG_DMA_API_DEBUG is not set/i\# CONFIG_CMA_SIZE_SEL_MIN is not set" .config
  sed -i "/# CONFIG_DMA_API_DEBUG is not set/i\# CONFIG_CMA_SIZE_SEL_MAX is not set" .config
  sed -i "/# CONFIG_DMA_API_DEBUG is not set/i\CONFIG_CMA_ALIGNMENT=8" .config

  # 鼠标的配置 ( 否则 xfce4 界面上鼠标不能操作 /dev/input/mice, 上层需要 xf86-input-evdev, libevdev )
  sed -i "/# CONFIG_INPUT_MOUSEDEV is not set/a\CONFIG_INPUT_MOUSEDEV_SCREEN_Y=768" .config
  sed -i "/# CONFIG_INPUT_MOUSEDEV is not set/a\CONFIG_INPUT_MOUSEDEV_SCREEN_X=1024" .config
  sed -i "/# CONFIG_INPUT_MOUSEDEV is not set/a\CONFIG_INPUT_MOUSEDEV_PSAUX=y" .config
  sed -i "s/# CONFIG_INPUT_MOUSEDEV is not set/CONFIG_INPUT_MOUSEDEV=y/" .config

  # 网络需要 TUN/TAP 驱动 [ Device Drivers ] ---> [ Network device support ] ---> [ Universal TUN/TAP device driver support ]
  make bzImage -j8
  make modules -j8
  #cd linux-5.8.6 && make x86_64_defconfig && make bzImage -j8 && make modules && make modules_install && cd ..
  make INSTALL_HDR_PATH=${linux_install} headers_install -j8
  make modules_install INSTALL_MOD_PATH=${linux_install} -j8 && cp arch/x86_64/boot/bzImage ${linux_install} && cd ..
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
  make -j8 && make install -j8 DESTDIR=${glibc_install}
  cd .. && cd ..
fi

# 编译 busybox 
if [ ! -d "busybox_install" ]; then
  mkdir -pv busybox_install && cd ${BUSYBOX_SRC_DIR} && make distclean && make defconfig
  # 屏蔽掉 lspci 这个自带的太简单
  sed -i "s/CONFIG_LSPCI=y/# CONFIG_LSPCI is not set/" .config
  # 静态编译 sed -i "s/# CONFIG_STATIC is not set/CONFIG_STATIC=y/g" .config
  sed -i "s|.*CONFIG_SYSROOT.*|CONFIG_SYSROOT=\"${glibc_install}\"|" .config
  sed -i "s|.*CONFIG_EXTRA_CFLAGS.*|CONFIG_EXTRA_CFLAGS=\"-I${linux_install}/include -I${glibc_install}/include -L${glibc_install}/usr/lib64 $CFLAGS\"|" .config
  # 环境变量 PATH 的设定，因为 busybox 的 init 会覆盖用户设置的 PATH，只能源码进行编译
  sed -i "s|#define BB_ADDITIONAL_PATH \"\"|#define BB_ADDITIONAL_PATH \":/usr/local/sbin:/usr/local/bin\"|" include/libbb.h
  make busybox -j8 && make CONFIG_PREFIX=${busybox_install} install
  cd ..
fi

# 编译 lshw ( 调试方便 )
if [ ! -d "lshw_install" ]; then
  mkdir -pv lshw_install && cd ${LSHW_SRC_DIR}
  CFLAGS="-L${glibc_install}/lib64 $CFLAGS" make -j8 && make install -j8 DESTDIR=${lshw_install} PREFIX=/usr
  cd ..
fi

# 编译 pciutils ( busybox 的 lspci 太简单 )
if [ ! -d "pciutils_install" ]; then
  mkdir -pv pciutils_install && cd ${PCIUTILS_SRC_DIR}
  CFLAGS="-L${glibc_install}/lib64 $CFLAGS" make -j8 && make install -j8 DESTDIR=${pciutils_install} PREFIX=/usr
  cd ..
fi

# 编译 openssl
if [ ! -d "openssl_install" ]; then
  mkdir -pv openssl_install && cd ${OPENSSL_SRC_DIR}
  ./config --prefix=/usr shared
  CFLAGS="-L${glibc_install}/lib64 $CFLAGS" make -j8 && make install -j8 DESTDIR=${openssl_install} PREFIX=/usr
  cd ..
fi

# 编译 openssh
if [ ! -d "openssh_install" ]; then
  mkdir -pv openssh_install && cd ${OPENSSH_SRC_DIR}
  ./configure --prefix=/usr --sysconfdir=/etc/ssh --with-ssl-dir=${openssl_install}/usr/ --without-openssl-header-check
  CFLAGS="-L${glibc_install}/lib64 -L${openssl_install}/usr/lib $CFLAGS" make -j8 && make install -j8 DESTDIR=${openssh_install} PREFIX=/usr
  # 修改配置文件
  sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/" ${openssh_install}/etc/ssh/sshd_config
  echo "HostKeyAlgorithms=ssh-rsa,ssh-dss" >> ${openssh_install}/etc/ssh/sshd_config
  echo "KexAlgorithms=diffie-hellman-group-exchange-sha1,diffie-hellman-group14-sha1,diffie-hellman-group1-sha1" >> ${openssh_install}/etc/ssh/sshd_config
  # 准备环境
  if [ ! -d "${openssh_install}/var/empty" ]; then
    mkdir -pv ${openssh_install}/var/empty
  fi
  chmod 744 ${openssh_install}/var/empty/
  chown root ${openssh_install}/var/empty/
  if [ ! -f "${openssh_install}/etc/ssh/ssh_host_dsa_key" ]; then
    ssh-keygen -t dsa -P "" -f ${openssh_install}/etc/ssh/ssh_host_dsa_key
  fi
  if [ ! -f "${openssh_install}/etc/ssh/ssh_host_rsa_key" ]; then
    ssh-keygen -t rsa -P "" -f ${openssh_install}/etc/ssh/ssh_host_rsa_key
  fi
  # 开启 sftp, 可以进行文件上传
  if [ -f "${openssh_install}/etc/ssh/sshd_config" ]; then
    sed -i "s/\/usr\/libexec\/sftp-server/internal-sftp/" ${openssh_install}/etc/ssh/sshd_config
  fi
  cd ..
fi

# 编译 gcc
if [ ! -d "gcc_install" ]; then 
  mkdir -pv gcc_install && cd ${GCC_SRC_DIR}
  if [ -f "config.cache" ]; then
    rm ./config.cache
  fi
  ./contrib/download_prerequisites
  ./configure --prefix=/usr --enable-languages=c,c++ --disable-multilib --disable-static --disable-libquadmath --enable-shared
  CFLAGS="-L${glibc_install}/lib64 $CFLAGS" make -j8 && make install -j8 DESTDIR=${gcc_install} && cd ..
fi

# 编译 binutils
if [ ! -d "binutils_install" ]; then
  mkdir -pv binutils_install && cd ${BINUTILS_SRC_DIR} && make distclean
  ./configure --prefix=/usr
  CFLAGS="-L${glibc_install}/lib64 $CFLAGS" make -j8 && make install -j8 DESTDIR=${binutils_install}
  cd ..
fi

cd ..

# 编译 xfce [ no same time with xorg ]
if [ "${with_xfce}" = true ]; then
  ./mk_xfce.sh img
fi

echo "Run the next script: 02_build_img.sh"
