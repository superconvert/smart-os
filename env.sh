#!/bin/sh

rm work/kernel_install/ work/glibc_install/ work/busybox_install/ -rf
apt -y install gcc make gawk bison libelf-dev