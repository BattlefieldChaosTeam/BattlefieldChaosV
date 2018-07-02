# coding=utf-8 #
'''
This program is used for png that has four channels rgba, for png that only has rgb channels, you can jut use jpg2mif
'''

import sys
from PIL import Image

input_file = sys.argv[1]
output_file = sys.argv[2]

img = Image.open(input_file, 'r')
#has_alpha = img.mode == 'RGBA'
#print(has_alpha)
width = img.size[0]
height = img.size[1]
print(width, height)
depth = width * height
mif_file = open(output_file, 'wb+')

mif_file.write(b'WIDTH=10;\n') #r,g,b各三位，透明度一位

str_tep = 'DEPTH=' + str(depth) + ';\n'
bs = bytes(str_tep, encoding='utf-8')

mif_file.write(bs)
mif_file.write(b'ADDRESS_RADIX=UNS;\n')
mif_file.write(b'DATA_RADIX=BIN;\n')
mif_file.write(b'CONTENT BEGIN\n')

def setLen(str, length):
    while(len(str) < length):
        str = '0' + str
    return str
# bands=img.split()
# print(type(bands))
# print(bands)
# for i in range(10):
#     for j in range(10):
#         print(bands[0].getpixel(i,j))
#print (img.split()[3].getpixel((0,0)))
print(img)
r = img.split()[0]
g = img.split()[1]
b = img.split()[2]
alpha = img.split()[3]

'''
for j in range(height):
    for i in range(width):
        print(i, j, r.getpixel((i, j)), g.getpixel((i, j)), b.getpixel((i, j)), alpha.getpixel((i, j)))
'''

#横为x，纵为y，左上方为原点
for i in range(depth):
    y = int(i / width)
    x = int(i - width * y)
    print(x, y, r.getpixel((x, y)), g.getpixel((x, y)), b.getpixel((x, y)), alpha.getpixel((x, y)))
    r_sgl = int(r.getpixel((x, y)) / 32)
    g_sgl = int(g.getpixel((x, y)) / 32)
    b_sgl = int(b.getpixel((x, y)) / 32)
    r_bin = str(bin(r_sgl))[2:]
    g_bin = str(bin(g_sgl))[2:]
    b_bin = str(bin(b_sgl))[2:]
    r_bin = setLen(r_bin, 3)
    g_bin = setLen(g_bin, 3)
    b_bin = setLen(b_bin, 3)
    if(alpha.getpixel((x, y)) > 0):
        alpha_bin = str(1)
    else:
        alpha_bin = str(0)
    rgba_bin = str(str(i) + ':' + r_bin + g_bin + b_bin + alpha_bin + ';\n')
    rgba_bin = bytes(rgba_bin, encoding = 'utf-8')

    mif_file.write(rgba_bin)

mif_file.write(b'END;\n')
mif_file.close()
print("finish converting")