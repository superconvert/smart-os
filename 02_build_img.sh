#!/bin/sh

# 导入公共环境
. ./common.sh

#----------------------------------------------
#
# 进行目录瘦身
#
#----------------------------------------------
./mk_strip.sh

#----------------------------------------------
#
# 制作磁盘
#
#----------------------------------------------
echo "${CYAN}--- build disk --- ${NC}"
# 创建磁盘 128M 或 256M
if [ "${with_gcc}" = false ]; then
  create_disk disk.img 4096
else
  create_disk disk.img 4096
fi
echo "${GREEN}+++ build disk ok +++${NC}"

# 磁盘镜像挂载到具体设备
loop_dev=$(losetup -f)
# fdisk -l disk.img 查看 start 为 2048, unit 512 所以 -o 偏移扇区 1048576 = 2048 x 512
losetup -o 1048576 ${loop_dev} disk.img
# 对磁盘进行格式化
mkfs.ext3 ${loop_dev} 

# 如果制作的 disk.img 转换为 qemu-img convert disk.img -f raw -O vmdk out.vmdk, vmware 的磁盘类型一定设置为 SATA ，否则，启动失败
diskfs="diskfs"
# 挂载磁盘到本地目录
mkdir -pv ${diskfs} 
mount -t ext3 ${loop_dev} ${diskfs} 
# 安装grub 引导
grub-install --boot-directory=${diskfs}/boot/ --target=i386-pc --modules=part_msdos disk.img

#---------------------------------------------
#
# 制作内核和 rootfs
#
#---------------------------------------------
rm -rf rootfs
mkdir -pv rootfs
mkdir -pv rootfs/dev
mkdir -pv rootfs/etc
mkdir -pv rootfs/sys
mkdir -pv rootfs/mnt
mkdir -pv rootfs/tmp
mkdir -pv rootfs/lib
mkdir -pv rootfs/sbin
mkdir -pv rootfs/proc
mkdir -pv rootfs/root
mkdir -pv rootfs/lib64
mkdir -pv rootfs/lib/modules

# 拷贝内核镜像
cp ${linux_install}/bzImage ${diskfs}/boot/bzImage
cp ${linux_install}/lib ${diskfs}/ -r

# 拷贝 glibc 到 rootfs
cp ${glibc_install}/* rootfs/ -r
rm -rf rootfs/var/db 
rm -rf rootfs/share
rm -rf rootfs/usr/share
find rootfs/ -name "*.a" -exec rm -rf {} \;
# 编译的镜像带有 gcc 编译器
if [ "${with_gcc}" = false ]; then
  rm -rf rootfs/usr/include
else
  cp ${glibc_install}/usr/lib64/libc_nonshared.a rootfs/usr/lib64 
fi

#----------------------------------------------------------------------
# 这个解释器必须设置对，否则系统会启动时 crash, 导致启动失败 !!!!!!
# 这个现在 glibc 编译时，已经自动生成，先注释掉
#-----------------------------------------------------------------------
# ln -s /lib/ld-2.32.so rootfs/lib64/ld-linux-x86-64.so.2

# 拷贝 busybox 到 rootfs
cp ${busybox_install}/* rootfs/ -r

#-----------------------------------------------
#
# 制作启动文件系统 initramfs
#
#-----------------------------------------------
cd rootfs
echo "${CYAN}--- build initrd ---${NC}"

# 这种方法也可以 mkinitramfs -k -o ./${diskfs}/boot/initrd 4.14.9
# 利用 Busybox 采用脚本制作 init 脚本 https://blog.csdn.net/embeddedman/article/details/7721926

# 光驱挂载 : /dev/cdrom 是 /dev/sr0 的软连接，也就是说 /dev/sr0 才是实际意义上的光驱。所以没有软连接，
# 照样可以挂载光驱。使用命令"mount /dev/sr0 /mnt/cdrom"便可以实现挂载。

make_init() {

cat<<"EOF">init
#!/bin/sh
# 必须首先挂载，否则 mdev 不能正常工作
mount -t sysfs sysfs /sys
mount -t proc proc /proc
mount -t devtmpfs udev /dev
mount -t tmpfs tmpfs /tmp -o mode=1777
# 必须挂载一下，否则下面的 mount 不上
mdev -s
mount -t ext3 /dev/sda1 /mnt
# 关闭内核烦人的输出信息
echo 0 > /proc/sys/kernel/printk
# 热插拔处理都交给 mdev
# echo /sbin/mdev > /proc/sys/kernel/hotplug
echo -e "\n\e[0;32mBoot took $(cut -d' ' -f1 /proc/uptime) seconds\e[0m"
mkdir -p /dev/pts
mount -t devpts devpts /dev/pts
# 切换之前，修改 mount 路径
mount --move /dev /mnt/dev
mount --move /sys /mnt/sys
mount --move /proc /mnt/proc
mount --move /tmp /mnt/tmp
# 切换到真正的磁盘系统上 rootfs ---> diskfs
export LD_LIBRARY_PATH="/lib:/lib64:/usr/lib:/usr/lib64:/usr/local/lib:/usr/local/lib64:/usr/lib/x86_64-linux-gnu"
exec switch_root /mnt /sbin/init
EOF

# /sbin/init [switch_root 执行] ---> /etc/inittab [定义了启动顺序] ---> 
# /etc/init.d/rcS [系统 mount, 安装驱动，配置网络] --->
# /etc/init.d/rc.local [文件配置应用程序需要的环境变量] ---> /etc/profile [部分初始化]
chmod +x init

}
make_init

# 下面这些不用了，利用脚本里面的 busybox 的 mdev -s 自动挂载
# mknod -m 644 dev/tty0 c 4 1
# mknod -m 644 dev/tty c 5 0
# mknod -m 600 dev/console c 5 1
# mknod -m 644 dev/null c 1 3
# mknod -m 640 dev/sda1 b 8 1
# xfce 需要显卡设备
# mknod -m 664 dev/dri/card0 c 226 0

# 指定了利用 /etc/init.d/rcS 启动
cat<<"EOF">etc/inittab
::sysinit:echo "sysinit 1++++++++++++++++++++++++++++++++++++++"
::sysinit:/etc/init.d/rcS
::sysinit:echo "sysinit 2++++++++++++++++++++++++++++++++++++++"

# /bin/sh invocations on selected ttys
#
# Note below that we prefix the shell commands with a "-" to indicate to the
# shell that it is supposed to be a login shell.  Normally this is handled by
# login, but since we are bypassing login in this case, BusyBox lets you do
# this yourself...
#
# Start an "askfirst" shell on the console (whatever that may be) -f root 自动登录
::respawn:-/bin/login -f root
# Start an "askfirst" shell on /dev/tty2-4
tty2::respawn:-/bin/sh
tty3::respawn:-/bin/sh
tty4::respawn:-/bin/sh

# /sbin/getty invocations for selected ttys
tty4::respawn:/sbin/getty 38400 tty5
tty5::respawn:/sbin/getty 38400 tty6

# Example of how to put a getty on a serial line (for a terminal)
#::respawn:/sbin/getty -L ttyS0 9600 vt100
#::respawn:/sbin/getty -L ttyS1 9600 vt100
#
# Example how to put a getty on a modem line.
#::respawn:/sbin/getty 57600 ttyS2

# Stuff to do when restarting the init process
::restart:/sbin/init

# Stuff to do before rebooting
::ctrlaltdel:/sbin/reboot
::shutdown:/bin/umount -a -r
::shutdown:/sbin/swapoff -a
EOF

find . | cpio -R root:root -H newc -o | gzip -9 > ../${diskfs}/boot/initrd
echo "${GREEN}+++ build initrd ok +++${NC}"
cd ..

#--------------------------------------------------------------
#
# 生成磁盘文件系统(利用 busybox 结构，省的自己创建了)
#
#--------------------------------------------------------------
echo "${CYAN}--- build diskfs ---${NC}"
cp rootfs/* ${diskfs} -r

# 单独的 lshw
cp ${lshw_install}/* ${diskfs} -r

# 单独的 pciutils
cp ${pciutils_install}/* ${diskfs} -r
if [ -f "${diskfs}/usr/share/pci.ids.gz" ]; then
  mkdir -pv ${diskfs}/usr/local/share
  mv ${diskfs}/usr/share/pci.ids.gz ${diskfs}/usr/local/share/pci.ids.gz
fi

# 带有 openssl
cp ${openssl_install}/* ${diskfs} -r

# 带有 openssh
cp ${openssh_install}/* ${diskfs} -r

# 带有 gcc 编译器
if [ "${with_gcc}" = true ]; then
  echo "${RED} ... build with-gcc${NC}"
  cp ${gcc_install}/* ${diskfs} -r
  cp ${binutils_install}/usr/x86_64-pc-linux-gnu/* ${diskfs} -r
fi
rm -rf ${diskfs}/init ${diskfs}/lost+found

# 测试用户登陆模式: root/123456
if [ "${with_login}" = true ]; then
  echo "${RED} ... build with-login${NC}"
  ./mk_login.sh ${diskfs}
fi

# 带有 xfce 编译器
if [ "${with_xfce}" = true ]; then
  echo "${RED} ... build xfce desktop${NC}"
  # 构建 Xorg 的键盘数据
  rm ${xfce_install}/usr/local/share/X11/xkb -rf
  ln -s /usr/share/X11/xkb ${xfce_install}/usr/local/share/X11
  # 依赖版本 libpcre.so.3
  if [ -f "${xfce_install}/usr/local/lib/libpcre.so.1" ]; then
    cp ${xfce_install}/usr/local/lib/libpcre.so.1 ${xfce_install}/usr/local/lib/libpcre.so.3
  fi
  # 依赖版本 libedit2
  if [ -f "${xfce_install}/usr/local/lib/libedit.so.0" ]; then
    cp ${xfce_install}/usr/local/lib/libedit.so.0 ${xfce_install}/usr/local/lib/libedit.so.2
  fi
  # 依赖版本 libtinfo.so.5
  if [ -f "${xfce_install}/usr/lib/libtinfo.so.6" ]; then
    cp ${xfce_install}/usr/lib/libtinfo.so.6 ${xfce_install}/usr/lib/libtinfo.so.5
  fi
  # 依赖版本 libffi.so.6
  if [ -f "${xfce_install}/usr/local/lib/libffi.so.8" ]; then
    cp ${xfce_install}/usr/local/lib/libffi.so.8 ${xfce_install}/usr/local/lib/libffi.so.6
  fi
  # dbus 用户添加
  echo "video:x:44:" >> ${diskfs}/etc/group
  echo "messagebus:x:107:" >> ${diskfs}/etc/group
  echo "messagebus:x:103:107::/nonexistent:/usr/sbin/nologin" >> ${diskfs}/etc/passwd
  # dbus 启动脚本
  # dbus-daemon --system --address=systemd: --nofork --nopidfile --systemd-activation --syslog-only
  # dbus-daemon --session --address=systemd: --nofork --nopidfile --systemd-activation --syslog-only
  # dbus-daemon --config-file=/usr/share/defaults/at-spi2/accessibility.conf --nofork --print-address 3
  echo "if [ -f "/swapfile" ]; then" > ${diskfs}/xfce.sh
  echo "  dd if=/dev/zero of=/swapfile bs=1M count=2048" >> ${diskfs}/xfce.sh
  echo "  mkswap /swapfile" >> ${diskfs}/xfce.sh
  echo "fi" >> ${diskfs}/xfce.sh
  echo "swapon /swapfile" >> ${diskfs}/xfce.sh
  echo "dbus-daemon --system --nopidfile --systemd-activation" >> ${diskfs}/xfce.sh
  echo "xinit /usr/local/bin/xfce4-session -- /usr/local/bin/Xorg :10" >> ${diskfs}/xfce.sh
  chmod +x ${diskfs}/xfce.sh
  # 添加 machine-id
  mkdir -p ${diskfs}/usr/local/var/lib/dbus
  echo "2add25d2f5994832ba171755bc21f9fe" > ${diskfs}/etc/machine-id
  echo "2add25d2f5994832ba171755bc21f9fe" > ${diskfs}/usr/local/var/lib/dbus/machine-id
  # 这些本来需要编译完成，目前暂且拷贝
  cp /usr/lib/x86_64-linux-gnu/libLLVM-10.so.1 build/xfce_install/usr/lib/x86_64-linux-gnu/
  # cp /usr/lib/x86_64-linux-gnu/libffi.so.6 build/xfce_install/usr/lib/x86_64-linux-gnu/
  # 拷贝 xfce4 到镜像目录
  cp ${xfce_install}/* ${diskfs} -r -n
  # xfce 需要系统内执行下面两句，保证键盘数据存在 Xorg :10 才能执行成功
  # 1. 键盘数据
  # rm /usr/local/share/X11/xkb -rf
  # ln -s /usr/share/X11/xkb /usr/local/share/X11
  # 2. 需要改动 libpcre.so.1 ---> libpcre.so.3
  # 3. xfce4-session 需要 libuuid.so

  # 依赖版本 libpcre.so.3
  if [ -f "${xfce_install}/usr/local/lib/libpcre.so.1" ]; then
    rm ${xfce_install}/usr/local/lib/libpcre.so.3 -rf
  fi
  # 依赖版本 libedit2
  if [ -f "${xfce_install}/usr/local/lib/libedit.so.0" ]; then
    rm ${xfce_install}/usr/local/lib/libedit.so.2 -rf
  fi
  # 依赖版本 libtinfo.so.5
  if [ -f "${xfce_install}/usr/lib/libtinfo.so.6" ]; then
    rm ${xfce_install}/usr/lib/libtinfo.so.5 -rf
  fi
  # 依赖版本 libffi.so.6
  if [ -f "${xfce_install}/usr/local/lib/libffi.so.8" ]; then
    rm ${xfce_install}/usr/local/lib/libffi.so.6 -rf
  fi
fi

# 我们测试驱动, 制作的镜像启动后，我们进入此目录 insmod hello_world.ko 即可 
./mk_drv.sh $(pwd)/${diskfs}/lib/modules 
# 编译网卡驱动 ( 目前版本内核已集成 e1000 )
# cd ${build_dir}/linux-5.8.6 && make M=drivers/net/ethernet/intel/e1000/ && cd ../..

# 生成 grub.cfg 文件, 增加 console=ttyS0 就会让 qemu 输出日志到 qemu.log
cat - > ${diskfs}/boot/grub/grub.cfg << EOF
set timeout=3
menuentry "smart-os" {
    root=(hd0,msdos1)
    linux /boot/bzImage console=tty0
    initrd /boot/initrd
}
EOF

# 生成 /etc/resolv.conf 文件
cat -> ${diskfs}/etc/resolv.conf << EOF
nameserver 8.8.8.8
nameserver 114.114.114.114
EOF

cat -> ${diskfs}/etc/fstab << EOF
# <file system>        <dir>         <type>    <options>             <dump> <pass>
proc                   /proc         proc      defaults              0      0
tmpfs                  /tmp          tmpfs     defaults              0      0
sysfs                  /sys          sysfs     defaults              0      0
EOF

# 生成 /etc/init.d/rcS 文件
title=$(cat<<EOF
\e[0;36m
..######..##.....##....###....########..########..........#######...######.
.##....##.###...###...##.##...##.....##....##............##.....##.##....##
.##.......####.####..##...##..##.....##....##............##.....##.##......
..######..##.###.##.##.....##.########.....##....#######.##.....##..######.
.......##.##.....##.#########.##...##......##............##.....##.......##
.##....##.##.....##.##.....##.##....##.....##............##.....##.##....##
..######..##.....##.##.....##.##.....##....##.............#######...######.
\e[0m
EOF
)
mkdir -pv ${diskfs}/etc/init.d
cat - > ${diskfs}/etc/init.d/rcS << EOF
#!/bin/sh
echo -e "\n“${title}”\n"

# 测试驱动加载 
cd /lib/modules && insmod hello_world.ko

# dns 测试 busybox 必须动态编译 动态编译 glibc 已经集成 dns 功能
# qemu
# ifconfig eth0 192.168.100.6 && ifconfig eth0 up
# route add default gw 192.168.100.1
# vmware
ifconfig eth0 192.168.222.195 && ifconfig eth0 up
route add default gw 192.168.222.2

# exec 执行 /etc/init.d/rc.local 脚本
/usr/sbin/sshd

EOF
chmod +x  ${diskfs}/etc/init.d/rcS

# 登陆 login shell ，非 non-login shell
if [ "${with_login}" = true ]; then
  echo "export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" >> ${diskfs}/etc/profile
  echo "export LD_LIBRARY_PATH=/lib:/lib64:/usr/lib:/usr/lib64:/usr/local/lib:/usr/local/lib64:/usr/lib/x86_64-linux-gnu" >> ${diskfs}/etc/profile
else
  echo "export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" >> ${diskfs}/etc/bash.bashrc
  echo "export LD_LIBRARY_PATH=/lib:/lib64:/usr/lib:/usr/lib64:/usr/local/lib:/usr/local/lib64:/usr/lib/x86_64-linux-gnu" >> ${diskfs}/etc/bash.bashrc
fi

echo "${GREEN}+++ build diskfs ok +++${NC}"

# 卸载映射
umount ${loop_dev} 
losetup -d ${loop_dev}

#----------------------------------------------------------------
#
# 常用命令
#
#----------------------------------------------------------------
# 查看CPU信息：cat /proc/cpuinfo
# 查看板卡信息：cat /proc/pci
# 查看PCI信息：lspci (相比cat /proc/pci更直观)
# 查看内存信息：cat /proc/meminfo
# 查看USB设备：cat /proc/bus/usb/devices
# 查看键盘和鼠标:cat /proc/bus/input/devices
# 查看系统硬盘信息和使用情况：fdisk & disk - l & df
# 查看各设备的中断请求(IRQ):cat /proc/interrupts
# 查看系统体系结构：uname -a
# dmidecode查看硬件信息，包括bios、cpu、内存等信息
# dmesg | more 查看硬件信息
# modinfo命令可以单看指定的模块/驱动的信息
# linux为什么访问设备数据先要mount?  https://www.zhihu.com/question/524667726

#---------------------------------------------------------------
#
# 查看磁盘内容
#
#---------------------------------------------------------------
./ls_img.sh

#---------------------------------------------------------------
#
# 转换为 vmware 格式
#
#---------------------------------------------------------------
qemu-img convert disk.img -f raw -O vmdk disk.vmdk

echo "Run the next script: 03_run_qemu.sh or 04_run_docker.sh"
