loop_dev=$(losetup -f)

# fdisk -l disk.img 查看 start 为 2048, unit 512 所以 -o 偏移扇区 1048576 = 2048 x 512
losetup -o 1048576 ${loop_dev} disk.img

# 挂载磁盘到本地目录
mkdir -p ./mnt1
mount -t ext3 ${loop_dev} ./mnt1
echo "/ ---------------------------------------"
du ./mnt1 -h
ls ./mnt1/etc
echo "lib -------------------------------------"
find ./mnt1 -name "*.a" -exec du -h {} \; 
umount ./mnt1
rm -rf mnt1
losetup -d ${loop_dev}
