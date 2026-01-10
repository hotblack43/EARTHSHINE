im=readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455469/LundMod-KEDF375-R1-1.fits')
dark=readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455641/meanhalfmedian_dark.fits')
im=im-dark
im(0:221,*)=im(0:221,*)/10^2.25
line=avg(im(*,0:10),1)
;line=avg(im(*,250:260),1)
plot,line
;plot_io,line
end

