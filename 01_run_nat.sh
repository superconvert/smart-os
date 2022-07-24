#!/bin/sh

#---------------------
# 停掉 NAT 
#---------------------
stop() {
  # 停掉 tap0
  ip link set tap0 down 
  # 断开与网桥链接
  brctl delif br0 tap0
  # 停掉网桥
  ip link set br0 down
  # 删除设备 tap0
  ip tuntap del mode tap tap0
  # 删除网桥
  brctl delbr br0
}

#---------------------
# 启动 NAT
#---------------------
start() {
  # 创建虚拟网桥
  brctl addbr br0
  # 创建虚拟tap设备
  ip tuntap add dev tap0 mode tap
  # 将tap设备介入网桥
  brctl addif br0 tap0
  # 配置网桥ip
  ip addr add 192.168.100.1/24 dev br0
  ip addr add 192.168.100.2/24 dev tap0 
  # 启动桥设备和虚拟网卡设备
  ip link set br0 up 
  ip link set tap0 up
  # 配置iptables forward转发规则
  # 在基本环境搭建这一节中，设置了一个本地网络，虚机只能访问host，无法访问外网，如果需要访问外网需要设置SNAT
  iptables -t nat -A POSTROUTING -s 192.168.100.0/24 ! -d 192.168.100.0/24 -j MASQUERADE
  # 开启物理网卡的转发功能:
  sysctl -w net.ipv4.ip_forward=1
  # 如果有防火墙的，特别是centos系统中，记得放开防火墙
  iptables -A FORWARD -s 192.168.100.0/24 -j ACCEPT
}

#----------------------
# DNS 服务
#----------------------
start_dns() {

# 准备dnsmasq配置文件,启动dnsmasq服务，这样就能为虚拟机自动分配IP了
cat<<EOF>dnsmasq.conf
strict-order
pid-file=/var/run/dnsmasq.pid
except-interface=lo
bind-interfaces
listen-address=192.168.0.1
dhcp-range=192.168.100.2,192.168.100.254
dhcp-no-override
dhcp-leasefile=/var/lib/libvirt/dnsmasq/default.leases
dhcp-lease-max=253
dhcp-hostsfile=/var/lib/libvirt/dnsmasq/default.hostsfile
addn-hosts=/var/lib/libvirt/dnsmasq/default.addnhosts
EOF
/usr/sbin/dnsmasq --conf-file=./dnsmasq.conf

}

stop_dns() {
  # 杀掉 dhcp 服务
  killall dnsmasq
}

#----------------------------------------------
# 运行 smart-os 前，先启动这个，这样就能上网了
#----------------------------------------------
if [ -n "$1" ];then
  stop
  echo "stop"
else
  start
  echo "start"
fi
