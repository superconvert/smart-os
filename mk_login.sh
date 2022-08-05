#!/bin/sh

diskfs=$1

# 用户组文件
cat<<EOF>${diskfs}/etc/group
root:x:0:root
EOF

# 用户密码文件
cat<<EOF>${diskfs}/etc/passwd
root:x:0:0:root:/:/bin/sh
EOF

# 用户 shadow 文件
cat<<EOF>${diskfs}/etc/shadow
root:\$1\$abcdefgh\$KJHEbEnUJaxWv269o9nH60:1:0:99999:7:::
EOF

# 用户 hostname 文件
cat<<EOF>${diskfs}/etc/hostname
localhost
EOF

# 用户 profile 文件
cat<<EOF>${diskfs}/etc/profile
HOSTNAME=$(/bin/hostname -F /etc/hostname)
PS1="[\u@\h \w]\# "
export PS1 HOSTNAME
EOF

# 重新生成 inittab 文件
cat<<EOF>${diskfs}/etc/inittab
::sysinit:/bin/hostname -F /etc/hostname
::sysinit:/etc/init.d/rcS
tty0::respawn:-/bin/login
::restart:/sbin/init
::ctrlaltdel:/sbin/reboot
::shutdown:/bin/umount -a -r
::shutdown:/sbin/swapoff -a
EOF
