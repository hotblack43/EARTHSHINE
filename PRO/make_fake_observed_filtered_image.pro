file='good_observed.fit'
im=readfits(file)
contour,im,xstyle=1,ystyle=1,/cell_fill,nlevels=11
cursor,a,b
print,a,b
factor=50.0d0
im(*,0:b)=im(*,0:b)/factor
im=long(im/max(im)*40000.0)
l=size(im,/dimensions)
for i=0,l(0)-1,1 do begin
for j=0,l(1)-1,1 do begin
if (im(i,j) ne 0) then im(i,j)=randomn(seed,poisson=im(i,j))
endfor
endfor
contour,im,xstyle=1,ystyle=1,/cell_fill,nlevels=11
writefits,'fakefiltered_im.fit',float(im)
end

