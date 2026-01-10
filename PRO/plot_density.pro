file='glintpoint.dat'
data=get_data(file)
print,'Got data'
lon=reform(data(0,*))
lat=reform(data(1,*))
dens=HIST_2d(lon,lat,bin1=10,bin2=10,min1=-180,max1=180,min2=-90,max2=90)
help
maplon=indgen(37)*10-180
maplat=indgen(19)*10-90
contour,dens,maplon,maplat,charsize=2,/cell_fill,nlevels=100
end

