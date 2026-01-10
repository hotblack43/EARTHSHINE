FUNCTION sensitivity,JD
; pretend the CCD sensitivity has a linear drift with time
common model,JD_epoch,a,b,period,slow_amplitude,annual_amplitude,trend,k0
sensitivity=a+b*(JD-JD_epoch)
return,sensitivity
end

FUNCTION extinction,jd
; time variable extinction coefficient
common model,JD_epoch,a,b,period,slow_amplitude,annual_amplitude,trend,k0
k=k0+trend*(jd-jd_epoch)/365.25d0+annual_amplitude*sin(jd/365.25*!pi*2.)+slow_amplitude*sin(jd/period*!pi*2.)
return,k
end

PRO go_perform_multiannual_analysis,exp_number,text_str,b,trend
common most,switch_linfit,ar1_noise_flag,if_want_random_ra,if_want_secant_airmass,n_min
;common model,JD_epoch,b,period,slow_amplitude,annual_amplitude,trend
; Plot drift in m0 over the years

!P.MULTI=[0,1,2]
data=get_data('m0_annual.dat')
jd=reform(data(0,*))
m0=reform(data(1,*))
caldat,jd,mm,dd,yy,hour,min,sec
fracyear=yy+(mm-1)/12.+(dd-1)/365.25+hour/24./365.25
xx=fracyear
xx=[transpose(xx),transpose(sin(xx*!pi*2.))]
plot,fracyear,m0,xtitle='Year',ytitle='m!d0!n',charsize=2,ystyle=1,psym=7
	res=regress(xx,m0,yfit=yhat2,/double,sigma=sigs,const=const)
	res=[const,transpose(res)]
	sigs=[0.0,sigs]
oplot,fracyear,yhat2,thick=3
err=sqrt(sigs(0)^2+(fracyear*sigs(1))^2)
oplot,fracyear,yhat2+err
oplot,fracyear,yhat2-err
; summarize and print out
print,'============================================================'
print,'Imposed flux sensitivity drift in system:',b*365.25,' per year'
print,format='(a,f10.6,a,f10.6)','Deduced magnitude sensitivity drift     :',res(1),' +/- ',sigs(1)
print,format='(a,f10.6,a,f10.6,a)','or, in terms of flux                    :',res(1)/(-1.0854),' +/- ',sigs(1)/(-1.0854),' per year'
Z=(abs(b*365.25)-abs(res(1)/(-1.0854)))/abs(sigs(1)/(-1.0854))
print,' so Z score is:',Z
if (n_elements(res) eq 3) then begin
print,' also, there is the fitted sinusoid:',res(2),' +/- ',sigs(2)
endif
; make latex table output: imposed sens drift, measured sens drift, Z score,text
printf,66,format='(i2,a,f10.6,a,f10.6,a,f10.6,a,f5.2,a,a,a)',exp_number,'&',b*365.25,'&',res(1)/(-1.0854),' +/- ',abs(sigs(1)/(-1.0854)),'&',abs(Z),'&',text_str,'\\'
print,format='(i2,a,f10.6,a,f10.6,a,f10.6,a,f5.2,a,a,a)',exp_number,'&',b*365.25,'&',res(1)/(-1.0854),' +/- ',abs(sigs(1)/(-1.0854)),'&',abs(Z),'&',text_str,'\\'

; Plot drift in k over the years
data=get_data('k_annual.dat')
jd=reform(data(0,*))
caldat,jd,mm,dd,year2
fracyear2=year2+(mm-1)/12.+(dd-1)/365.25
k=reform(data(1,*))
plot,fracyear2,k,xtitle='Year',ytitle='k',charsize=2,ystyle=1,title='Thin: determined, thick: actual',psym=-7
xx=fracyear2
xx=[transpose(xx),transpose(sin(xx*!pi*2.))]
	res2=regress(xx,k,/double,sigma=sigs2,const=const,yfit=yhat2)
	res2=[const,transpose(res2)]
	sigs2=[0.0,sigs2]
oplot,fracyear2,yhat2,thick=3
; summarize and print out

print,'------------------------------------------------------------'
print,'Imposed extinction drift :',trend,' mags per year.'
print,format='(a,f10.6,a,f10.6)','Deduced drift on extinction:',res2(1),' +/- ',sigs2(1),' mags per year.'
Z=(abs(res2(1))-abs(trend))/abs(sigs2(1))
print,' so Z score is:',Z
if (n_elements(res2) eq 3) then begin
print,format='(a,f10.6,a,f10.6)',' also, there is the fitted sinusoid:',res2(2),' +/- ',sigs2(2)
endif
; make latex table output: imposed ext drift, measured ext drift, Z score,text
printf,66,format='(a,a,f10.6,a,f10.6,a,f10.6,a,f5.2,a,a,a)',' ','&',trend,'&',res2(1),' +/- ',abs(sigs2(1)),'&',abs(Z),'&',' ','\\ \hline'
print,format='(a,a,f10.6,a,f10.6,a,f10.6,a,f5.2,a,a,a)',' ','&',trend,'&',res2(1),' +/- ',abs(sigs2(1)),'&',abs(Z),'&',' ','\\ \hline'

print,'============================================================'
openw,11,'assembled_results.dat',/append
printf,11,format='(6(1x,f12.7))',b*365.25,res(1)/(-1.0854),sigs(1)/(-1.0854),trend,res2(1),sigs2(1)
return
end

FUNCTION fetch_AR1_series,n
; will generate an AR1 series as long as n
series=randomn(seed,n)
lag_1=0.7
imethod=1
series=pseudo_t_guarantee_ac1(series,lag_1,imethod,seed)
get_lun,unit
openw,unit,'AR1_series.dat'
for i=0,n-1,1 do begin
printf,unit,i,series(i)
endfor
close,unit
free_lun,unit
return,series
end
FUNCTION get_secant_airmass,jd,ra,dec,lat,lon,wave,pressure,temp,relhum
; calculates the very simple airmass formula am=1/cos(Z)
; ra,dec	: stars true position in DEGREES
; lat,lon	: observatory latitude and longitude in DEGREES (west is neg)
;----------------------------------------------------------------------------
; first find the true zenith distance for the object
eq2hor, ra, dec, jd, alt, az, LAT=lat, LON=lon
; then find true zenith distance
z=90.-alt
; then apply refraction correction to the true zenith distance to get the apparent zenith distance
zref=refrac(z*!dtor,wave,pressure,temp,relhum)
; then calculate the simple airmass
get_secant_airmass=1./cos(zref)
return,get_secant_airmass
end

PRO generate_observing_times,startyear,stopyear,n_each_night,n_nights,list
; will generate a list of bunched observing times - bunched
; so that each night has many observations but then there
; may be several nights without any
;
; find the nights wehn observations are performed
jd=randomu(seed,n_nights)*(julday(1,1,stopyear)-julday(1,1,startyear))+julday(1,1,startyear)
jd=jd(sort(jd))
jd=jd(uniq(jd))	; just the unique nights
; put all hours on each of those nights
for i=0,n_elements(jd)-1,1 do begin
; find the local times at which observations are performed each night
	hours=randomu(seed,n_each_night)*24.0
	if (i eq 0) then list=(jd(0)+hours/24.0d0)
	if (i gt 0) then list=[[list],[(jd(i)+hours/24.0d0) ]]
endfor
l=size(list,/dimensions)
n_nights=l(1)
return
end

;============= MAIN PROGRAMME ====================
common model,JD_epoch,a,b,period,slow_amplitude,annual_amplitude,trend,k0
common numbers,njd
common most,switch_linfit,ar1_noise_flag,if_want_random_ra,if_want_secant_airmass,n_min
switch_linfit=1	; =1 use linfit not =1 use CO
ar1_noise_flag=0	; if =1 then use AR1 noise, not randomn noise
if_want_random_ra=0	; if you want randomized RAs
if_want_secant_airmass=1	; if you want the airmass (whether set or randomized)
												; calculated from the simple 1/cos(Z) formula
												exp_number='8'
												text_str='Trends in both. Ann. cycle in Ext. Set RA. Secant.'
; Sensitivity evolution parameters:
a=1.0d0

b=0.0
b=-0.01/365.25	; % drift per year starting year JD_epoch

; Extinction evolution parameters
JD_epoch=julday(1,1,2005)
k0=0.10d0	; background extinction
period=11.3*365.25d0	; 'slow' period in days
slow_amplitude=0.01
slow_amplitude=0.0


annual_amplitude=0.03
annual_amplitude=0.0

trend=0.0
trend=0.02d0	; mags per year
;------------------------------------
!P.MULTI=[0,1,1]
openw,23,'all_observed_data.dat'
openw,13,'k_annual.dat'
openw,14,'m0_annual.dat'
openw,66,'tabels.tex'
ra_HRS=13.0d0	; RA in hrs
ra=ra_HRS*15.0d0*!dtor	; ra in radians
dec_degs=65.0d0	; Decl in degrees
dec=dec_degs*!dtor	; Decl in radians
lat_deg=55.0d0	; latitud eof observatory in degrees
lat=lat_deg*!dtor	; latitude in radians
lon_deg=12.0d0	; longitude in degrees
lon=lon_deg*!dtor	; longitude in radians
wave=0.56d0	; wavelength in microns
pressure=760.0d0	; mm Hg
temp=11.0d0
relhum=0.0d0
mag_0=12.0d0
am_max=2.0d0
n_min=19	; minimum number of regressor points
min_span=0.5	; minimum span in airmass
startyear=2005
stopyear=2010
n_each_night=40
n_nights=200*(stopyear-startyear)
generate_observing_times,startyear,stopyear,n_each_night,n_nights,list
for i_night=0,n_nights-1,1 do begin
jd=list(*,i_night)
jd=jd(sort(jd))
njd=n_elements(jd)
if (ar1_noise_flag eq 1) then ar1series=fetch_AR1_series(njd)
get_lun,unit
openw,unit,'data.dat'
for i=0,n_elements(jd)-1,1 do begin
	SUNPOS, jd(i), ra_sun, dec_sun
	eq2hor, ra_sun, dec_sun, jd(i), alt_sun, az, LAT=lat_deg , LON=lon_deg
	ra_in=ra
	if (if_want_random_ra eq 1) then begin
		ra_in=24.0d0*randomu(seed)*15.0d0/180.0d0*!pi
	endif
	if (if_want_secant_airmass ne 1) then begin
		am = airmass(jd(i),ra_in,dec,lat,lon,wave,pressure,temp,relhum)
	endif
	if (if_want_secant_airmass eq 1) then begin
		am=get_secant_airmass(jd(i),ra_in/!dtor,dec_degs,lat_deg,lon_deg,wave,pressure,temp,relhum)
	endif
	if (am lt am_max and alt_sun lt -5) then begin
			noise=randomn(seed)*0.003d0
		if (ar1_noise_flag eq 1) then begin
			noise=ar1series(i)*0.003d0
		endif
		k=extinction(jd(i))
		mag_atmos=mag_0+k*am+noise
		mag_obs=-2.5d0*alog10(10^(mag_atmos/(-2.5d0))*sensitivity(jd(i)))
		printf,unit,format='(f20.7,1x,f14.7,1x,f14.7)',double(jd(i)),am,mag_obs
		printf,23,format='(f20.7,5(1x,g24.9))',double(jd(i)),am,mag_obs,double(jd(i)*am),double(jd(i)*jd(i)),sin(jd(i)/365.25d0*!pi*2.)
		print,format='(f20.7,5(1x,g24.9))',double(jd(i)),am,mag_obs,double(jd(i)*am),double(jd(i)*jd(i)),sin(jd(i)/365.25d0*!pi*2.)
;	help,double(jd(i)),am,mag_obs,double(jd(i)*am),double(jd(i)*jd(i)),sin(jd(i)/365.25d0*!pi*2.)

	endif
endfor	; end of loop over jd's
close,unit
free_lun,unit
;
data=get_data('data.dat')
jd=reform(data(0,*))*1.0d0
x=reform(data(1,*))*1.0d0
y=reform(data(2,*))*1.0d0
if (n_elements(x) gt n_min and abs(max(x))-abs(min(x)) gt min_span ) then begin
	plot,x,y,xtitle='Airmass',ytitle='m',charsize=2,psym=7,yrange=[mag_0,max(y)],ystyle=1,xrange=[0,am_max],xstyle=1
	res=linfit(x,y,yfit=yhat,/double,sigma=sigs,prob=p)
	oplot,[0.0,x],res(0)+res(1)*[0.0,x],thick=2
	print,'m0:',res(0),' +/- ',sigs(0)
	print,'k:',res(1),' +/- ',sigs(1)
	printf,format='(2(1x,f20.10))',14,mean(jd),res(0)
	printf,format='(2(1x,f20.10))',13,mean(jd),res(1)
endif
endfor
close,14
close,13
     print,' before',       exp_number,text_str,b,trend
go_perform_multiannual_analysis,exp_number,text_str,b,trend
close,11
close,23
close,66
end







