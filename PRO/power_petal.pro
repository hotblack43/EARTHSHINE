read_png,'200px-Starshade.svg.png',im
im=reform(im(3,*,*))
im=im(0:199,0:199)
idx=where(im ne 0)
im(idx)=1
meshgrid,200,200,x,y
radius=sqrt((x-100)^2+(y-100)^2)
idx=where(radius lt 60)
disc=im*0
disc(idx)=1
tvscl,[im,disc]
;
z=fft(im,-1,/double)
zz=float(z*conj(z))
y=fft(disc,-1,/double)
yy=float(y*conj(y))
yy=shift(yy,[100,100])
zz=shift(zz,[100,100])
zz=zz/max(zz)
yy=yy/max(yy)
surface,[rebin(zz,50,50),rebin(yy,50,50)],/zlog,charsize=2,zrange=[1e-10,1]
end
