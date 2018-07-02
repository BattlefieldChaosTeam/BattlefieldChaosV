# pic2mif程序说明
使用python的PIL库，按位置读取像素点的rgb值，然后讲0-255范围的rgb值转化为0-7范围。将得到的结果写入mif文件（位宽为9位，3*3rgb值）

对于png文件，由于有alpha通道(标示透明度)，mif文件中有一位专门表示透明度信息，因此mif文件有10位。

运行方式: `python3 jpg2mif.py picname.jpg mifname.jpg` or
`python3 jpg2mif.py picname.jpg mifname.jpg`