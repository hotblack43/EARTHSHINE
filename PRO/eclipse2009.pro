file='eclipse31122009.jpg'
read_jpeg,file,im
imR=reform(im(0,*,*))
imG=reform(im(1,*,*))
imB=reform(im(2,*,*))
help
contour,imG,levels=[30,40,50,100,150,200,250],/isotropic
end