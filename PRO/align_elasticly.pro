





stack=readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2456106/2456106.8046883MOON_IRCUT_AIR.fits.gz')
meanim=avg(stack,2)
;
imfix=reform(stack(*,*,55))
help,meanim,imfix
; loop over subimages, align if not pure sky

end
