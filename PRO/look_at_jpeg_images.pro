
file='C:\Documents and Settings\Peter Thejll\My Documents\My Pictures\Image_0011.jpg'
read_jpeg,file,im
r=float(reform(im(0,*,*)))
b=float(reform(im(1,*,*)))
g=float(reform(im(2,*,*)))
sum=(r+g+b)/3.
tvscl,sum
write_jpeg,'C:\Documents and Settings\Peter Thejll\My Documents\My Pictures\sum.jpg',sum,quality=100
read_jpeg,file,im,/grayscale
write_jpeg,'C:\Documents and Settings\Peter Thejll\My Documents\My Pictures\im_gray.jpg',sum,quality=100

help,im
end