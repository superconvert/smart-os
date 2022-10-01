# 单独运行 xfce4 组件 （ 不编译 smart-os, 单独编译 xfce4 ）
1. 利用 wmare 安装 Ubuntu 18.04 Server 版本，安装完毕，配置 apt 源，ssh 等操作，就不要再做过多的操作了，尽量保持系统纯净
2. 修订 common.sh 文件里面的 with_xfce_test=true
3. ./mk_xfce.sh 进行 xfce4 的编译，编译完毕会自动生成 startxfce.sh
4. 在 wmware 虚拟机里面执行 ldconfig，然后再执行 startxfce.sh 就可以成功拉起桌面了

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

# xrdp 远程访问 linux 桌面流程分析（ 重要 ）

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
-- The start-up result is RESULT.
Aug 18 01:45:04 freeabc xrdp-sesman[10688]: (10688)(140145709626688)[DEBUG] Closed socket 7 (AF_INET6 ::1 port 3350)
Aug 18 01:45:04 freeabc xrdp[10687]: (10687)(139797313210176)[DEBUG] xrdp_wm_log_msg: started connecting
Aug 18 01:45:04 freeabc xrdp-sesman[10688]: (10688)(140145709626688)[DEBUG] Closed socket 8 (AF_INET6 ::1 port 3350)
Aug 18 01:45:04 freeabc xrdp-sesman[10690]: (10690)(140145709626688)[INFO ] /usr/lib/xorg/Xorg :11 -auth .Xauthority -config xrdp/xorg.conf -noreset -nolisten tcp -logfile .xorgxrdp.%s.log
Aug 18 01:45:04 freeabc xrdp-sesman[10688]: (10688)(140145709626688)[CORE ] waiting for window manager (pid 10689) to exit
Aug 18 01:45:04 freeabc systemd[1487]: Started GnuPG cryptographic agent and passphrase cache.
-- Subject: Unit UNIT has finished start-up
-- Defined-By: systemd
-- Support: http://www.ubuntu.com/support
--
-- Unit UNIT has finished starting up.
--
-- The start-up result is RESULT.
Aug 18 01:45:04 freeabc gpg-agent[10760]: gpg-agent (GnuPG) 2.2.4 starting in supervised mode.
Aug 18 01:45:04 freeabc gpg-agent[10760]: using fd 3 for ssh socket (/run/user/0/gnupg/S.gpg-agent.ssh)
Aug 18 01:45:04 freeabc gpg-agent[10760]: using fd 4 for extra socket (/run/user/0/gnupg/S.gpg-agent.extra)
Aug 18 01:45:04 freeabc gpg-agent[10760]: using fd 5 for std socket (/run/user/0/gnupg/S.gpg-agent)
Aug 18 01:45:04 freeabc gpg-agent[10760]: using fd 6 for browser socket (/run/user/0/gnupg/S.gpg-agent.browser)
Aug 18 01:45:04 freeabc gpg-agent[10760]: listening on: std=5 extra=4 browser=6 ssh=3
Aug 18 01:45:04 freeabc kernel: xfce4-session[10742]: segfault at 2c ip 0000556e4a4fe8c6 sp 00007ffedc54cd30 error 4 in xfce4-session[556e4a4d2000+45000]
Aug 18 01:45:04 freeabc xrdp[10687]: (10687)(139797313210176)[INFO ] lib_mod_log_peer: xrdp_pid=10687 connected to X11rdp_pid=10690 X11rdp_uid=0 X11rdp_gid=0 client_ip=::ffff:192.168.222.1 client_port=56030
Aug 18 01:45:04 freeabc xrdp[10687]: (10687)(139797313210176)[DEBUG] xrdp_wm_log_msg: connected ok
Aug 18 01:45:04 freeabc xrdp[10687]: (10687)(139797313210176)[DEBUG] xrdp_mm_connect_chansrv: chansrv connect successful
Aug 18 01:45:04 freeabc xrdp[10687]: (10687)(139797313210176)[DEBUG] Closed socket 20 (AF_INET6 ::1 port 36482)
Aug 18 01:45:04 freeabc xrdp[10687]: (10687)(139797313210176)[INFO ] The following channel is allowed: rdpdr (0)
Aug 18 01:45:04 freeabc xrdp[10687]: (10687)(139797313210176)[INFO ] The following channel is allowed: rdpsnd (1)
Aug 18 01:45:04 freeabc xrdp[10687]: (10687)(139797313210176)[INFO ] The following channel is allowed: cliprdr (2)
Aug 18 01:45:04 freeabc xrdp[10687]: (10687)(139797313210176)[INFO ] The following channel is allowed: drdynvc (3)
Aug 18 01:45:04 freeabc xrdp[10687]: (10687)(139797313210176)[DEBUG] The allow channel list now initialized for this session
Aug 18 01:45:04 freeabc xrdp-sesman[10688]: (10688)(140145709626688)[CORE ] window manager (pid 10689) did exit, cleaning up session
Aug 18 01:45:04 freeabc xrdp-sesman[10688]: (10688)(140145709626688)[INFO ] calling auth_stop_session and auth_end from pid 10688
Aug 18 01:45:04 freeabc xrdp-sesman[10688]: pam_unix(xrdp-sesman:session): session closed for user root
Aug 18 01:45:04 freeabc xrdp-sesman[10688]: (10688)(140145709626688)[DEBUG] cleanup_sockets:
Aug 18 01:45:04 freeabc xrdp[10687]: (10687)(139797313210176)[DEBUG] Closed socket 22 (AF_UNIX)
Aug 18 01:45:04 freeabc xrdp-sesman[10688]: (10688)(140145709626688)[DEBUG] cleanup_sockets: deleting /var/run/xrdp/sockdir/xrdp_chansrv_audio_out_socket_11
Aug 18 01:45:04 freeabc xrdp[10687]: (10687)(139797313210176)[DEBUG] Closed socket 12 (AF_INET6 ::ffff:192.168.222.178 port 3389)
Aug 18 01:45:04 freeabc xrdp-sesman[10688]: (10688)(140145709626688)[DEBUG] cleanup_sockets: deleting /var/run/xrdp/sockdir/xrdp_chansrv_audio_in_socket_11
Aug 18 01:45:04 freeabc xrdp[10687]: (10687)(139797313210176)[DEBUG] xrdp_mm_module_cleanup
Aug 18 01:45:04 freeabc xrdp[10687]: (10687)(139797313210176)[DEBUG] Closed socket 21 (AF_UNIX)
Aug 18 01:45:04 freeabc xrdp-sesman[10688]: (10688)(140145709626688)[DEBUG] cleanup_sockets: deleting /var/run/xrdp/sockdir/xrdpapi_11
Aug 18 01:45:04 freeabc xrdp-sesman[10471]: (10471)(140145709626688)[INFO ] ++ terminated session:  username root, display :11.0, session_pid 10688, ip ::ffff:192.168.222.1:56030 - socket: 12
Aug 18 01:45:14 freeabc systemd-logind[1076]: Removed session c15.
-- Subject: Session c15 has been terminated
```

这个日志可以看到更清楚的流程，具体日志见上
我们看到这个没启动起来是 xfce4-session[10742]: segfault at 2c ip 0000556e4a4fe8c6 sp 00007ffedc54cd30 error 4 in xfce4-session[556e4a4d2000+45000] 有段错误
这个错误，我们可以单独运行 xfce4-session 查看原因

```shell
xfwm4-Message: 02:00:03.303: Another Window Manager (Xfwm4) is already running on screen :10.0
xfwm4-Message: 02:00:03.303: To replace the current window manager, try "--replace"
(xfwm4:11384): xfwm4-WARNING **: 02:00:03.303: Could not find a screen to manage, exiting
```

我们看到是另外一个 Xfwn4 已经启动在 screen :10.0 了，可以运行 xfwm4 --replace 替换一下
对用户的授权，我们通过日志可以观察到是通过文件 ~/.Xauthority

5. xrdp-sesman 会根据 sesman.ini 调用 /etc/xrdp/startwm.sh，这个脚本最终会调用 /etc/X11/Xsession 这个脚本, Xsession 这个脚本大有文章
```shell
SYSSESSIONDIR=/etc/X11/Xsession.d
USERXSESSION=$HOME/.xsession  ---> 看到没有这就是我们经常看到的很多文章推荐的 echo "xfce4-session" > ~/.xsession 的原因，设置 Xsession 的环境变量
...
SESSIONFILES=$(run-parts --list $SYSSESSIONDIR)  ---> 最终会执行 /etc/X11/Xsession.d 下的脚本，我们所有的窗口会话实现，应该放到这个里面

if [ -n "$SESSIONFILES" ]; then
  set +e
  for SESSIONFILE in $SESSIONFILES; do
    echo $SESSIONFILES >> /root/my.log
    . $SESSIONFILE
  done
  set -e
fi
```

/etc/X11/Xsession.d/20dbus_xdg-runtime
/etc/X11/Xsession.d/20x11-common_process-args
/etc/X11/Xsession.d/30x11-common_xresources
/etc/X11/Xsession.d/35x11-common_xhost-local
/etc/X11/Xsession.d/40x11-common_xsessionrc
/etc/X11/Xsession.d/50x11-common_determine-startup
/etc/X11/Xsession.d/60x11-common_localhost
/etc/X11/Xsession.d/60x11-common_xdg_path
/etc/X11/Xsession.d/75dbus_dbus-launch
/etc/X11/Xsession.d/90gpg-agent
/etc/X11/Xsession.d/90qt-a11y
/etc/X11/Xsession.d/90x11-common_ssh-agent
/etc/X11/Xsession.d/95dbus_update-activation-env
/etc/X11/Xsession.d/99x11-common_start

参数 STARTUP 赋值
我们看到执行 /etc/X11/Xsession.d/50x11-common_determine-startup 时，会 STARTUP="$shell $STARTUPFILE" 其实就是 /bin/bash /root/.xsession , root就是 ~ 我们用 root 登录的。

参数 STARTUP 运行
我们跟踪执行 /etc/X11/Xsession.d/99x11-common_start/99x11-common_start 时，exec $STARTUP 这个其实就是执行 xfce4-session 了，至此 xfce4-session 启动完成

xfce4-session 会读取 下面的文件，并执行里面的命令
https://manpages.ubuntu.com/manpages/xenial/man1/xfce4-session.1.html  
xfce4-session  reads its configuration from Xfconf.  xfce4-session stores its session data into $XDG_CACHE_HOME/sessions/.

具体配置文件就是 /usr/local/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml
```xml
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-session" version="1.0">
  <property name="general" type="empty">
    <property name="FailsafeSessionName" type="string" value="Failsafe"/>
    <property name="LockCommand" type="string" value=""/>
  </property>
  <property name="sessions" type="empty">
    <property name="Failsafe" type="empty">
      <property name="IsFailsafe" type="bool" value="true"/>
      <property name="Count" type="int" value="5"/>
      <property name="Client0_Command" type="array">
        <value type="string" value="xfwm4"/>
      </property>
      <property name="Client0_Priority" type="int" value="15"/>
      <property name="Client0_PerScreen" type="bool" value="false"/>
      <property name="Client1_Command" type="array">
        <value type="string" value="xfsettingsd"/>
      </property>
      <property name="Client1_Priority" type="int" value="20"/>
      <property name="Client1_PerScreen" type="bool" value="false"/>
      <property name="Client2_Command" type="array">
        <value type="string" value="xfce4-panel"/>
      </property>
      <property name="Client2_Priority" type="int" value="25"/>
      <property name="Client2_PerScreen" type="bool" value="false"/>
      <property name="Client3_Command" type="array">
        <value type="string" value="Thunar"/>
        <value type="string" value="--daemon"/>
      </property>
      <property name="Client3_Priority" type="int" value="30"/>
      <property name="Client3_PerScreen" type="bool" value="false"/>
      <property name="Client4_Command" type="array">
        <value type="string" value="xfdesktop"/>
      </property>
      <property name="Client4_Priority" type="int" value="35"/>
      <property name="Client4_PerScreen" type="bool" value="false"/>
    </property>
  </property>
</channel>
```

我们看到一个会话启动五个最基本的服务 xfwm4, xfsettingsd, xfce4-panel, Thunar, xfdesktop，如果启动失败，请依次排查这几个服务是否正常
如果只出状态栏和 Dock ，桌面出现黑屏，基本上是 xfdesktop 启动失败，可能依赖的库不满足，缺少什么库，这个需要具体问题具体分析了。
进程关系如下图
```shell
systemd--
        |-xrdp---xrdp
        |-xrdp-sesman---xrdp-sesman---Xorg---9*[{Xorg}]
                                    |-bash---ssh-agent
                                    |      |-xfce4-session---Thunar---2*[{Thunar}]
                                    |                      |-xfce4-panel---panel-14-action---2*[{panel-14-action}]
                                    |                      |             |-panel-6-systray---2*[{panel-6-systray}]
                                    |                      |             |-panel-9-power-m---2*[{panel-9-power-m}]
                                    |                      |             |-2*[{xfce4-panel}]
                                    |                      |-xfce4-power-man---2*[{xfce4-power-man}]
                                    |                      |-xfdesktop---2*[{xfdesktop}]
                                    |                      |-xfsettingsd---2*[{xfsettingsd}]
                                    |                      |-xfwm4---2*[{xfwm4}]
                                    |                      |-10*[{xfce4-session}]
                                    |-xrdp-chansrv---{xrdp-chansrv}
```

Xorg 就是我们通常说的 xserver, 有关整个流程的调试，我们可以用下述命令进行错误排除
```shell
env LD_LIBRARY_PATH="/root/test/build/test/a/usr/lib:/root/test/build/test/a/usr/local/lib:/root/test/build/test/a/usr/lib/x86_64-linux-gnu:/root/test/build/test/a/opt/libjpeg-turbo/lib64" DBUS_SESSION_BUS_ADDRESS="unix:path=/var/run/dbus/session_bus_socket" strace -f xrdp-sesman -n
```
基本上 xrdp-sesman 会启动 Xorg ( xserver ), Xorg 会通过 tcp 或 Unix socket 与 xclient 进行通讯；还会启动 xsession, 还会启动 xrdp-chansrv，从上述我们可以得知，这些组件都必须启动成功，否则，就会看不到图像界面。我们通过 strace -f 跟踪得知 xrdp-sesman 是通过接口 execve 启动的 Xorg ，这个接口执行后，来自父进程的环境变量将会被清除，导致 LD_LIBRARY_PATH 失效，因此 Xorg 所依赖的动态库就找不到，解决方法就是把库直接拷贝到系统库的位置，就行，比如：
```shell
cp /root/smart-os/build/test/a/usr/lib/x86_64-linux-gnu/libharfbuzz.so.0 /usr/lib/x86_64-linux-gnu/
```

# 常见问题解决方法
1. 解决 Fontconfig error: Cannot load default config file: No such file
cp /root/test/a/usr/local/etc/* /usr/local/etc/ -rf

2. 解决 Cannot read private key file /etc/xrdp/key.pem: Permission denied
    ```shell
    adduser xrdp ssl-cert
    reboot
    ```

3. 解决 libpango 库多版本的环境下，系统的低版本优先加载，导致 xfdesktop 不能正常启动的问题我们可以这么做
    ```shell
    libdir=`pwd`"/a/usr"
    echo "LD_LIBRARY_PATH=\"${libdir}/lib:${libdir}/local/lib:${libdir}/lib/x86_64-linux-gnu\" xfce4-session" > ~/.xsession
    ```
    这样就可以优先加载我们编译的动态库了

4. xfce4-session 其实相应的配置也可以通过命令行工具查看
xfconf-query -c xfce4-session -p /sessions/Failsafe/Client3_Command
我们可以逐行查看每个属性，然后通过 ps -aef | grep xf* 查看相应的进程是否正确启动，如果没有启动，就会导致出现问题，然后单独手工启动那个进程，查看是什么原因导致不能正常启动的，解决问题就非常简单了。

5. xfdesktop 启动时，提示：Settings schema 'org.gtk.Settings.FileChooser' is not installed  
方法：apt install libgtk-3-common

6. xfce4 编译后，启动远程桌面，发现面板上相应的 item 都没有图标，进入文件管理器，对应的文件也没有图标，只显示文字，需要安装  
方法：apt install gnome-icon-theme，当然这两个问题只装 libgtk-3-common 都可以解决

7. 编译 libxi 库时，会提示下面的错误，我们去官方网站去看 发现 inputproto  项目已经被废弃，怎么办？
    ```shell
    configure: error: Package requirements (xproto >= 7.0.13 x11 >= 1.6 xextproto >= 7.0.3 xext >= 1.0.99.1 inputproto >= 2.3.99.1) were not met:
    Requested 'inputproto >= 2.3.99.1' but version of InputProto is 2.3.2
    ```
    方法：其实现在这些（inputproto）都被合并到项目 xorgproto 里面了，编译这个库就行了，这个问题折腾我好久

8. 编译 libx11 遇到问题
    ```shell
    checking keysym definitions... configure: error: /usr/local/include/X11 doesn't exist or isn't a directory
    ```
    方法: --with-keysymdefdir="${xfce_install}/usr/local/include/X11"
    
9. 编译 pciaccess, libxcb-util 遇到问题
    ```shell
    error: must install xorg-macros 1.8 or later before running autoconf/autogen
    error: must install xorg-macros 1.16.0 or later before running autoconf/autogen
    ```
    方法: 原因就是 aclocal 的路径设置的不完全 
    ```shell
    export ACLOCAL="aclocal -I /usr/share/aclocal -I ${xfce_share}/aclocal -I ${xfce_loc_share}/aclocal"
    ```
10. 我们利用 xrdp 远程访问 xfce 桌面黑屏，查看日志 .xsession-errors，发现提示下述错误
    ```shell
    (xfce4-session:1904): xfce4-session-WARNING **: 11:23:52.330: ICE connection 0x55b030d772e0 rejected
    (xfwm4:1942): xfwm4-WARNING **: 11:23:52.330: Failed to connect to session manager: Failed to connect to the session manager: Authentication Rejected, reason : None of the authentication protocols specified are supported and host-based authentication failed
    (xfce4-session:1904): xfce4-session-WARNING **: 11:24:00.217: ICE connection 0x55b030ddb520 rejected
    Failed to connect to session manager: Failed to connect to the session manager: Authentication Rejected, reason : None of the authen
    tication protocols specified are supported and host-based authentication failed
    ```
    我们进一步追踪，journalctl -xf 
    ```shell
    Aug 28 11:30:52 freeabc xrdp[2172]: (2172)(139849385854784)[INFO ] Using default X.509 key file: /etc/xrdp/key.pem
    Aug 28 11:30:52 freeabc xrdp[2172]: (2172)(139849385854784)[ERROR] Cannot read private key file /etc/xrdp/key.pem: Permission denied
    Aug 28 11:30:52 freeabc xrdp[2172]: (2172)(139849385854784)[DEBUG] TLSv1.2 enabled
    Aug 28 11:30:52 freeabc xrdp[2172]: (2172)(139849385854784)[DEBUG] TLSv1.1 enabled
    Aug 28 11:30:52 freeabc xrdp[2172]: (2172)(139849385854784)[DEBUG] TLSv1 enabled
    Aug 28 11:30:52 freeabc xrdp[2172]: (2172)(139849385854784)[DEBUG] Security layer: requested 11, selected 0
    Aug 28 11:30:52 freeabc xrdp[2172]: (2172)(139849385854784)[DEBUG] Closed socket 12 (AF_INET6 ::ffff:192.168.1.101 port 3389)
    Aug 28 11:30:52 freeabc xrdp[1289]: (1289)(139849385854784)[INFO ] Socket 12: AF_INET6 connection received from ::ffff:192.168.1.105 port 11281
    Aug 28 11:30:52 freeabc xrdp[1289]: (1289)(139849385854784)[DEBUG] Closed socket 12 (AF_INET6 ::ffff:192.168.1.101 port 3389)
    Aug 28 11:30:52 freeabc xrdp[2173]: (2173)(139849385854784)[DEBUG] Closed socket 11 (AF_INET6 :: port 3389)
    Aug 28 11:30:52 freeabc xrdp[2173]: (2173)(139849385854784)[INFO ] Using default X.509 certificate: /etc/xrdp/cert.pem
    Aug 28 11:30:52 freeabc xrdp[2173]: (2173)(139849385854784)[INFO ] Using default X.509 key file: /etc/xrdp/key.pem
    Aug 28 11:30:52 freeabc xrdp[2173]: (2173)(139849385854784)[ERROR] Cannot read private key file /etc/xrdp/key.pem: Permission denied
    ```
    我们看到是 key.pem 的权限不允许导致的,  sudo adduser xrdp ssl-cert  重启系统，这个问题解决

11. 如果我们运行 xsession 提示 Can't open display， 即使我们设置环境变量 export DISPLAY=:10 ，也是这个提示，引起这个问题的原因有很多，但我们首先第一步要做的是要检查 Xorg( xserver ) 服务在不在，一般情况通常会忽略这个检查

12. Xorg（xserver） 启动时，提示错误
    ```shell
    Using system config directory "/usr/local/share/X11/xorg.conf.d"
    MESA-LOADER: failed to open vmwgfx (search paths /usr/lib/x86_64-linux-gnu/dri)
    failed to load driver: vmwgfx
    MESA-LOADER: failed to open kms_swrast (search paths /usr/lib/x86_64-linux-gnu/dri)
    failed to load driver: kms_swrast
    MESA-LOADER: failed to open swrast (search paths /usr/lib/x86_64-linux-gnu/dri)
    failed to load swrast driver
    couldn't get display device
    ```
    解决：缺失显卡驱动  
    apt install libgl1-mesa-dri

13. Xorg（xserver）启动时，提示错误
    ```shell
    XKB: Failed to compile keymap
    Keyboard initialization failed. This could be a missing or incorrect setup of xkeyboard-config.
    (EE) 
    Fatal server error:
    (EE) Failed to activate virtual core keyboard: 2(EE) 
    (EE) 
    ```
    解决：
    ln -s /usr/share/X11/xkb /usr/local/share/X11/xkb  
    这样再运行 Xorg 就可以正常运行了。

14. failed to load driver: swrast
    ```shell
    LD_LIBRARY_PATH="/root/smart-os/build/test/a/usr/lib:/root/smart-os/build/test/a/usr/local/lib:/root/smart-os/build/test/a/usr/lib/x86_64-linux-gnu:/root/smart-os/build/test/a/opt/libjpeg-turbo/lib64" xfwm4
    MESA-LOADER: failed to open swrast (search paths /usr/lib/x86_64-linux-gnu/dri)
    libGL error: failed to load driver: swrast
    ```
    解决：  
    apt install libgl1-mesa-dri
    
15. 我们的 upower.service 运行依赖我们编译的 glib 库，系统自带的 glib 版本有点低，我们为 systemd 的服务单元增加环境变量，才能让 unit 正确运行  
    因此我们需要编辑 vi /lib/systemd/system/upower.service
    ```shell
    [Service]
    Type=dbus
    BusName=org.freedesktop.UPower
    ExecStart=/usr/libexec/upowerd
    Restart=on-failure
    Environment="LD_LIBRARY_PATH=/root/smart-os/build/test/a/usr/lib:/root/smart-os/build/test/a/usr/local/lib:/root/smart-os/build/test/a/usr/lib/x86_64-linux-gnu:/root/smart-os/build/test/a/opt/libjpeg-turbo/lib64"
    ```

16. 通过 systemctl start upower.service ，启动会被系统强杀 SIGSYS ( syscall=12 )，apport.log 会提示下面的错误
    ```shell
    ERROR: apport (pid 3268) Thu Sep 15 10:25:01 2022: host pid 3257 crashed in a separate mount namespace, ignoring
    ```
    journalctl -xf 会提示下面的错误
    ```shell
    Sep 15 10:25:01 freeabc kernel: [ 5505.813250] audit: type=1326 audit(1663237501.505:66): auid=4294967295 uid=0 gid=0 ses=4294967295 pid=3300 comm="upowerd" 
    exe="/usr/local/bin/upowerd" sig=31 arch=c000003e syscall=12 compat=0 ip=0x7f40bfa9c0a9 code=0x0
    ```
    单独执行 /usr/libexec/upowerd -v ，也能成功执行。这个问题让我困惑了好久，目前找到解决方法了；我们需要做的是把 upower.service 里面的几句话注释掉即可
    ```shell
    # System call interfaces
    LockPersonality=yes
    SystemCallArchitectures=native
    SystemCallFilter=@system-service
    SystemCallFilter=ioprio_get
    ```
    猜测这样可能就不会启动 seccomp 的功能了，upower.service 调用的系统调用就能正确进行了，保证 systemctl start upower.service 启动成功
    
17. 如果采用高版本的 glibc 库，mk_xfce4.sh 的编译就会出现很多问题，编译 harfbuzz，gdk-pixbuf 都会遇到问题: linking of temporary binary failed，died with <Signals.SIGSEGV: 11>，目前采用降低 glibc ( 2.32 ---> 2.27 ) 版本的方法，编译通过 
