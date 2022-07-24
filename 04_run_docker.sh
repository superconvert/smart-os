#!/bin/sh

dock_name=smart-os
loop_dev=$(losetup -f)

# fdisk -l disk.img 查看 start 为 2048, unit 512 所以 -o 偏移扇区 1048576 = 2048 x 512
losetup -o 1048576 ${loop_dev} disk.img

# 挂载磁盘到本地目录
mkdir -p ./tmp_docker
mount -t ext3 ${loop_dev} ./tmp_docker
cd ./tmp_docker
tar -cvpf ../${dock_name}.tar --directory=./ --exclude=proc --exclude=sys --exclude=dev --exclude=run --exclude=boot .
cd ..
umount ./tmp_docker
rm -rf ./tmp_docker 
losetup -d ${loop_dev}

# 删除镜像
clear() {
    if [ ! "`docker ps -a | grep ${dock_name}`" = "" ] ; then
        docker stop `docker ps -a | grep ${dock_name} | awk '{print $1}'`
        docker rm `docker ps -a | grep ${dock_name} | awk '{print $1}'`
    fi

    if [ ! "`docker images -a | grep ${dock_name}`" = "" ] ; then
        docker rmi `docker images -a | grep ${dock_name} | awk '{print $1}'`:1.0
    fi
}

# 导入镜像
run() {
    cat smart-os.tar | docker import - ${dock_name}:1.0
    docker run -t -i ${dock_name}:1.0 /bin/sh
}

clear
run
clear

# 删除镜像文件
if [ -f "${dock_name}.tar" ]; then
    rm -rf ${dock_name}.tar
fi
