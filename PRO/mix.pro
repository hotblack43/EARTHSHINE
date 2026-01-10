im1=readfits('ideal_2456015.7533013_SSA_1p0.fits')
im0=readfits('ideal_2456015.7533013_SSA_0p0.fits')
im1=reform(im1(*,*,0))
albedo=0.3d0
mixed=albedo*im1+(1.0-albedo)*im0
writefits,'mixed_0p3.fits',mixed
end
