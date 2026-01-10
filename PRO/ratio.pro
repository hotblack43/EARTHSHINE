im=readfits('median_image.fit')
im2=readfits('UNflatdarked_LunarImg_0012.fit')
ratio=smooth(im2,3)/im
surface,ratio,zrange=[-10,10]
device,decomposed=0
loadct,9
contour,ratio,min=0,max=3,/isotropic,/cell_fill

end
