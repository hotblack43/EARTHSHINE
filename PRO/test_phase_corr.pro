im=readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2456015/2456015.7265996MOON_B_AIR.fits')
l=size(im,/dimensions)
n=l(2)
hann=HANNING( l(0),l(1), ALPHA=0.54, /DOUBLE)
im1=hann*reform(im(*,*,0))*1.0d0
f1=fft(im1,-1,/double)
for i=1,n-1,1 do begin
im2=hann*reform(im(*,*,i))*1.0d0
window,2
tvscl,im2
f2=fft(im2,-1,/double)
ph=(f1*conj(f2)/(f2*conj(f2)))
ph=float(ph)
invph=fft(ph,1,/double)
invph=sqrt(float(invph*conj(invph)))
;contour,ph,/isotropic,xstyle=3,ystyle=3
window,1
x=shift(invph,256,256)
surface,x(250:260,250:260)
idx=where(invph eq max(invph))
coord=array_indices(invph,idx)
print,coord,'max:',max(invph)
endfor
end
