file='met_mlo_insitu_1_obop_minute_2012_01.txt'
str=''
openr,1,file
readf,1,str
readf,1,str
readf,1,str
mlo=''
openw,2,'plotme.dat'
print,'reading ...'
while not eof(1) do begin
;print,'------------------------------------------'
readf,1,str
bits=strsplit(str,' ',/extract)
;print,bits
year=fix(bits(1))
month=fix(bits(2))
day=fix(bits(3))
hour=fix(bits(4))
minute=fix(bits(5))
jd=julday(month,day,year,hour,minute)
wind_dir=double(bits(6))
wind_speed=double(bits(7))
dummy=double(bits(8))
pressure=double(bits(9))
temp_at_2m=double(bits(10))
temp_at_10m=double(bits(11))
temp_at_tower_top=double(bits(12))
Tgradient=float(temp_at_tower_top)-float(temp_at_2m)
rel_hum=double(bits(13))
precip_intensity=double(bits(14))
fmt_str='(f15.7,5(1x,f9.2))'
printf,2,format=fmt_str,jd,rel_hum,Tgradient,wind_speed,temp_at_2m,pressure
;print,format=ftm_str,jd,rel_hum,Tgradient,wind_speed
;print,format=fmt_str,jd,rel_hum,Tgradient,wind_speed
;print,jd,rel_hum,Tgradient,wind_speed
endwhile
close,1
close,2
data=get_data('plotme.dat')
jd=reform(data(0,*))
rel_hum=reform(data(1,*))
Tgradient=reform(data(2,*))
wind_speed=reform(data(3,*))
temp_at_2m=reform(data(4,*))
pressure=reform(data(5,*))
idx=where(rel_hum ne -99)
x=2455945.177d0-min(jd)
!P.MULTI=[0,1,5]
!P.CHARSIZE=1.6
!P.THICK=3
!x.THICK=2
!y.THICK=2
plot,psym=3,title='Met conditions at MLO near Jan 18 2012 (JD 2455945)',ystyle=3,xstyle=3,jd(idx)-min(jd),pressure(idx),xrange=[x-3,x+3],ytitle=' p [hPa]'
plots,[x,x],[!Y.crange],linestyle=2
plot,psym=3,xstyle=3,jd(idx)-min(jd),temp_at_2m(idx),xrange=[x-3,x+3],ytitle='T at 2 m'
plots,[x,x],[!Y.crange],linestyle=2
plot,psym=3,xstyle=3,jd(idx)-min(jd),Tgradient(idx),xrange=[x-3,x+3],ytitle='T vert. gradient'
plots,[x,x],[!Y.crange],linestyle=2
plots,[!X.crange],[0,0],linestyle=2
plot,psym=3,xstyle=3,jd(idx)-min(jd),wind_speed(idx),xrange=[x-3,x+3],ytitle='Wind speed'
plots,[x,x],[!Y.crange],linestyle=2
plot,psym=3,xstyle=3,jd(idx)-min(jd),rel_hum(idx),xrange=[x-3,x+3],ytitle='Relative humidity [%]'
plots,[x,x],[!Y.crange],linestyle=2
end
