data=get_data('Clementine_minus_Wildey_relativediff.txt')
diff=reform(data(0,*))
lon=reform(data(1,*))
lat=reform(data(2,*))
map_set,/satellite,sat_p=[50,0,0],/isotropic,/advance
contour,diff,lon,lat,/irregular,/overplot,/cell_fill,nlevels=31
contour,diff,lon,lat,/irregular,/overplot,nlevels=11,c_labels=findgen(11)*0+1
print,'Mean rel difference:',mean(diff)
print,' S.D.:              ',stddev(diff)
end
