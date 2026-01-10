im=readfits('/media/thejll/OLDHD/MOONDROPBOX/JD2456015/2456015.8027195MOON_B_AIR.fits.gz')
avim=avg(im,2)
print,size(im)
l=size(im)
nims=l(3)
sd=fltarr(100)
for i=0,nims-1,1 do begin
resim=im(*,*,i)-avim
sd(i)=stddev(resim(*,15))
endfor
plot,sd
end
