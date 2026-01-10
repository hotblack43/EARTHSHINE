im=readfits('veryspcialimageSSA0p300.fits')
n=512
nblocks=8
step=n/nblocks
for i=0,nblocks-1,1 do begin
x=i*step
im(x,0:n-1)=max(im)
endfor
for j=0,nblocks-1,1 do begin
y=j*step
im(0:n-1,y)=max(im)
endfor
contour,hist_equal(im),/isotropic,xstyle=3,ystyle=3
ic=0
for i=0,nblocks-1,1 do begin
for j=0,nblocks-1,1 do begin
ix=-step/2.+i*step
iy=step/2.+j*step
print,ix,iy
xyouts,ix,iy,string(ic+1)
ic=ic+1
endfor
endfor
end
