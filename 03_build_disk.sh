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
dd if=/dev/zero of=disk.img bs=1M count=64
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

# 拷贝内核镜像
cp linux-4.14.9/arch/x86_64/boot/bzImage ../${diskfs}/boot/bzImage

# 编译 busybox 
if [ ! -d "./busybox-1.34.1/_install" ]; then
  # 静态编译 sed -i "s/# CONFIG_STATIC is not set/CONFIG_STATIC=y/g" .config
  cd busybox-1.34.1 && make defconfig && make -j8 && make install && cd ..
fi

# 拷贝 busybox 到 rootfs
echo "${CYAN}开始制作rootfs...${NC}"
cp busybox-1.34.1/_install/* ../rootfs/ -r
cd ..

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
cp -rf ../fixed/lib* lib/ && cp ../fixed/ld-linux-x86-64.so.2 lib64/

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

cat -> ${diskfs}/rtmpd.sh << EOF
wget http://www.qiyicc.com/download/rtmpd.zip
unzip rtmpd.zip
rm rtmpd.zip -rf
cd rtmpd 
mv smart_rtmp/smart_rtmpd.multithread.centos* ./
tar zxvf *.tar.gz 
rm *.tar.gz -rf
rm smart_rtmp -rf
EOF
chmod +x ${diskfs}/rtmpd.sh

echo "${GREEN}diskfs制作成功!!!${NC}"
echo ".........................................................."

# 卸载映射
umount ${loop_dev} 
losetup -d ${loop_dev}