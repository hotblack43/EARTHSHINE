path='C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\'
read_jpeg,path+'webcam_dark_sky.jpg',im1
tvscl,im1
im1=total(im1,1)/3.
print,'SD im1:',stddev(im1)
read_jpeg,path+'webcam_dark_sky2.jpg',im2
im2=total(im2,1) /3.
print,'SD im2:',stddev(im2)
read_jpeg,path+'webcam_dark_sky3.jpg',im3
im3=total(im3,1) /3.
print,'SD im3:',stddev(im3)
dark=(im1+im2+im3)/3.
darklevel=mean(dark)
print,'Dark level=',darklevel
read_jpeg,path+'webcam_image3.jpg',image
image=total(image,1)/3.
tvscl,image
writefits,'image.fit',image
window,2
print,'mean image:',mean(image)
factor=-.10
restored=image-factor*(dark)+factor*darklevel
tvscl,restored
print,'Dark removed image + dark level:',mean(restored)
print,'SD im:',stddev(image)
print,'SD im - dark:',stddev(image-factor*dark)
writefits,'fixed.fit',restored
window,3
!P.MULTI=[0,1,3]
help,image,restored
plot,total(image,2),title='Original image',xstyle=1,ystyle=1
plot,total(dark,2),title='Dark image',xstyle=1,ystyle=1
plot,total(restored,2),title='Restored image',xstyle=1,ystyle=1
end