function imagefocusnumber,im
;value=total(sobel(im)/total(im))
value=total(abs(laplacian(im))/total(im))
return,value
end

im_in=readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2456074/2456074.7857900MOON_VE2_AIR.fits.gz')
l=size(im_in,/dimensions)
nims=l(2)
ntries=30
for i=0,nims-1,1 do begin
im=im_in(*,*,i)
openw,12,'focus.dat'
for itry=0,ntries-1,1 do begin
im=smooth(im,3)
printf,12,itry,imagefocusnumber(im)
endfor
close,12
data=get_data('focus.dat')
if (i eq 0) then plot,xstyle=3,ystyle=3,data(0,*),data(1,*),xtitle='Smooth #',ytitle='Focus'
if (i gt 0) then oplot,data(0,*),data(1,*)
endfor
end
