# xfce4 组件介绍
* [ Gtk+ ] 这些组件 gtk 最庞大  
  libffi  
  libmount  
  glib  
  pixman  
  freetype  
  harfbuzz  
  fontconfig  
  cairo  
  fribidi  
  pango  
  gdkpixbuf  
  libeproxy  
  graphene  
  wayland-protocols  
  gettext( libintl )  
  gtk+  
* [ xfce ] 这些组件编译顺序也有要求  
  libwnck  
  xfce4-dev-tools  
  xlibxfce4util  
  xfconf  
  libxfce4ui  
  garcon  
  exo  
  xfce4-panel  
  thunar 
  xfce4-settings  
  xfce4-session  
  xfwm4  
  xfdesktop  
  thunar-volman  
  tumbler  
  xfce4-power-manager  
  xfce4-appfinder  

# Cairo 
cairo is a vector graphics library with cross-device output support  
cairo能够做各种复杂的点线图案绘制、填充、文字渲染、图像变换、剪切、层混合等等操作。但是他没有涉及到用户交互，如鼠标、touch、事件处理，交互窗口，这些统统没有，他只有专一的绘图。他有surface可以理解为画布，这个surface可以是基于内存（image surface，必选的surface）也可以基于某种backend（和操作系统或驱动接口对接），使用过程是创建一个surface，然后在surface里做各种绘图，最后使用Painting类的functions时图像就显示在了surface上。当然surface也是一块image，可以把image通过png（源码有对接libpng库）图像压缩输出png文件

# harfbuzz
HarfBuzz 是一个文本整形引擎。它主要支持OpenType，但也 支持Apple Advanced Typography。HarfBuzz 用于 Android、Chrome、ChromeOS、Firefox、GNOME、GTK+、KDE、LibreOffice、OpenJDK、PlayStation、Qt、XeTeX 等地方。


# xfce 运行黑屏怎么办
比如黑屏，我们由屏幕想到可能是 xfdesktop 这个应用负责渲屏，黑屏可能是 xfdesktop 未能正确运行，这个就需要我们手工调试跟踪了，通常情况下我们会这么做：
```shell
# 设置屏幕，这个是 xfce 默认的值 10
export DISPLAY=:10
# 执行这个，正常执行理论上就不会黑屏，不能执行，可能是依赖库路径不对，版本不对，配置不对，逐步根据提示解决问题
xfdesktop
```
# xfce4-session 每个客户建立一个屏幕，具体动作的执行在下面配置文件
/usr/local/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml 其实就是执行的 xfdesktop  
startxfce4 ---> xinitrc ---> xfce4-session ---> xfdesktop

# xrdp 远程访问 linux 桌面流程分析



1. xrdp 服务依赖 xrdp-sesman 服务

我们可以通过 grep 全局查找 xrdp-sesman，发现下面这句

```shell

./lib/systemd/system/xrdp.service:4:Requires=xrdp-sesman.service

```

因此 xrdp 启动时，肯定 xrdp-sesman 也相应启动，具体机制待研究(TODO)



2. 配置文件 /etc/xrdp/sesman.ini

```shell

[Globals]

ListenAddress=127.0.0.1

ListenPort=3350

```

3. 确认 xrdp 和 xrdp-sesman 服务

```shell

root@freeabc:/# netstat -anpt | grep xrdp

tcp6       0      0 :::3389                 :::*                    LISTEN      6288/xrdp           

tcp6       0      0 ::1:3350                :::*                    LISTEN      6259/xrdp-sesman

```



其中 xrdp 是 3389 对外提供服务, xrdp-sesman 是 3350 对 xrdp 提供服务，xrdp 把请求转给 xrdp-sesman (经过 tcpdump 抓包确认是)

```shell

root@freeabc:/# tcpdump -s 0 -i lo port 3350 -v -n

tcpdump: listening on lo, link-type EN10MB (Ethernet), capture size 262144 bytes

01:37:24.538435 IP6 (flowlabel 0xc281a, hlim 64, next-header TCP (6) payload length: 40) ::1.52600 > ::1.3350: Flags [S], cksum 0x0030 (incorrect -> 0x3f1d), seq 213438096, win 65476, options [mss 65476,sackOK,TS val 4262615841 ecr 0,nop,wscale 7], length 0

01:37:24.538457 IP6 (flowlabel 0xe10b3, hlim 64, next-header TCP (6) payload length: 40) ::1.3350 > ::1.52600: Flags [S.], cksum 0x0030 (incorrect -> 0xbea4), seq 3363004107, ack 213438097, win 65464, options [mss 65476,sackOK,TS val 4262615841 ecr 4262615841,nop,wscale 7], length 0

01:37:24.538472 IP6 (flowlabel 0xc281a, hlim 64, next-header TCP (6) payload length: 32) ::1.52600 > ::1.3350: Flags [.], cksum 0x0028 (incorrect -> 0xe53a), ack 1, win 512, options [nop,nop,TS val 4262615841 ecr 4262615841], length 0

01:37:25.149700 IP6 (flowlabel 0xc281a, hlim 64, next-header TCP (6) payload length: 109) ::1.52600 > ::1.3350: Flags [P.], cksum 0x0075 (incorrect -> 0x6a7f), seq 1:78, ack 1, win 512, options [nop,nop,TS val 4262616452 ecr 4262615841], length 77

01:37:25.149734 IP6 (flowlabel 0xe10b3, hlim 64, next-header TCP (6) payload length: 32) ::1.3350 > ::1.52600: Flags [.], cksum 0x0028 (incorrect -> 0xe028), ack 78, win 511, options [nop,nop,TS val 4262616452 ecr 4262616452], length 0

01:37:25.216918 IP6 (flowlabel 0xe10b3, hlim 64, next-header TCP (6) payload length: 62) ::1.3350 > ::1.52600: Flags [P.], cksum 0x0046 (incorrect -> 0xd13d), seq 1:31, ack 78, win 512, options [nop,nop,TS val 4262616519 ecr 4262616452], length 30

01:37:25.216969 IP6 (flowlabel 0xc281a, hlim 64, next-header TCP (6) payload length: 32) ::1.52600 > ::1.3350: Flags [.], cksum 0x0028 (incorrect -> 0xdf83), ack 31, win 512, options [nop,nop,TS val 4262616519 ecr 4262616519], length 0

01:37:25.254713 IP6 (flowlabel 0xe10b3, hlim 64, next-header TCP (6) payload length: 32) ::1.3350 > ::1.52600: Flags [F.], cksum 0x0028 (incorrect -> 0xdf5c), seq 31, ack 78, win 512, options [nop,nop,TS val 4262616557 ecr 4262616519], length 0

01:37:25.297973 IP6 (flowlabel 0xc281a, hlim 64, next-header TCP (6) payload length: 32) ::1.52600 > ::1.3350: Flags [.], cksum 0x0028 (incorrect -> 0xdf0b), ack 32, win 512, options [nop,nop,TS val 4262616600 ecr 4262616557], length 0

01:37:25.886713 IP6 (flowlabel 0xc281a, hlim 64, next-header TCP (6) payload length: 32) ::1.52600 > ::1.3350: Flags [F.], cksum 0x0028 (incorrect -> 0xdcbd), seq 78, ack 32, win 512, options [nop,nop,TS val 4262617189 ecr 4262616557], length 0

01:37:25.886737 IP6 (flowlabel 0xc429c, hlim 64, next-header TCP (6) payload length: 32) ::1.3350 > ::1.52600: Flags [.], cksum 0x0028 (incorrect -> 0xda45), ack 79, win 512, options [nop,nop,TS val 4262617189 ecr 4262617189], length 0

01:37:41.603074 IP6 (flowlabel 0x461f5, hlim 64, next-header TCP (6) payload length: 32) ::1.46136 > ::1.3350: Flags [F.], cksum 0x0028 (incorrect -> 0x23fc), seq 3577026672, ack 1112127163, win 512, options [nop,nop,TS val 4262632906 ecr 4262596309], length 0

01:37:41.603101 IP6 (flowlabel 0xeaed7, hlim 64, next-header TCP (6) payload length: 32) ::1.3350 > ::1.46136: Flags [.], cksum 0x0028 (incorrect -> 0x9506), ack 1, win 512, options [nop,nop,TS val 4262632906 ecr 4262632906], length 0

```



我们也可以利用 journalctl -xf 查看日志

```shell

Aug 18 01:45:02 freeabc xrdp[10507]: (10507)(139797313210176)[INFO ] Socket 12: AF_INET6 connection received from ::ffff:192.168.222.1 port 56030

Aug 18 01:45:02 freeabc xrdp[10507]: (10507)(139797313210176)[DEBUG] Closed socket 12 (AF_INET6 ::ffff:192.168.222.178 port 3389)

Aug 18 01:45:02 freeabc xrdp[10687]: (10687)(139797313210176)[DEBUG] Closed socket 11 (AF_INET6 :: port 3389)

Aug 18 01:45:03 freeabc xrdp[10687]: (10687)(139797313210176)[INFO ] Using default X.509 certificate: /etc/xrdp/cert.pem

Aug 18 01:45:03 freeabc xrdp[10687]: (10687)(139797313210176)[INFO ] Using default X.509 key file: /etc/xrdp/key.pem

Aug 18 01:45:03 freeabc xrdp[10687]: (10687)(139797313210176)[DEBUG] TLSv1.2 enabled

Aug 18 01:45:03 freeabc xrdp[10687]: (10687)(139797313210176)[DEBUG] TLSv1.1 enabled

Aug 18 01:45:03 freeabc xrdp[10687]: (10687)(139797313210176)[DEBUG] TLSv1 enabled

Aug 18 01:45:03 freeabc xrdp[10687]: (10687)(139797313210176)[DEBUG] Security layer: requested 11, selected 1

Aug 18 01:45:03 freeabc xrdp[10687]: (10687)(139797313210176)[INFO ] connected client computer name: DESKTOP-9PAUEP4

Aug 18 01:45:03 freeabc xrdp[10687]: (10687)(139797313210176)[INFO ] TLS connection established from ::ffff:192.168.222.1 port 56030: TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384

Aug 18 01:45:03 freeabc xrdp[10687]: (10687)(139797313210176)[DEBUG] xrdp_000029bf_wm_login_mode_event_00000001

Aug 18 01:45:03 freeabc xrdp[10687]: (10687)(139797313210176)[INFO ] Cannot find keymap file /etc/xrdp/km-00000804.ini

Aug 18 01:45:03 freeabc xrdp[10687]: (10687)(139797313210176)[INFO ] Cannot find keymap file /etc/xrdp/km-00000804.ini

Aug 18 01:45:03 freeabc xrdp[10687]: (10687)(139797313210176)[INFO ] Loading keymap file /etc/xrdp/km-00000409.ini

Aug 18 01:45:03 freeabc xrdp[10687]: (10687)(139797313210176)[WARN ] local keymap file for 0x00000804 found and doesn't match built in keymap, using local keymap file

Aug 18 01:45:03 freeabc xrdp[10687]: (10687)(139797313210176)[DEBUG] xrdp_wm_log_msg: connecting to sesman ip 127.0.0.1 port 3350

Aug 18 01:45:03 freeabc xrdp-sesman[10471]: (10471)(140145709626688)[INFO ] A connection received from ::1 port 36482

Aug 18 01:45:04 freeabc xrdp[10687]: (10687)(139797313210176)[INFO ] xrdp_wm_log_msg: sesman connect ok

Aug 18 01:45:04 freeabc xrdp[10687]: (10687)(139797313210176)[DEBUG] xrdp_wm_log_msg: sending login info to session manager, please wait...

Aug 18 01:45:04 freeabc xrdp[10687]: (10687)(139797313210176)[DEBUG] return value from xrdp_mm_connect 0

Aug 18 01:45:04 freeabc xrdp-sesman[10471]: (10471)(140145709626688)[INFO ] ++ created session (access granted): username root, ip ::ffff:192.168.222.1:56030 - socket: 12

Aug 18 01:45:04 freeabc xrdp-sesman[10471]: (10471)(140145709626688)[INFO ] starting Xorg session...

Aug 18 01:45:04 freeabc xrdp-sesman[10471]: (10471)(140145709626688)[DEBUG] Closed socket 9 (AF_INET6 :: port 5911)

Aug 18 01:45:04 freeabc xrdp-sesman[10471]: (10471)(140145709626688)[DEBUG] Closed socket 9 (AF_INET6 :: port 6011)

Aug 18 01:45:04 freeabc xrdp-sesman[10471]: (10471)(140145709626688)[DEBUG] Closed socket 9 (AF_INET6 :: port 6211)

Aug 18 01:45:04 freeabc xrdp-sesman[10688]: (10688)(140145709626688)[INFO ] calling auth_start_session from pid 10688

Aug 18 01:45:04 freeabc xrdp-sesman[10471]: (10471)(140145709626688)[DEBUG] Closed socket 8 (AF_INET6 ::1 port 3350)

Aug 18 01:45:04 freeabc xrdp[10687]: (10687)(139797313210176)[INFO ] xrdp_wm_log_msg: login successful for display 11

Aug 18 01:45:04 freeabc xrdp-sesman[10688]: pam_unix(xrdp-sesman:session): session opened for user root by (uid=0)

Aug 18 01:45:04 freeabc systemd-logind[1076]: New session c15 of user root.

-- Subject: A new session c15 has been created for user root

-- Defined-By: systemd

-- Support: http://www.ubuntu.com/support

-- Documentation: https://www.freedesktop.org/wiki/Software/systemd/multiseat

-- 

-- A new session with the ID c15 has been created for the user root.

-- 

-- The leading process of the session is 10688.

Aug 18 01:45:04 freeabc systemd[1]: Started Session c15 of user root.

-- Subject: Unit session-c15.scope has finished start-up

-- Defined-By: systemd

-- Support: http://www.ubuntu.com/support

-- 

-- Unit session-c15.scope has finished starting up.

-- 

