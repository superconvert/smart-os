loop_dev=$(losetup -f)

# fdisk -l disk.img 查看 start 为 2048, unit 512 所以 -o 偏移扇区 1048576 = 2048 x 512
losetup -o 1048576 ${loop_dev} disk.img

# 挂载磁盘到本地目录
mkdir -p ./mnt1
mount -t ext3 ${loop_dev} ./mnt1
echo "/ ---------------------------------------"
ls ./mnt1/
du ./mnt1 -h
echo "boot ---------------------------------------"
ls ./mnt1/boot
echo "sbin ---------------------------------------"
ls ./mnt1/sbin
echo "etc ---------------------------------------"
ls ./mnt1/etc
echo "dev ---------------------------------------"
ls ./mnt1/dev
echo "lib ---------------------------------------"
ls ./mnt1/lib
echo "lib64 -------------------------------------"
ls ./mnt1/lib64
umount ./mnt1
rm -rf mnt1
losetup -d ${loop_dev}
