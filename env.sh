#!/bin/sh
  
rm work/kernel_install/ work/glibc_install/ work/busybox_install/ -rf

if [ -f "/usr/bin/apt" ]; then
  apt -y install gcc g++ make gawk bison libelf-dev bridge-utils qemu-system docker.io
fi

if [ -f "/usr/bin/yum" ]; then
  yum -y install gcc gcc-c++ make gawk bison elfutils-libelf bridge-utils qemu-img qemu-kvm qemu-kvm-tools docker
fi
