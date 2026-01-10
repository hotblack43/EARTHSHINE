!P.MULTI=[0,3,4]
file='Very_loong_list_of_Moon_data.txt'
file='dat.dat'
data=get_data(file)
az=reform(data(10,*))
station_lat=reform(data(11,*))
uniquelats=station_lat(uniq(station_lat(sort(station_lat))))
print,uniquelats
n_uniq=n_elements(uniquelats)
for id=0,n_uniq-1,1 do begin
idx=where(station_lat eq uniquelats(id))
histo,az(idx),0,360,3.*3.6,xtitle='Lunar azimuth',ytitle='frequency',title=strcompress('At '+string(fix(uniquelats(id)))+' degees latitude.')
endfor
end

