#!/bin/sh
# 启动镜像 网络对应 run_nat.sh 里面的配置
qemu-system-x86_64 -drive format=raw,file=disk.img -netdev tap,id=nd0,ifname=tap0 -device e1000,netdev=nd0 

#----------------------------------------------------
#
# 多硬盘测试 -hdb extra.img
#
#----------------------------------------------------
# make_sdb.sh
# qemu-system-x86_64 -drive format=raw,file=disk.img -hdb extra.img

