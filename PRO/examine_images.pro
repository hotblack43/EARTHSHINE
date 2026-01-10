im1=readfits('/data/pth/CUBES/cube_MkIII_onealfa_2456016.8022376_VE1_.fits')
im2=readfits('/data/pth/CUBES/cube_MkIII_onealfa_2456075.7997739_VE1_.fits')
im1=im1(*,*,1)/total(im1(*,*,0))
im2=im2(*,*,1)/total(im2(*,*,0))
plot,im2(*,300),yrange=[0,1e-3]
oplot,im1(*,256),color=fsc_color('red')
end
