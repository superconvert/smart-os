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
  create_disk disk.img 128
else
  create_disk disk.img 256
fi
echo "${GREEN}+++ build disk ok +++${NC}"

# 磁盘镜像挂载到具体设备
loop_dev=$(losetup -f)
# fdisk -l disk.img 查看 start 为 2048, unit 512 所以 -o 偏移扇区 1048576 = 2048 x 512
losetup -o 1048576 ${loop_dev} disk.img
# 对磁盘进行格式化
mkfs.ext3 ${loop_dev} 

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
  echo "${RED} with-gcc tools --- you can build your world${NC}"
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
echo /sbin/mdev > /proc/sys/kernel/hotplug
echo -e "\n\e[0;32mBoot took $(cut -d' ' -f1 /proc/uptime) seconds\e[0m"
mkdir -p /dev/pts
mount -t devpts devpts /dev/pts
# 切换之前，修改 mount 路径
mount --move /dev /mnt/dev
mount --move /sys /mnt/sys
mount --move /proc /mnt/proc
mount --move /tmp /mnt/tmp
# 切换到真正的磁盘系统上 rootfs ---> diskfs
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

# 指定了利用 /etc/init.d/rcS 启动
cat<<"EOF">etc/inittab
::restart:/sbin/init
::ctrlaltdel:/sbin/reboot
::shutdown:/bin/umount -a -r
::shutdown:/sbin/swapoff -a
::sysinit:echo "sysinit 1++++++++++++++++++++++++++++++++++++++"
::sysinit:/etc/init.d/rcS
::sysinit:echo "sysinit 2++++++++++++++++++++++++++++++++++++++"
tty1::once:echo "hello smart-os tty1"
tty1::respawn:/bin/sh
tty2::once:echo "hello smart-os tty2"
tty2::respawn:/bin/sh
tty3::once:echo "hello smart-os tty3"
tty3::respawn:/bin/sh
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
# 带有 gcc 编译器
if [ "${with_gcc}" = true ]; then
  echo "${RED} with-gcc tools --- you can build your world${NC}"
  cp ${gcc_install}/* ${diskfs} -r
  cp ${binutils_install}/usr/x86_64-pc-linux-gnu/* ${diskfs} -r
fi
rm -rf ${diskfs}/init ${diskfs}/lost+found

# 带有 xfce 编译器
if [ "${with_xfce}" = true ]; then
  echo "${RED}build xfce desktop${NC}"
  cp ${xfce_install}/* ${diskfs} -r -n
fi

# 测试用户登陆模式: root/123456
if [ "${with_login}" = true ]; then
  echo "${RED} with-login --- it's an exciting time ${NC}"
  ./mk_login.sh ${diskfs}
fi

# 我们测试驱动, 制作的镜像启动后，我们进入此目录 insmod hello_world.ko 即可 
./mk_drv.sh $(pwd)/${diskfs}/lib/modules 
# 编译网卡驱动 ( 目前版本内核已集成 e1000 )
# cd ${build_dir}/linux-4.14.9 && make M=drivers/net/ethernet/intel/e1000/ && cd ../..

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
ifconfig eth0 192.168.100.6 && ifconfig eth0 up
route add default gw 192.168.100.1

# exec 执行 /etc/init.d/rc.local 脚本
EOF
chmod +x  ${diskfs}/etc/init.d/rcS


# 登陆 login shell ，非 non-login shell
if [ "${with_login}" = true ]; then
cat - > ${diskfs}/etc/profile << EOF
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export LD_LIBRARY_PATH=/usr/lib:/usr/lib64:/usr/local/lib:/usr/lib/x86_64-linux-gnu
EOF
else
cat - > ${diskfs}/etc/bash.bashrc << EOF
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export LD_LIBRARY_PATH=/usr/lib:/usr/lib64:/usr/local/lib:/usr/lib/x86_64-linux-gnu
EOF
fi

echo "${GREEN}+++ build diskfs ok +++${NC}"

# 卸载映射
umount ${loop_dev} 
losetup -d ${loop_dev}

#---------------------------------------------------------------
#
# 查看磁盘内容
#
#---------------------------------------------------------------
./ls_img.sh

echo "Run the next script: 03_run_qemu.sh or 04_run_docker.sh"
