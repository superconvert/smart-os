# xfce4 组件介绍
* cairo
* harfbuzz
* freetype2
* pixman
* 
# Cairo 
cairo is a vector graphics library with cross-device output support  
cairo能够做各种复杂的点线图案绘制、填充、文字渲染、图像变换、剪切、层混合等等操作。但是他没有涉及到用户交互，如鼠标、touch、事件处理，交互窗口，这些统统没有，他只有专一的绘图。他有surface可以理解为画布，这个surface可以是基于内存（image surface，必选的surface）也可以基于某种backend（和操作系统或驱动接口对接），使用过程是创建一个surface，然后在surface里做各种绘图，最后使用Painting类的functions时图像就显示在了surface上。当然surface也是一块image，可以把image通过png（源码有对接libpng库）图像压缩输出png文件
