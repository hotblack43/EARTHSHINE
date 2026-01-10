file='BB9.dat'
data=get_data(file)
tstep=reform(data(0,*))
time=reform(data(1,*))
lat=reform(data(2,*))
lon=reform(data(3,*))
num=reform(data(4,*))
numbers=num(sort(num))
uniq_numbers=numbers(uniq(numbers))
idx=where(num eq 7663)
plot,lon(idx),lat(idx),xstyle=1,ystyle=1
xyouts,lon(idx),lat(idx),string(tstep(idx))
file='7663.dat'
data=get_data(file)
lon_7663=reform(data(1,*))
lat_7663=reform(data(2,*))
oplot,lon_7663,lat_7663,psym=4
end