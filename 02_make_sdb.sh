#!/bin/sh

#----------------------------------------------
#
# 制作磁盘
#
#----------------------------------------------

echo "${CYAN}开始制作磁盘...${NC}"

# 创建磁盘 64M
dd if=/dev/zero of=extra.img bs=1M count=64

# 对磁盘进行分区一个主分区
fdisk extra.img << EOF
n
p



w
EOF

echo "${GREEN}磁盘制作成功!!!${NC}"
echo ".........................................................."

# 磁盘镜像挂载到具体设备
loop_dev=$(losetup -f)

# fdisk -l disk.img 查看 start 为 2048, unit 512 所以 -o 偏移扇区 1048576 = 2048 x 512
losetup -o 1048576 ${loop_dev} extra.img

# 对磁盘进行格式化
mkfs.ext3 ${loop_dev}

losetup -d ${loop_dev}

