im=readfits('/data/pth/CUBES/cube_2456046.7711120_IRCUT_.fits')
obs=reform(im(*,*,0))
mask=obs gt 10000
emission=reform(im(*,*,8))
incident=reform(im(*,*,7))
f=1./(1.+cos(emission)/cos(incident))
contour,f,/cell_fill,/isotropic
writefits,'obscorrected.fits',(obs/f)*mask
writefits,'f.fits',f*mask
end
