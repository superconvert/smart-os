# smart-os 一个小巧的 linux 系统
本项目给大家演示了怎么样快速制作一个小巧切功能齐全的 linux 操作系统, 项目地址 https://github.com/superconvert/smart-os

# 功能与特点
1. 支持挂载多块硬盘
2. 支持网络功能
3. 支持 DNS 域名解析
4. 支持 GCC 编译器
5. 支持 qemu 启动
6. 支持 docker 启动
7. 最精简模式 64 M
8. 支持驱动相关演示
9. 支持 smart_rtmpd 流媒体服务器运行 https://github.com/superconvert/smart_rtmpd

# 用途与场景
1. 操作系统原理教学
2. 云主机系统
3. 流媒体服务器定制
4. 嵌入式设备定制
5. IoT场景操作系统定制

# TODO 列表
1. 增加 arm 版本
2. 增加图形界面演示  
3. 支持 ISO 制作
4. 防火墙

# 制作流程
本脚本 Ubuntu 18.04 上做的，别的系统应该改动不大，有需要的朋友可以自行修改。

1. 准备系统环境  
由于内核需要编译，需要安装内核编译所需要的环境
由于 busybox 需要编译，根据需要自行安装所需环境  
    ```shell
    ./00_build_env.sh
    ```

2. 编译源码 ( kernel, glibc, busyboxy, gcc, binutils)     
    ```shell
    ./01_build_src.sh
    ```
3. 制作系统盘 （ 重要，此步骤把系统安装到一个系统文件内 )  
    ```shell
    ./02_build_img.sh
    ```
4. 运行 smart-os 系统  
    ```shell
    ./03_run_qemu.sh 或 ./04_run_docker.sh
    ```
是不是制作一个操作系统很简单！
磁盘空间可以任意扩展，可以上网，可以根据需要扩展自己想要的组件，我已经试验成功，在 smart-os 内运行流媒体服务器 smart_rtmpd 了

# 网络拓扑图
```shell
+----------------------------------------------------------------+-----------------------------------------+-----------------------------------------+  
|                          Host                                  |              Container 1                |              Container 2                |  
|                                                                |                                         |                                         |  
|       +------------------------------------------------+       |       +-------------------------+       |       +-------------------------+       |  
|       |             Newwork Protocol Stack             |       |       |  Newwork Protocol Stack |       |       |  Newwork Protocol Stack |       |  
|       +------------------------------------------------+       |       +-------------------------+       |       +-------------------------+       |  
|               +                    +                           |                   +                     |                    +                    |
|...............|....................|...........................|...................|.....................|....................|....................|
|               +                    +                           |                   +                     |                    +                    |
|        +-------------+    +---------------+                    |           +---------------+             |            +---------------+            |
|        | 192.168.0.3 |    | 192.168.100.1 |                    |           | 192.168.100.6 |             |            | 192.168.100.8 |            |
|        +-------------+    +---------------+     +-------+      |           +---------------+             |            +---------------+            |
|        |     eth0    |    |      br0      |<--->|  tap0 |      |           |      eth0     |             |            |      eth0     |            |
|        +-------------+    +---------------+     +-------+      |           +---------------+             |            +---------------+            |
|               +                   +                 +          |                   +                     |                    +                    |
|               |                   |                 |          |                   |                     |                    |                    |
|               |                   +                 +------------------------------+                     |                    |                    |
|               |               +-------+                        |                                         |                    |                    |
|               |               |  tap1 |                        |                                         |                    |                    |
|               |               +-------+                        |                                         |                    |                    |
|               |                   +                            |                                         |                    |                    |
|               |                   |                            |                                         |                    |                    |
|               |                   +-------------------------------------------------------------------------------------------+                    |
|               |                                                |                                         |                                         |
|               |                                                |                                         |                                         |
+---------------|------------------------------------------------+-----------------------------------------+-----------------------------------------+
                +
     Physical Network  (192.168.0.0/24)
```

# 注意事项
1. 由于smart-os安装了 glibc 动态库，这个严重依赖动态库加载器/链接器 ld-linux-x86-64.so.2 ，由于应用程序都是通过动态编译链接的，当一个需要动态链接的应用被操作系统加载时，系统必须要定位然后加载它所需要的所有动态库文件。这项工作是由 ld-linux.so.2 来负责完成的，当程序加载时，操作系统会将控制权交给 ld-linux.so 而不是交给程序正常的入口地址。 ld-linux.so.2 会寻找然后加载所有需要的库文件，然后再将控制权交给应用的起始入口。ld-linux-x86-64.so.2 其实就是 ld-linux.so.2 的软链，它必须存在于 /lib64/ld-linux-x86-64.so.2 下，否则，我们动态编译的 busybox 依赖 glibc 库，glibc 库的加载需要 ld-linux-x86-64.so，如果/lib64目录下不存在它，就会导致<font color=red>系统启动时会直接 panic</font>，这个问题需要特别注意！！！

2. qemu 一般启动后窗口比较小，一旦出现错误，基本上没办法看错误日志，那么就需要在 grub 的启动项内增加 console=ttyS0，同时 qemu-system-x86_64 增加串口输出到文件 -serial file:./qemu.log，这样调试就方便多了，调试完毕需要去掉 console=ttyS0 否则，/etc/init.d/rcS 里面的内容可能输出不显示

3. 我们编译的 glibc ，通常情况下版本都会高于系统自带的版本，我们可以编写测试程序 main.c 用来测试 glibc 是否编译成功。比如：  
    ```cpp
    #include <stdio.h>
    int main() {
        printf("Hello glibc\n");
        return 0 ;
    }
    ```
    我们进行编译  
    ```shell
    gcc -o test main.c -Wl,-rpath=/root/smart-os/work/glibc_install/usr/lib64  
    ```
    编译成功，我们执行 ./test 程序，通常会报类似于这样的错误 /lib64/libc.so.6: version `GLIBC_2.28' not found 或者程序直接 segment 了  
    其实这是没有指定动态库加载器/链接器和系统环境的原因，通常我们编译 glibc 库的时候，编译目录会自动生成一个 testrun.sh 脚本文件，我们在编译目录内执行程序  
    ```shell
    ./testrun.sh ./test  
    ```
    通常这样就可以成功执行。我们也可以把下面一句话保存到一个脚本中，执行测试也是可以的。  
    ```shell
    exec env /root/smart-os/work/glibc_install/lib64/ld-linux-x86-64.so.2 --library-path /root/smart-os/work/glibc_install/lib64 ./test
    ```

4. 我们怎么跟踪一个可执行程序的加载那些库，利用 LD_DEBUG=libs ./test  就可以了, 我们预加载库可以利用 LD_PRELOAD 强制预加载库

5. 我们编译 cairo 通常情况下会遇到很多问题，如果 cairo 编译出现问题，怎么办，有些错误信息网上很难搜到   
一定看它编译时生成的 config.log 文件，错误信息很详细！可以根据提示信息去解决问题

# libxcb 的编译，具体详情参见 mk_xorg.sh
1. 需要安装 apt install -y python-xcbgen 这个库，这个库会根据 xcbproto 提供的 xml 文件生成对应的 h 文件和 c 文件
2. 增加变量 export PKG_CONFIG_SYSROOT_DIR="${xclient_dir}"， 否则，编译过程中找 xml 文件的路径不对
3. 增加变量 export PKG_CONFIG_PATH="${xclient_dir}/usr/share/pkgconfig:${xclient_dir}/usr/lib/pkgconfig:${xclient_dir}/usr/local/lib/pkgconfig"，
   否则，pkg-config --variable=xcbincludedir xcb-proto 就不能正常工作
4. 增加变量 export XCBPROTO_XCBINCLUDEDIR="${xclient_dir}/usr/share/xcb" 这是正确的 xml 文件所在的路径
5. 增加变量 export PYTHONPATH="${xclient_dir}/usr/lib/python2.7/dist-packages"，配置 xcbgen 模块路径
6. 编辑 libxcb 的文件 src/c_client.py ，解决 UnicodeEncodeError 的问题 ordinal not in range(128)，Python 默认字符集是 ascii 码
   sed -i "8 i reload(sys)" src/c_client.py
   sed -i "9 i sys.setdefaultencoding('utf8')" src/c_client.py
   
# xfce 的编译
1. xfce 的编译相当于对 xfce 做一个整体的 cross compile，工作量相当庞大，有各个组件之间有顺序关系，有依赖关系
2. 会依赖很多开发包，系统工具，开发包理论上全需要源码编译，工作量巨大，开发包和系统工具有版本要求
3. 环境变量要求，比如找不到头文件，找不工具路径，undefined reference to XXX 这些都需要更改环境变量和编译参数进行不同的尝试
4. 编译过程中，引用的库存在多版本的问题，这个一定要理清楚用哪个版本，编译时，把 search path 的优先次序要理清
5. 有很多新工具需要熟悉，比如：meson, g-ir-scanner, g-ir-compile 等，这些是工具，不是开发包，刚接触不了解，结果编译 gobject-introspection 搞了很长时间

# 拓展知识

* ramfs :   
   ramfs是一种非常简单的文件系统，它直接利用linux内核已有的高速缓存机制(所以其实现代码很小, 也由于这个原因, ramfs特性不能通过内核配置参数屏蔽，
   它是内核的天然属性), 使用系统的物理内存，做成一个大小可以动态变化的的基于内存的文件系统, 系统不会回收, 只有 root 用户使用它

* tmpfs :   
   tmpfs是ramfs的衍生物，在ramfs的基础上增加了容量大小的限制和允许向交换空间(swap) 写入数据。由于增加了这两个特性，所以普通用户也可以使用tmpfs。
   tmpfs 占用的是虚拟内存，不全是 RAM ，性能可能没 ramfs 高

* ramdisk :   
   ramdisk是一种将内存中的的一块区域作为物理磁盘来使用的一种技术，也可以说，ramdisk是在一块内存区 域中创建的块设备，用于存放文件系统。对于用
   户来说，可以把ramdisk与通常的硬盘分区同等对待来使用。系统读写它还会在内存中存储一份对应的缓存，污染 CPU 缓存，性能也差，需要对应驱动支持

* rootfs :  
   rootfs是一个特定的ramfs(或tmpfs，如果tmpfs被启用)的实例，它始终存在于linux2.6的系统中。rootfs不能被卸载(与其添加特殊代码用来维护空的链表，
   不如把rootfs节点始终加入，因此便于kernel维护。rootfs是ramfs的一个空实例，占用空间极小)。大部分其他的文件系统安装于rootfs之上，然后忽略它。
   它是内核启动初始化根文件系统。

 * rootfs又分为虚拟rootfs和真实rootfs。  
 虚拟rootfs由内核自己创建和加载，仅仅存在于内存之中（后续的InitRamfs也是在这种基础上实现），其文件系统是tmpfs类型或者ramfs类型。  
 真实rootfs则是指根文件系统存在于存储设备上，内核在启动过程中会在虚拟rootfs上挂载这个存储设备，然后将/目录节点切换到这个存储设备上，这样存储
 设备上的文件系统就会被作为根文件系统使用（后续InitRamdisk是在这种基础上实现），其文件系统类型更加丰富，可以是ext2、yaffs、yaffs2等等类型，
 由具体的存储设备的类型决定。

 * 我们的启动文件系统其实就是为 rootfs 准备文件，让内核按照我们的意愿执行  
 在早期的linux系统中，一般只有硬盘或者软盘被用来作为linux根文件系统的存储设备，因此也就很容易把这些设备的驱动程序集成到内核中。但是现在的嵌入式
 系统中可能将根文件系统保存到各种存储设备上，包括scsi、sata，u-disk等等。因此把这些设备的驱动代码全部编译到内核中显然就不是很方便。
 在内核模块自动加载机制udev中，我们看到利用udevd可以实现内核模块的自动加载，因此我们希望如果存储根文件系统的存储设备的驱动程序也能够实现自动加载，
 那就好了。但是这里有一个矛盾，udevd是一个可执行文件，在根文件系统被挂载前，是不可能执行udevd的，但是如果udevd没有启动，那就无法自动加载存储根文件
 系统设备的驱动程序，同时也无法在/dev目录下建立相应的设备节点。
 为了解决这一矛盾，于是出现了基于ramdisk的initrd( bootloader initialized RAM disk )。Initrd是一个被压缩过的小型根目录，这个目录中包含了启动阶段中
 必须的驱动模块，可执行文件和启动脚本，也包括上面提到的udevd（实现udev机制的demon）。当系统启动的时候，bootloader会把initrd文件读到内存中，然后把
 initrd文件在内存中的起始地址和大小传递给内核。内核在启动初始化过程中会解压缩initrd文件，然后将解压后的initrd挂载为根目录，然后执行根目录中的 /init
 脚本（cpio格式的initrd为/init,而image格式的initrd<也称老式块设备的initrd或传统的文件镜像格式的initrd>为/initrc），您就可以在这个脚本中运行initrd
 文件系统中的udevd，让它来自动加载realfs（真实文件系统）存放设备的驱动程序以及在/dev目录下建立必要的设备节点。在udevd自动加载磁盘驱动程序之后，就
 可以mount真正的根目录，并切换到这个根目录中来。
