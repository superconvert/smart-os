#!/bin/sh

red='\e[0;41m' # 红色
RED='\e[1;31m'
green='\e[0;32m' # 绿色
GREEN='\e[1;32m'
yellow='\e[5;43m' # 黄色
YELLOW='\e[1;33m'
blue='\e[0;34m' # 蓝色
BLUE='\e[1;34m'
purple='\e[0;35m' # 紫色
PURPLE='\e[1;35m'
cyan='\e[4;36m' # 蓝绿色
CYAN='\e[1;36m'
WHITE='\e[1;37m' # 白色
NC='\e[0m' # 没有颜色

#----------------------------------------------
#
# 制作磁盘
#
#----------------------------------------------
# 创建磁盘 64M
dd if=/dev/zero of=disk.img bs=1M count=256
# 对磁盘进行分区一个主分区
fdisk disk.img << EOF
n
p



w
EOF
echo ".........................................................."

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
cp work/kernel_install/bzImage ${diskfs}/boot/bzImage

# 拷贝 glibc 到 rootfs
cp work/glibc_install/* rootfs/ -r
rm -rf rootfs/lib/*.a 
rm -rf rootfs/lib/gconv 
rm -rf rootfs/bin/*
rm -rf rootfs/share
rm -rf rootfs/var/db 
rm -rf rootfs/include
rm -rf rootfs/lib/ld-linux-x86-64.so.2
ln -s ../lib rootfs/usr/lib
ln -s ../lib/ld-2.32.so rootfs/lib64/ld-linux-x86-64.so.2

# 拷贝 busybox 到 rootfs
echo "${CYAN}开始制作rootfs...${NC}"
cp work/busybox_install/* rootfs/ -r

#-----------------------------------------------
#
# 制作启动文件系统 initramfs
#
#-----------------------------------------------
cd rootfs

# 这种方法也可以 mkinitramfs -k -o ./${diskfs}/boot/initrd 4.14.9
# 利用 Busybox 采用脚本制作 init 脚本 https://blog.csdn.net/embeddedman/article/details/7721926

make_init() {

cat<<"EOF">init
#!/bin/sh

# 必须首先挂载，否则 mdev 不能正常工作
mount -t sysfs none /sys
mount -t proc none /proc
mount -t devtmpfs none /dev
mount -t tmpfs none /tmp -o mode=1777
# 必须挂载一下，否则下面的 mount 不上
mdev -s
mount -t ext3 /dev/sda1 /mnt

# 关闭内核烦人的输出信息
echo 0 > /proc/sys/kernel/printk
echo -e "\n\e[0;32mBoot took $(cut -d' ' -f1 /proc/uptime) seconds\e[0m"

mkdir -p /dev/pts
mount -t devpts none /dev/pts

# 切换之前，修改 mount 路径
mount --move /dev /mnt/dev
mount --move /sys /mnt/sys
mount --move /proc /mnt/proc
mount --move /tmp /mnt/tmp

# 切换到真正的磁盘系统上 rootfs(initramfs) ---> diskfs
exec switch_root /mnt /sbin/init
EOF

# /sbin/init [switch_root 执行] ---> /etc/inittab [定义了启动顺序] ---> 
# /etc/init.d/rcS [系统 mount, 安装驱动，配置网络] --->
# /etc/init.d/rc.local [文件配置应用程序需要的环境变量] ---> 
# /etc/profile [部分初始化]
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
::sysinit:echo "sysinit 1++++++++++++++++++++++++++++++++++++++"
::sysinit:/etc/init.d/rcS
::sysinit:echo "sysinit 2++++++++++++++++++++++++++++++++++++++"
::restart:/sbin/init
::ctrlaltdel:/sbin/reboot
::shutdown:/bin/umount -a -r
tty1::once:echo "hello smart-os tty1"
tty1::respawn:/bin/sh
tty2::once:echo "hello smart-os tty2"
tty2::respawn:/bin/sh
tty3::once:echo "hello smart-os tty3"
tty3::respawn:/bin/sh
EOF

# dns 测试
# 0. 启动脚本 run_nat.sh
# 1. busybox 必须动态编译
# 2. ifconfig eth0 192.168.100.6 && ifconfig eth0 up
# 3. route add default gw 192.168.100.1
# 4. echo "nameserver 114.114.114.114" >> /etc/resolv.conf
# cp -rf ../fixed/lib* lib/ && cp ../fixed/ld-linux-x86-64.so.2 lib64/
strip -g bin/* sbin/* lib/* 

find . | cpio -R root:root -H newc -o | gzip -9 > ../${diskfs}/boot/initrd
echo "${GREEN}rootfs制作成功!!!${NC}"
echo ".........................................................."
cd ..

#--------------------------------------------------------------
#
# 生成磁盘文件系统(利用 busybox 结构，省的自己创建了)
#
#--------------------------------------------------------------
echo "${CYAN}开始制作diskfs...${NC}"
cp rootfs/* ${diskfs} -r
cp work/libgcc_install/* ${diskfs} -r
cp work/binutils_install/* ${diskfs} -r
rm -rf ${diskfs}/init && rm -rf ${diskfs}/linuxrc && rm -rf ${diskfs}/lost+found

# 我们测试驱动, 制作的镜像启动后，我们进入此目录 insmod hello_world.ko 即可 
./make_driver.sh $(pwd)/${diskfs}/lib/modules 
# 编译网卡驱动 ( 目前版本内核已集成 e1000 )
# cd work/linux-4.14.9 && make M=drivers/net/ethernet/intel/e1000/ && cd ../..

# 生成 grub.cfg 文件
cat - > ${diskfs}/boot/grub/grub.cfg << EOF
set timeout=6
menuentry "smart-os" {
    root=(hd0,msdos1)
    linux /boot/bzImage console=tty0
    initrd /boot/initrd
}
EOF

# 生成 rcS 文件
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

# dns 测试
ifconfig eth0 192.168.100.6 && ifconfig eth0 up
route add default gw 192.168.100.1
echo "nameserver 114.114.114.114" >> /etc/resolv.conf

# exec 执行 /etc/init.d/rc.local 脚本
EOF
chmod +x  ${diskfs}/etc/init.d/rcS

echo "${GREEN}diskfs制作成功!!!${NC}"
echo ".........................................................."

# 卸载映射
umount ${loop_dev} 
losetup -d ${loop_dev}
