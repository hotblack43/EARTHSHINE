













im1=readfits('/data/pth/UNIVERSALSETOFMODELS/newH-63_HIRESscaled_LA/convolved_albedo0p31/halo_model_ideal_2456016.8337509_SSA_.fits',hdr1)
im2=readfits('/data/pth/DARKCURRENTREDUCED/SELECTED_1/2456016.8337509MOON_VE1_AIR_DCR.fits',hdr2)
help,im1,im2
im1=im1(*,*,0)
im2=shift(reverse(im2,2),256-311.089850000,249.973420000-256)
;contour,[hist_equal(im1),hist_equal(im2)],/cell_fill,/isotropic
writefits,'im1.fits',im1
writefits,'im2.fits',im2
im1=im1/total(im1)
im2=im2/total(im2)
!P.charsize=2
!P.thick=3
!P.charthick=2
plot,im1(*,256),/ylog,xstyle=3
oplot,im2(*,256),color=fsc_color('red')
end

