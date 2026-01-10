spawn,'sort results_vissibility.dat | uniq -c > count.dat'
file='count.dat'
data=get_data(file)
count=reform(data(0,*))
lon=reform(data(1,*))
lat=reform(data(2,*))
map_set
contour,count,lon,lat,/overplot,/irregular,/cell_fill,nlevels=11
contour,count,lon,lat,/overplot,/irregular,nlevels=11,$
c_labels=indgen(11)*0+1
map_continents,/overplot
end
