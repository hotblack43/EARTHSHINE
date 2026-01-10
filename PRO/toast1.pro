path='C:\Documents and Settings\Peter Thejll\My Documents\My Pictures\2007_07_14\'
read_jpeg,path+'IMG_0120.JPG',im1
read_jpeg,path+'IMG_0119.JPG',im2
l=size(im1,/dimensions)
im1R=reform(im1(0,*,*))
im2R=reform(im2(0,*,*))
im1G=reform(im1(1,*,*))
im2G=reform(im2(1,*,*))
im1B=reform(im1(2,*,*))
im2B=reform(im2(2,*,*))
im1R=(im1R/mean(im1R) )
im1G=(im1G/mean(im1G))
im1B=(im1B/mean(im1B))
im2R=(im2R/mean(im2R) )
im2G=(im2G/mean(im2G))
im2B=(im2B/mean(im2B))
BW=total(im1,1)
BW2=im1
idx=where(im1R/im2R gt 5)
BW2(0,idx)=255
display,BW2
end