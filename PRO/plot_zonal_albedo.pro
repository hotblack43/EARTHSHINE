file='zonal_albedo.dat'
data=get_data(file)
lat=reform(data(0,*))
z=reform(data(1,*))
idx=where(lat gt -74 and lat lt 74)
lat=lat(idx)
z=z(idx)/max(z)
z=z/mean(z)*0.3
plot,lat,z,xtitle='Latitude',thick=3,ytitle='Annual mean zonal albedo',charsize=2,yrange=[0,0.9]
;.... plot canonical values
file='zonal_albedo_canon.dat'
data=get_data(file)
lat1=reform(data(0,*))
lat2=reform(data(1,*))
albedo=reform(data(2,*))
alb_lo=reform(data(3,*))
alb_hi=reform(data(4,*))
oplot,(lat1+lat2)/2.,albedo
oplot,(lat1+lat2)/2.,alb_lo,linestyle=2
oplot,(lat1+lat2)/2.,alb_hi,linestyle=2
end
