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

# 处理器
core_num=`nproc`

# 是否开启 gcc
with_gcc=true

# 是否开启 xfce
with_xfce=true

# 是否挂载第二块硬盘
with_sdb=false

# 是否登陆模式
with_login=true

#----------------------------------------------
# 公共目录
#----------------------------------------------
build_dir=`pwd`"/build"
linux_install=${build_dir}"/linux_install"
glibc_install=${build_dir}"/glibc_install"
busybox_install=${build_dir}"/busybox_install"
pciutils_install=${build_dir}"/pciutils_install"
gcc_install=${build_dir}"/gcc_install"
binutils_install=${build_dir}"/binutils_install"
xorg_install=${build_dir}"/xorg_install"
xfce_install=${build_dir}"/xfce_install"

#----------------------------------------------
# 从完整路径获取文件名
#----------------------------------------------
file_name() {
  filename=$(echo $1 | rev | awk -v FS='/' '{print $1}' | rev)
  echo ${filename}
}

#----------------------------------------------
# 获取去掉扩展名的文件名
#----------------------------------------------
file_dirname() {
  filename=$(file_name $1)
  filedir=`echo $filename | sed "s/$2//g"`
  echo $filedir
}

#----------------------------------------------
# 下载一个指定 URL 的源码包, 并存为指定的名字
#----------------------------------------------
download_src() {
  SRC_NAME=$2$(file_name $1)
  if [ ! -f ${SRC_NAME} ]; then
    wget -c -t 0 $1 -O $SRC_NAME || (echo "download $1 failed" && exit)
  fi
  echo $SRC_NAME
}

#----------------------------------------------
# 解压一个下载的源码包到去掉扩展名的目录内
#----------------------------------------------
unzip_src() {
  SRC_NAME=$2
  SRC_DIR=${build_dir}"/"$(file_dirname ${SRC_NAME} $1)
  if [ ! -d ${SRC_DIR} ]; then
    tar xf source/${SRC_NAME} -C ${build_dir}
  fi
  echo $SRC_DIR
}

#----------------------------------------------
# 获取一个目录下所有的文件，包括子目录
#----------------------------------------------
ls_dir() {
  for file in `ls $1`
  do
    if [ -d $1"/"$file ]
    then
        ls_dir $1"/"$file $2
    else
	file=$1"/"$file
	echo ${file#$2} >> tmpfile.txt
    fi
  done
}

#---------------------------------------------
# 创建一个磁盘文件并分区
#---------------------------------------------
create_disk() {
# 输入参数磁盘文件和大小
disk=$1
size=$2
# 创建一个磁盘文件
dd if=/dev/zero of=${disk} bs=1M count=${size}

# 对磁盘进行分区一个主分区
fdisk ${disk} << EOF
n
p



w
EOF
}
