; Get the Clementine map written as ascii text
data=get_data('Clem.txt')
Clem=reform(data(0,*))
lonClem=reform(data(1,*))
latClem=reform(data(2,*))
; Get the Wildey map written as ascii text
data=get_data('Wild.txt')
Wild=reform(data(0,*))
lonWild=reform(data(1,*))
latWild=reform(data(2,*))
;
!P.MULTI=[0,1,2]
dis=384400.0    ; mean Moon-Earth distance in km;
distance=dis/6371.      ; in units of earth radii
tit_str='Clementine albedo map'
map_set,0,0,0,/satellite,sat_p=[distance,0,0],title=tit_str,/isotropic
contour,Clem,lonClem,latClem,/irregular,/cell_fill,nlevels=101,/overplot
tit_str='Wildey albedo map'
map_set,0,0,0,/satellite,sat_p=[distance,0,0],title=tit_str,/isotropic,/advance
contour,Wild,-lonWild,latWild,/irregular,/cell_fill,nlevels=101,/overplot
end
