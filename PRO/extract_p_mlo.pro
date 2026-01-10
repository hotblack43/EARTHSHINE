pro extract_p_mlo,jd_want,p_out
common flags_meteoro,mlo_flag,jd,pressure
if (mlo_flag ne 314) then begin
; INPUT	- jd JULIAN DAY with fractions
; get all the met data from MLO for 2011+2012:
print,'reading ...'
restore,'/media/thejll/OLDHD/idlsave.dat'
; get rid of flagged observations
temp_at_2m=reform(data(10,*))
temp_at_tower_top=reform(data(12,*))
rel_hum=reform(data(13,*))
pressure=reform(data(9,*))
idx=where(pressure gt 100 and rel_hum gt -10 and temp_at_2m gt -90 and temp_at_tower_top gt -90)
data=data(*,idx)
;
year=reform(data(1,*))
month=reform(data(2,*))
day=reform(data(3,*))
hour=reform(data(4,*))
minute=reform(data(5,*))
jd=julday(month,day,year,hour,minute)
wind_dir=reform(data(6,*))
wind_speed=reform(data(7,*))
dummy=reform(data(8,*))
pressure=reform(data(9,*))
temp_at_2m=reform(data(10,*))
temp_at_10m=reform(data(11,*))
temp_at_tower_top=reform(data(12,*))
Tgradient=float(temp_at_tower_top)-float(temp_at_2m)
rel_hum=reform(data(13,*))
precip_intensity=reform(data(14,*))
mlo_flag=314
endif
if (jd_want lt min(jd) or jd_want gt max(jd)) then stop
p_out=interpol(pressure,jd,jd_want)
return
end
