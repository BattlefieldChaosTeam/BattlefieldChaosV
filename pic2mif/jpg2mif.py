# coding=utf-8 #
import sys
from PIL import Image

input_file = sys.argv[1]
output_file = sys.argv[2]

im = Image.open(input_file)
pix = im.load()
width = im.size[0] #长度
height = im.size[1] #宽度
print(width, height)
depth = width * height
mif_file = open(output_file, 'wb+')

mif_file.write(b'WIDTH=9;\n') #写入存储位宽8位 

str_tep = 'DEPTH='+str(depth)+';\n'
bs = bytes(str_tep, encoding='utf8')

mif_file.write(bs) #写入存储深度width*height
mif_file.write(b'ADDRESS_RADIX=UNS;\n') #写入地址类型为无符号整型  
mif_file.write(b'DATA_RADIX=BIN;\n') #写入数据类型为2进制  
mif_file.write(b'CONTENT BEGIN\n') #起始内容  

def setLen(str, length):
    while(len(str) < length): #前面用0补
        str = '0' + str
    return str
#横位x, 纵为y, 左上方为原点
for i in range(depth):
    y = int(i / width)
    x = int(i - width * y)
    print(x, y)
    pixel = pix[x, y]
    #print(pixel[0], pixel[1], pixel[2])
    r = int(pixel[0] / 32)
    g = int(pixel[1] / 32)
    b = int(pixel[2] / 32)
    r_bin = str(bin(r))[2:]
    g_bin = str(bin(g))[2:]
    b_bin = str(bin(b))[2:]
    r_bin = setLen(r_bin, 3)
    g_bin = setLen(g_bin, 3)
    b_bin = setLen(b_bin, 3)
    rgb_bin = str(str(i) + ':' + r_bin + g_bin + b_bin + '1;\n')
    rgb_bin = bytes(rgb_bin, encoding='utf-8')

    mif_file.write(rgb_bin)
    #if(b != 0):
    #    print(rgb_bin)

mif_file.write(b'END;\n')
mif_file.close()
print("finish converting")
