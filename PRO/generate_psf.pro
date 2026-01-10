im=readfits('~/Desktop/ASTRO/MOON/May27/obsrun1/IMG164.FIT')
im=im*0.0
l=size(im,/dimensions)
im(l(0)/2,l(1)/2)=1.0
rescale=8*2
im=rebin(im,l(0)/rescale,l(1)/rescale)
l=size(im,/dimensions)
print,l
nrows=l(1)
ncols=l(0)
rayleigh=im*0
factor=0.5/float(l(1))	; image scale - degrees/pixel
for irow=0L,nrows-1,1 do begin
print,irow
for icol=0L,ncols-1,1 do begin
intensity=im(icol,irow)
for j=0L,nrows-1,1 do begin
for i=0L,ncols-1,1 do begin
dist=sqrt((irow-j)^2+(icol-i)^2)
angle=dist*factor*!dtor
if (finite(angle) eq 0) then stop
rayleigh(i,j)=rayleigh(i,j)+intensity*(1.+cos(angle)^2)
endfor
endfor
tvscl,rebin(rayleigh,l(0)*rescale/2,l(1)*rescale/2)
endfor
endfor
end
