file='meanpic.fit'
im=readfits(file)
print,'Read a big file ...'
l=size(im,/dimensions)
im=rebin(im,l/4.) & l=size(im,/dimensions)
lon=findgen(l(0))/(l(0))*360. ; 2048)/2047.*360.
lat=findgen(l(1))/(l(1)-1)*180.-90. ; 1024)/1023.*180.-90.
set_plot,'win
MAP_SET,  0, 0, /ISOTROPIC, $
   /HORIZON, /GRID, /CONTINENTS
im=bytscl(im)
contour,im,lon,lat,/OVERPLOT,levels=[0,10,50,100,200,255]
end