# xfce4 组件介绍
[Gtk+]  
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
[xfce]  
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
