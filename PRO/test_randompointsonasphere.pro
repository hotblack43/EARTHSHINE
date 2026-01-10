



PRO generaterandompointsonasphere,n,lon,lat
z=randomu(seed,n)*2-1.0	 
phi=randomu(seed,n)*2.*!pi
;
lon=phi/!dtor
lat=asin(z/1.0d0)/!dtor
;
return
end

n=1000
generaterandompointsonasphere,n,lon,lat
map_set,/mollweide
oplot,lon,lat,psym=7
end
