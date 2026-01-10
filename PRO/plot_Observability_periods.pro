f='Start_Stop_times.dat'
data=get_data(f)
sta=reform(data(0,*))
sto=reform(data(1,*))
plot,sta,(sto-sta)*24.
idx=where(sto-sta ge 1)
if (idx(0) ne -1) then print,'Something wrong here : ',sta(idx)
; go and check monpos and sunpos for each minute inside the tow limits
obsname='cfht'
observatory, obsname, obs
observatory_longitude = obs.longitude
observatory_latitude  = obs.latitude
observatory_altitude  = obs.altitude
np=n_elements(sta)
for ip=0,np-1,1 do begin
openw,44,'plotting.dat'
for xJD=sta(ip),sto(ip),1./24./60. do begin
moonpos, xJD, RAmoon, DECmoon, Dem
eq2hor, RAmoon, DECmoon, xJD, moon_altitude, az, ha, LAT=observatory_latitude , LON=observatory_longitude ,  $
        PRECESS_= 1, NUTATE_= 1, REFRACT_= 1, ABERRATION_= 1, ALTITUDE=observatory_altitude
sunpos, xJD, RAsun, DECsun
eq2hor, RAsun, DECsun, xJD, sun_altitude, az, ha, LAT=observatory_latitude , LON=observatory_longitude , OBSNAME=obsname , $
        PRECESS_= 1, NUTATE_= 1, REFRACT_= 1, ABERRATION_= 1, ALTITUDE=observatory_altitude
printf,44,format='(f20.8,2(1x,f9.3))',xJD,sun_altitude,moon_altitude
endfor
close,44
data=get_data('plotting.dat')
xJD=reform(data(0,*))
salt=reform(data(1,*))
malt=reform(data(2,*))
plot,xJD-2455550.0d0,salt,psym=7,thick=3,xtitle='Days since 2455550.0d0',yrange=[min([salt,malt]),max([salt,malt])]
oplot,xJD-2455550.0d0,malt,psym=3,thick=3
plots,[!x.crange],[0,0],color=fsc_color('yellow')
plots,[!x.crange],[30,30],color=fsc_color('blue')
endfor
end
