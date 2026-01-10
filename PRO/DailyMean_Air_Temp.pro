PRO get_idxs,lon,lat,statlon,statlat,lonidx,latidx,level
d=abs(lon-statlon)
lonidx=where(d eq min(d))
d=abs(lat-statlat)
latidx=where(d eq min(d))
lonidx=lonidx(0)
latidx=latidx(0)
print,'IN:',statlon,statlat,' Out: ',lon(lonidx),lat(latidx)
return
end
PRO plot_tavg,data,level,lonidx,latidx,title,p_station
idx_p_higher=max(where(level gt p_station))	; index of level with p higher than p_station
idx_p_lower=min(where(level le p_station))	; index of level with p lower than p_station
t3=data(lonidx,latidx,idx_p_higher,*)
t4=data(lonidx,latidx,4,*)
t5=data(lonidx,latidx,idx_p_lower,*)
phigher=level(idx_p_higher)
plower=level(idx_p_lower)
Thigher=data(lonidx,latidx,idx_p_higher,*)
Tlower=data(lonidx,latidx,idx_p_lower,*)
fraction=(p_station-plower)/(phigher-plower)
l=size(data,/dimensions)
Tactual=Tlower+fraction*(Thigher-Tlower)
!P.Charsize=2
plot,Tactual,yrange=[min([t3,t4,t5]),max([t3,t4,t5])],$
xrange=[0,364],xtitle='Day of year',ytitle='Air temperature [deg C]',xstyle=1,$
title=title
print,title
print,'Number of days below 0 : ',n_elements(where(Tactual lt 0))
print,'Number of days below -10 : ',n_elements(where(Tactual lt -10))
oplot,t3
oplot,t5
oplot,Tactual,thick=2,color=fsc_color('red')
plots,[!X.crange],[0,0],linestyle=3
return
end

; Restore data of daily mean NCEP temperatures
restore,filename='stack.sav'
data=stack
;
!P.MULTI=[0,1,2]
p_station=602.
title='Yangbajing site (90E, 30 N)'
get_idxs,lon,lat,90,30,lonidx,latidx,level
plot_tavg,data,level,lonidx,latidx,title,p_station
;
p_station=750.
title='TUG site (30E 37N)'
get_idxs,lon,lat,30,37,lonidx,latidx,level
plot_tavg,data,level,lonidx,latidx,title,p_station
;
p_station=775.
title='La Palma (18W 29N)'
get_idxs,lon,lat,360.-17.6,28.75,lonidx,latidx,level
plot_tavg,data,level,lonidx,latidx,title,p_station
end
