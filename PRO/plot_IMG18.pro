bias=double(readfits('PSF/IMG18.FIT'))
im=double(readfits('PSF/IMG18.FITs'))
im=im-bias*0.92
 l=size(im,/dimensions)
 Nx=l(0)
 Ny=l(1)
 XR = indgen(Nx)
 YC = indgen(Ny)
 X = double(XR # (YC*0 + 1))        ;     eqn. 1
 Y = double((XR*0 + 1) # YC)        ;     eqn. 2
 r=sqrt((x-654)^2+(y-532)^2)
plot_oo,r,im,psym=3,xrange=[0.1,1e2],yrange=[1e2,1e5]
oplot,r,50000/r^1.8
w=50
subim=im(654-w:654+w,532-w:532+w)
mask=subim*0+1
idx=where(subim lt 0)
mask(idx)=0
fita=[1,1,1,1,1,1,1]
a=[1,1e5,2,2,w,w,0.0]
surf=gauss2dfit((subim),a,/tilt,mask=mask,fita=fita) 
end

