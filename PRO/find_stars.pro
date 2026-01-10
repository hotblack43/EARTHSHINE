file='ANDOR/Capella_coadded_iteration_2001.fits'
im=readfits(file)
yfit=GAUSS2DFIT(im,a)
print,a
yfit=MPFIT2DPEAK(im,a)
print,a
end
