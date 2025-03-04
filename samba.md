# samba 配置整体说明
samba 是基于 smb 协议实现的不同系统之间实现文件共享，打印资源共享的一套框架。smb 协议用来解决局域网内的文件或打印机等资源共享的问题，由微软公司和英特尔公司共同制定。  
目前主要的类 UNIX 系统平台都支持此协议，这样在大部分常用的系统中都满足文件共享及打印资源共享需求。  

samba 分为服务器端和客户端，本文档基于 UOS Server 20 1070a 作为 Samba 服务器做基准，win10, win11 作为客户端为基准，进行配置流程说明

# samba 服务器端
下面的章节主要是阐述服务器端一些准备工作，包括安装，环境配置，运行等基本工作

## 安装 samba
~~~shell
yum install -y samba
~~~

## 查询是否安装 samba  
~~~shell
[root@localhost ~]# rpm -qa | grep samba
samba-common-tools-4.17.5-2.0.1.uelc20.03.x86_64
samba-ldb-ldap-modules-4.17.5-2.0.1.uelc20.03.x86_64
samba-client-libs-4.17.5-2.0.1.uelc20.03.x86_64
samba-4.17.5-2.0.1.uelc20.03.x86_64
samba-libs-4.17.5-2.0.1.uelc20.03.x86_64
samba-dcerpc-4.17.5-2.0.1.uelc20.03.x86_64
samba-common-libs-4.17.5-2.0.1.uelc20.03.x86_64
samba-common-4.17.5-2.0.1.uelc20.03.noarch
~~~
如果出现上述包，则表明 samba 已经安装成功

## 开通防火墙放行
~~~shell
firewall-cmd --zone=public --add-port=139/tcp --permanent  
firewall-cmd --zone=public --add-port=445/tcp --permanent  
firewall-cmd --reload 或 systemctl restart firewalld  
~~~

## 开通 SELinux 放行或关闭 SELinux
~~~shell
setsebool -P samba_enable_home_dirs=1  
chcon -t samba_share_t /home/centos/share      ---> 放行的目录
~~~
经过验证系统默认不阻挡 samba 服务器对外提供服务，这一步可以省略!!!

## 运行 samba 服务
~~~shell
systemctl restart smb.service  
~~~
理想情况下都是启动成功，如果出现失败，会出现很多提示信息，根据信息进行排查，下面就一些错误进行简单的说明  

1. 配置文件格式错误  
samba 配置文件错误会导致 samba 启动失败，比如：yes 多了空格, set_variable_helper(yes ): value is not boolean

2. 查看启动失败原因
tail -f /var/log/samba/log.smbd

## 查看运行状态
~~~shell
[root@localhost ~]# systemctl status smb.service
● smb.service - Samba SMB Daemon
   Loaded: loaded (/usr/lib/systemd/system/smb.service; disabled; vendor preset: disabled)
   Active: active (running) since Tue 2025-02-25 04:00:58 CST; 5min ago
     Docs: man:smbd(8)
           man:samba(7)
           man:smb.conf(5)
 Main PID: 13499 (smbd)
   Status: "smbd: ready to serve connections..."
    Tasks: 3
   Memory: 4.1M
   CGroup: /system.slice/smb.service
           ├─13499 /usr/sbin/smbd --foreground --no-process-group
           ├─13501 /usr/sbin/smbd --foreground --no-process-group
           └─13502 /usr/sbin/smbd --foreground --no-process-group

2月 25 04:00:58 localhost.localdomain systemd[1]: Starting Samba SMB Daemon...
2月 25 04:00:58 localhost.localdomain smbd[13499]: [2025/02/25 04:00:58.114320,  0] ../../source3/smbd/server.c:1741(main)
2月 25 04:00:58 localhost.localdomain smbd[13499]:   smbd version 4.17.5 started.
2月 25 04:00:58 localhost.localdomain smbd[13499]:   Copyright Andrew Tridgell and the Samba Team 1992-2022
2月 25 04:00:58 localhost.localdomain smbd[13499]: [2025/02/25 04:00:58.115092,  0] ../../lib/param/loadparm.c:749(lpcfg_map_parameter)
2月 25 04:00:58 localhost.localdomain smbd[13499]:   Unknown parameter encountered: "browse"
2月 25 04:00:58 localhost.localdomain smbd[13499]: [2025/02/25 04:00:58.115138,  0] ../../lib/param/loadparm.c:1936(lpcfg_do_service_parameter)
2月 25 04:00:58 localhost.localdomain smbd[13499]:   Ignoring unknown parameter "browse"
2月 25 04:00:58 localhost.localdomain systemd[1]: Started Samba SMB Daemon.
~~~

我们发现状态 active (running) 表明 samba 服务器启动成功。

## 查看运行端口
~~~shell
[root@localhost ~]# netstat -anp | grep smbd
tcp        0      0 192.168.112.132:139     0.0.0.0:*               LISTEN      13499/smbd          
tcp        0      0 192.168.112.132:445     0.0.0.0:*               LISTEN      13499/smbd          
unix  2      [ ]         DGRAM                    336690   13499/smbd           /var/lib/samba/private/msg.sock/13499
unix  2      [ ]         DGRAM                    335554   13501/smbd           /var/lib/samba/private/msg.sock/13501
unix  2      [ ]         DGRAM                    334795   13502/smbd           /var/lib/samba/private/msg.sock/13502
unix  3      [ ]         STREAM     CONNECTED     335562   13499/smbd           
unix  2      [ ]         STREAM     CONNECTED     336695   13499/smbd           
unix  2      [ ]         DGRAM                    336673   13499/smbd    
~~~
我们看到端口 139 和 445 已经正确绑定

## 配置文件说明
配置文件就是 /etc/samba/smb.conf， 这里面的内容太多，大部分采用默认配置即可，没必要一一进行解释和使用。

# windows 客户端配置

## windows 配置 SMB 功能
windows 需要开启 SMB 1.0/CIFS 共享文件支持 ， 分别从系统设置里面进行配置，配置完成，需要重启机器  
win11 ---> 设置 ---> 应用 ---> 可选功能 ---> 更多 windows 功能 ---> SMB 1.0/CIFS 共享文件支持  
win10 ---> 设置 ---> 应用 ---> 程序和功能 ---> 启用或关闭 windows 功能 ---> SMB 1.0/CIFS 共享文件支持  

# 基本使用场景说明
下面就针对组，用户，配置文件，使用场景进行分别说明，由于是对账号和组的操作，所以必须在 root 账号下进行操作。

## 组管理
这里可以根据咱们的部门进行分组，比如：td(技术部), fd(财务部), md(市场部)，这样对应部门的用户可以加入到相应的组内  
1. 添加组 技术部
    ~~~shell
    groupadd td
    ~~~

2. 删除组 技术部
    ~~~shell
    groupdel td
    ~~~

3. 查看组成员
    ~~~shell
    cat /etc/group | grep 组名
    ~~~

这是属于 linux 的一些基本命令，不一一介绍了

4. 要查看 samba 用户所属的用户组
    ~~~shell
    pdbedit -Lv -u <samba用户名>
    ~~~


## 用户 管理
添加用户需要两步，第一步是添加系统用户，其次是添加 samba 用户
1. 添加用户
    1.1 添加系统用户（ 不能登录系统 )  
    ~~~shell
    useradd -s /sbin/nologin dev001
    ~~~

    1.2 添加 samba 用户，并配置密码
    ~~~shell
    smbpasswd -a dev001
    ~~~

2. 删除用户
    2.1 删除 samba 用户
    ~~~shell
    smbpasswd -x dev001
    ~~~

    2.2 删除系统用
    ~~~shell
    userdel dev001
    ~~~

3. 把用户添加到组
    把用户 dev001 添加到组 td 中
    ~~~shell
    usermod -a -G td dev001
    ~~~

4. 把用户从组中删除
    把用户 dev001 从组 td 中删除
    ~~~shell
    gpasswd -d dev001 td
    ~~~

## 配置文件说明
1. 配置文件路径
/etc/samba/smb.conf

2. 配置项说明
通常情况下，smb.conf 配置文件是不需要修改的，如果我们想共享一个目录，则需要追加类似下面格式的文字到 smb.conf，保存后，重新启动 samba 服务  
~~~shell
[company]								# 共享名  
	comment = company share				# 注释说明  
	path = /home/company				# 共享文件路径  
	guest ok = no					    # 不允许匿名访问  
	writeable = yes	                    # 允许用户写入数据  
	browseable = no                     # 当设置为 yes 时，表示该共享目录是可浏览的，其他计算机上的用户可以在网络浏览器中看到该共享目录，并能够浏览其中的文件和文件夹  
                                        # 当设置为no时，表示该共享目录是不可浏览的，其他计算机上的用户无法在网络浏览器中看到该共享目录，从而增加共享资源的隐私保护       ---> 虽然看不到，但输入路径还是能进入的  
	printable = no                      #   
	valid users=admin,xsuser            # 指定用户访问  
	write list=xzuser                   # 指定用户有写入权限  
	read list=user2  

	create mask = 755                   # 新建文件掩码
	directory mask = 755                # 新建目录掩码

	host allow = 192.168.0. EXCEPT 192.168.0.99     # 只允许192.168.0.0/24但不包括192.168.0.99的客户端访问Samba服务器上的smbtest目录。  
                 192.168.0.99 192.168.0.100         # 中间是空格  
	hosts deny ：拒绝访问      
~~~

# 配置示例
1. 场景描述
领导：王总（wangzong)
正式员工：张三(zhang3), 李四(li4)，于老大(yu1), 于老二(yu2)
实习生：楚乔乔(chuxx)，小马(xiaoma)

整个共享区域分为两部分，日常区，读写区，其中王总有整个盘的读写权限，子目录如下：  
1.1 日常区  
| 子目录 | 读写权限 | 查询权限 |
| --- | --- | --- |
| 重大事项 | wangzong | |
| 财务报表 | li4 | yu1, yu2 |
| 战略规划 | li4, yu1 | 正式员工 |
| 公司建议 | 正式员工 | |
| 共享资料 | 正式员工 | 实习生 |

1.2 读写区
| 子目录 | 读写权限 |
| --- | --- |
| 周报总结 | yu2 |
| 工作记录 | 正式员工 |
| 休闲娱乐 | 正式员工，实习生 |

2. 创建共享目录
~~~shell
[root@samba-server ~]# useradd samba
[root@samba-server ~]# mkdir -p /data/samba/daily
[root@samba-server ~]# mkdir -p /data/samba/read-write
[root@samba-server ~]# chown -R samba.samba /data/samba
~~~
共享根目录 /data/samba，里面有两个目录 daily 和 read-write，并把此目录所有者指定为 samba

3. 添加用户账号
~~~shell
[root@samba-server ~]# useradd -d /data/samba -s /sbin/nologin wangzong
[root@samba-server ~]# useradd -d /data/samba -s /sbin/nologin zhang3
[root@samba-server ~]# useradd -d /data/samba -s /sbin/nologin li4
[root@samba-server ~]# useradd -d /data/samba -s /sbin/nologin yu1
[root@samba-server ~]# useradd -d /data/samba -s /sbin/nologin yu2
[root@samba-server ~]# useradd -d /data/samba -s /sbin/nologin chuxx
[root@samba-server ~]# useradd -d /data/samba -s /sbin/nologin xiaoma
~~~

4. 创建对应的 samba 用户
~~~shell
[root@samba-server ~]# smbpasswd -a wangzong
new password:                      
retype new password:
.......
~~~
依次把用户添加进来，这里只举例了 wangzong 这个账号

5. 设置共享目录的权限
~~~shell
# 日常区配置
[root@samba-server samba]# cd daily

[root@samba-server daily]# mkdir 重大事项
[root@samba-server daily]# chown -R wangzong.wangzong /data/samba/daily/重大事项
[root@samba-server daily]# chmod -R 700 /data/samba/daily/重大事项
      
[root@samba-server daily]# mkdir 财务报表
[root@samba-server daily]# chown -R li4.li4 /data/samba/daily/财务报表
[root@samba-server daily]# chmod -R 700 /data/samba/daily/财务报表
[root@samba-server daily]# setfacl -R -m u:yu1:rx /data/samba/daily/财务报表
[root@samba-server daily]# setfacl -R -m u:yu2:rx /data/samba/daily/财务报表
      
[root@samba-server daily]# mkdir 战略规划
[root@samba-server daily]# chown -R li4.li4 /data/samba/daily/战略规划
[root@samba-server daily]# chmod -R 700 /data/samba/daily/战略规划
[root@samba-server daily]# setfacl -R -m u:yu1:rwx /data/samba/daily/战略规划
[root@samba-server daily]# setfacl -R -m g:regular:rx /data/samba/daily/战略规划
// 把正式员工添加到正式员工 (regular) 的组内
[root@samba-server daily]# gpasswd -a zhang3 regular
[root@samba-server daily]# gpasswd -a li4 regular
[root@samba-server daily]# gpasswd -a yu1 regular
[root@samba-server daily]# gpasswd -a yu2 regular
      
[root@samba-server daily]# mkdir 公司建议
[root@samba-server daily]# chown -R zhang3.zhang3 /data/samba/daily/公司制度
[root@samba-server daily]# chmod -R 700 /data/samba/daily/公司制度
[root@samba-server daily]# setfacl -R -m g:regular:rwx /data/samba/daily/公司制度
      
[root@samba-server daily]# mkdir 共享资料
[root@samba-server daily]# chown -R zhang3.zhang3 /data/samba/daily/共享资料
[root@samba-server daily]# chmod -R 700 /data/samba/daily/共享资料
[root@samba-server daily]# setfacl -R -m g:regular:rwx /data/samba/daily/共享资料
[root@samba-server daily]# setfacl -R -m g:intern:rx /data/samba/daily/共享资料
// 把实习生添加到实习生 (intern) 的组内
[root@samba-server daily]# gpasswd -a chuxx intern
[root@samba-server daily]# gpasswd -a xiaoma intern

# 读写区
[root@samba-server daily]# cd ../read-write/
[root@samba-server read-write]# mkdir /data/samba/read-write/周报总结
[root@samba-server read-write]# chown -R yu2.yu2 /data/samba/read-write/周报总结
[root@samba-server read-write]# chmod -R 700 /data/samba/read-write/周报总结
      
[root@samba-server read-write]# mkdir /data/samba/read-write/工作记录
[root@samba-server read-write]# chown -R zhang3.zhang3 /data/samba/read-write/工作记录
[root@samba-server read-write]# chmod -R 700 /data/samba/read-write/工作记录
[root@samba-server read-write]# setfacl -R -m g:regular:rwx /data/samba/read-write/作记录
      
[root@samba-server read-write]# mkdir /data/samba/read-write/休闲娱乐
[root@samba-server read-write]# chown -R zhang3.zhang3 /data/samba/read-write/休闲娱乐
[root@samba-server read-write]# chmod -R 700 /data/samba/read-write/休闲娱乐
[root@samba-server read-write]# setfacl -R -m g:regular:rwx /data/samba/read-write/休闲娱乐
[root@samba-server read-write]# setfacl -R -m g:intern:rwx /data/samba/read-write/休闲娱乐
~~~

王总 (wangzong) 对整个共享具有读写权限, 还要赋权给王总
~~~shell
[root@samba-server ~]# setfacl -R -m u:wangzong:rwx /data/samba/daily/重大事项
[root@samba-server ~]# setfacl -R -m u:wangzong:rwx /data/samba/daily/财务报表
[root@samba-server ~]# setfacl -R -m u:wangzong:rwx /data/samba/daily/战略规划
[root@samba-server ~]# setfacl -R -m u:wangzong:rwx /data/samba/daily/公司建议
[root@samba-server ~]# setfacl -R -m u:wangzong:rwx /data/samba/daily/共享资料

[root@samba-server ~]# setfacl -R -m u:wangzong:rwx /data/samba/read-write/周报总结
[root@samba-server ~]# setfacl -R -m u:wangzong:rwx /data/samba/read-write/工作记录
[root@samba-server ~]# setfacl -R -m u:wangzong:rwx /data/samba/read-write/休闲娱乐
~~~

6. 修订 samba 服务器配置文件
编辑 /etc/samba/smb.conf，追加
~~~shell
[share]
    comment = "公司共享文件系统s"
    path= /data/samba
    public = no
    valid users = wangzong,zhang3,li4,yu1,yu2,chuxx,xiaoma,@samba
    printable = no
    write list = wangzong,zhang3,li4,yu1,yu2,chuxx,xiaoma

7. 重启 samba 服务器
~~~shell
[root@samba-server ~]# systemctl restart smb.service
~~~
