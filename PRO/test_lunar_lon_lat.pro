for imo=1,12,1 do begin
openw,33,'p.dat'
for JD=julday(imo,1,2010,17,52,0),julday(imo,31,2010,16,0,0),1.0d0/24.0d0/10. do begin
lunar_lon_lat,JD,lon,lat
MOONPHASE,jd,phase_angle_M
printf,33,jd,lon,lat,phase_angle_M
endfor
close,33
data=get_data('p.dat')
jd=reform(data(0,*))
lon=reform(data(1,*))
lat=reform(data(2,*))
phase=reform(data(3,*))
!P.MULTI=[0,1,2]
idx=where((phase lt 140 and phase gt 40) or (phase gt -140 and phase lt -40))
map_set
oplot,lon(idx),lat(idx),psym=3
map_continents,/overplot
plot,phase(idx),lat(idx),title=string(imo),psym=3
endfor
end