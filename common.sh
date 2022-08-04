# 处理器
core_num=`nproc`

# 是否开启 gcc
with_gcc=false

# 是否开启 xorg
with_xorg=true

# 是否挂载第二块硬盘
with_sdb=false

# 是否登陆模式
with_login=false

# 编译工程目录
build_dir=`pwd`"/build"

# 公共目录
linux_install=${build_dir}"/linux_install"
glibc_install=${build_dir}"/glibc_install"
busybox_install=${build_dir}"/busybox_install"
gcc_install=${build_dir}"/gcc_install"
binutils_install=${build_dir}"/binutils_install"
xorg_install=${build_dir}"/xorg_install"

# 从完整路径获取文件名
file_name() {
  filename=$(echo $1 | rev | awk -v FS='/' '{print $1}' | rev)
  echo ${filename}
}

# 获取去掉扩展名的文件名
file_dirname() {
  filename=$(file_name $1)
  filedir=`echo $filename | sed "s/$2//g"`
  echo $filedir
}


