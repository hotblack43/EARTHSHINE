map_set,title=str
map_continents,/overplot
map_grid,/overplot
data=get_data('any_sunglint_coords.dat')
jd=reform(data(0,*))
glon=reform(data(1,*))
glat=reform(data(2,*))
illumfr=reform(data(3,*))
;contour,illumfr,glon,glat,/irregular,levels=findgen(11)/10.,c_labels=findgen(11)*0+1
oplot,glon,glat,psym=1,color=fsc_color('red')
idx=where(illumfr lt 0.25)
oplot,glon(idx),glat(idx),psym=2,color=fsc_color('blue')
end


