#!/bin/sh

mkdir -pv driver && cd driver

cat<<EOF>hello_world.c
#include <linux/init.h>             
#include <linux/module.h>          
#include <linux/kernel.h>   

MODULE_LICENSE("GPL");              

static int __init hello_world_init(void)
{
    printk(KERN_DEBUG "hello world!!!\n");
    return 0;
}

static void __exit hello_world_exit(void)
{
    printk(KERN_DEBUG "goodbye world!!!\n");
}

module_init(hello_world_init);
module_exit(hello_world_exit);
EOF

cat<<EOF>Makefile
obj-m += hello_world.o
all:
	make -C ../build/linux-4.14.9 M=`pwd` modules
clean:
	make -C ../build/linux-4.14.9 M=`pwd` clean
EOF

echo $1
make && mv hello_world.ko $1 && make clean && cd .. && rm -rf driver
