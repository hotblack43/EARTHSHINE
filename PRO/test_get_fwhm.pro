PRO get_fwhm,im,fwhm
idx=where(im eq max(im))
pos=array_indices(im,idx)
x0=pos(0)
y0=pos(1)
yfit=gauss2dfit(im,a)
print,a
return
end


im=readfits('/data/pth/DATA/ANDOR/OUTDATA/JD2455482/Capella_coadded_iteration_1988.fits')
get_fwhm,im,fwhm
end
