PRO get_moon_rise_set,jd,jd_rise,jd_set
MOONPHASE,jd,phase_angle_M,alt_moon,alt_sun
moon_sign=alt_moon/abs(alt_moon)
moon_lim=0.0
step=1./24./12.	; step is 5 minutes
;--------------------------------------------------------------------------------
altitude=911
time=911
for ijd=jd-0.6,jd+0.6,step do begin
	MOONPHASE,ijd,phase_angle_M,alt_moon,alt_sun
	altitude=[altitude,alt_moon]
	time=[time,ijd]
endfor
idx=where(altitude ne 911)
altitude=altitude(idx)
time=time(idx)
sign=deriv(altitude)/abs(deriv(altitude))
for i=1,n_elements(altitude)-2,1 do begin
	if (sign(i-1) gt 0 and sign(i+1) lt 0) then jd_set=time(i)
	if (sign(i-1) lt 0 and sign(i+1) gt 0) then jd_rise=time(i)
endfor
return
end
