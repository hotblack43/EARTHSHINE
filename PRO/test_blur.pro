im1=readfits('/media/thejll/OLDHD/NGC6633/2456104.9668342NGC6633_B_AIR.fits')
im2=readfits('/media/thejll/OLDHD/NGC6633/2456110.0440008NGC6633_B_AIR.fits')
im2=avg(im2,2)
im2=im2/total(im2)*total(im1)
;
idx=where(im1 eq max(im1))
coords=array_indices(im1,idx)
plot_io,im1(*,coords(1)),xrange=[coords(0),coords(0)+30]
idx=where(im2 eq max(im2))
coords2=array_indices(im2,idx)
im2=shift_sub(im2,coords(0)-coords2(0)+0.75,0)
oplot,im2(*,coords2(1)),color=fsc_color('red')
end
