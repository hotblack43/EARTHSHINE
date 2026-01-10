JDstart=double(julday(1,1,2011,0,0,0))
JDstop=double(jdstart+370.)
jdstep=1./24./4.
obsname='lapalma'
openw,5,'p.dat'
for jd=jdstart,jdstop,jdstep do begin
	mphase,jd, k
MOONPOS, jd, alpha, delta, dis
eq2hor, alpha, delta, jd, alt_moon, az, ha,  OBSNAME=obsname
SUNPOS, jd, alpha0, delta0
eq2hor, alpha0, delta0, jd, alt_sun, az, ha,  OBSNAME=obsname
	observe=0
        if (alt_moon ge 30. and alt_sun lt -5 and (k gt 0.15 and k lt 0.85)) then observe=1
	if (observe eq 1) then printf,5,format='(f20.5,3(1x,f8.4))', jd,alt_moon,alt_sun,k
	if (observe eq 1) then print,format='(f20.5,3(1x,f8.4))', jd,alt_moon,alt_sun,k
endfor
close,5
data=get_data('p.dat')
jd=reform(data(0,*)) 
alt_moon=reform(data(1,*))
alt_sun=reform(data(2,*))
illfrac=reform(data(3,*))
n=n_elements(jd)
integer_jd=long(jd)
uniq_ijd=integer_jd(uniq(integer_jd))
n=n_elements(uniq_ijd)
openw,6,'start_stop_observing_times.dat'
fmt='(3(1x,f20.7))'
for i=0,n-1,1 do begin
idx=where(long(jd) eq uniq_ijd(i))
if (idx(0) eq -1) then stop
start=min(jd(idx))
stop=max(jd(idx))
print,format=fmt,uniq_ijd(i),start,stop
printf,6,format=fmt,uniq_ijd(i),start,stop
endfor
close,6
end
