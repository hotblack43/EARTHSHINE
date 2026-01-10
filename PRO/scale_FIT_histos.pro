im1=readfits('Moon_simulated_MatlabMap.FIT')
im2=1.3*readfits('Moon_simulated_basemap.FIT')
idx=where(im1 ne 0)
h1=histogram(im1(idx))
idx=where(im2 ne 0)
h2=histogram(im2(idx))
plot_oo,h1,xrange=[0.5,65000],yrange=[1e-2,1e6]
oplot,h2,linestyle=2
window,0
contour,im1,/cell_fill,levels=findgen(21)/11.
window,2
contour,im2,/cell_fill,levels=findgen(21)/11.
end

