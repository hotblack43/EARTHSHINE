im1=readfits('image_1.fit')
window,0
idx=where(im1 gt 40)
jdx=where(im1 le 40)
im1(jdx)=0.0
histo, 2.3*im1(idx),0,65000,1000
im1=2.3*im1
im2=readfits('image_2.fit')

window,1
histo, im2,0,1500,10
idx=where(im2 gt 1000)
jdx=where(im2 le 1000)
histo, im2(idx),0,65000,100
im2(jdx)=0.0
window,0
tvscl,im1
histo,im1,1,50000,500
window,1
tvscl,im2
histo,im2,1,50000,500
end