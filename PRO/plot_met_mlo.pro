; get the list of JDs and alfas determined by fitting
data=get_data('jd_vs_alfa_V.dat')
data=get_data('jd_vs_alfa_VE2.dat')
jdobs=reform(data(0,*))
alfa=reform(data(1,*))
n=n_elements(jdobs)
; get all the met data from MLO for 2011+2012:
print,'reading ...'
restore,'/data/pth/MLO_MET_DATA/idlsave.dat'
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
; loop over all observations and extract plots for each one
openw,14,'Tgradient_vs_alfa.dat'
for i=0,n-1,1 do begin
x=jdobs(i)-min(jd)
!P.MULTI=[0,1,5]
!P.CHARSIZE=1.6
!P.THICK=3
!x.THICK=2
!y.THICK=2
plot,psym=3,title='Met conditions at MLO near Jan 18 2012 (JD 2455945)',ystyle=3,xstyle=3,jd-min(jd),pressure,xrange=[x-3,x+3],ytitle=' p [hPa]'
plots,[x,x],[!Y.crange],linestyle=2
plot,psym=3,ystyle=3,xstyle=3,jd-min(jd),temp_at_2m,xrange=[x-3,x+3],ytitle='T at 2 m'
plots,[x,x],[!Y.crange],linestyle=2
plot,psym=3,ystyle=3,xstyle=3,jd-min(jd),Tgradient,xrange=[x-3,x+3],ytitle='T vert. gradient'
plots,[x,x],[!Y.crange],linestyle=2
plots,[!X.crange],[0,0],linestyle=2
plot,psym=3,ystyle=3,xstyle=3,jd-min(jd),wind_speed,xrange=[x-3,x+3],ytitle='Wind speed'
plots,[x,x],[!Y.crange],linestyle=2
plot,psym=3,ystyle=3,xstyle=3,jd-min(jd),rel_hum,xrange=[x-3,x+3],ytitle='Relative humidity [%]'
plots,[x,x],[!Y.crange],linestyle=2
printf,14,format='(f15.7,5(1x,f9.3))',jdobs(i),alfa(i),interpol(Tgradient,jd,jdobs(i)),interpol(rel_hum,jd,jdobs(i)),interpol(pressure,jd,jdobs(i)),interpol(wind_speed,jd,jdobs(i))
print,format='(f15.7,5(1x,f9.3))',jdobs(i),alfa(i),interpol(Tgradient,jd,jdobs(i)),interpol(rel_hum,jd,jdobs(i)),interpol(pressure,jd,jdobs(i)),interpol(wind_speed,jd,jdobs(i))
endfor
close,14
end
