PRO getthefiltername,name,filtername
bits=strsplit(name,'/',/extract)
idx=where(strpos(bits,'245') ne -1)
nn=bits(idx)
bits=strsplit(nn,'_',/extract)
filtername=bits(1)
return
end

PRO MOONPHASE,jd,az_moon,phase_angle_M,alt_moon,alt_sun,obsname
;-----------------------------------------------------------------------
; Set various constants.
;-----------------------------------------------------------------------
RADEG  = 180.0/!PI
DRADEG = 180.0D/!DPI
AU = 149.6d+6       ; mean Sun-Earth distance     [km]
Rearth = 6365.0D    ; Earth radius                [km]
Rmoon = 1737.4D     ; Moon radius                 [km]
Dse = AU            ; default Sun-Earth distance  [km]
Dem = 384400.0D     ; default Earth-Moon distance [km]
MOONPOS, jd, ra_moon, DECmoon, dis
distance=dis/6371.
eq2hor, ra_moon, DECmoon, jd, alt_moon, az_moon, ha_moon,  OBSNAME=obsname
SUNPOS, jd, ra_sun, DECsun
eq2hor, ra_sun, DECsun, jd, alt_sun, az, ha, OBSNAME=obsname
RAdiff = ra_moon - ra_sun
sign = +1
if (RAdiff GT 180.0) OR (RAdiff LT 0.0 AND RAdiff GT -180.0) then sign = -1
phase_angle_E = sign*acos( sin(DECsun/DRADEG)*sin(DECmoon/DRADEG) + cos(DECsun/DRADEG)*cos(DECmoon/DRADEG)*cos(RAdiff/DRADEG) ) * DRADEG
phase_angle_M = -atan( Dse*sin(phase_angle_E/DRADEG), Dem - Dse*cos(phase_angle_E/DRADEG) ) * DRADEG
return
end

PRO getthevalues,file,filterwanted,JD_list,alfa_list,albedo_list,err_albedo_list,phase_list,name_list
openr,1,file
ic=0
obsname='mlo'
while not eof(1) do begin
str=''
readf,1,str
bits=strsplit(str,' ',/extract)
; JD,albedo,erralbedo,alfa,pedestal,xshift,RMSE,name
jd=double(bits(0))
; get stuff
MOONPHASE,jd,az_moon,phase_angle_M,alt_moon,alt_sun,obsname
albedo=double(bits(1))
err_albedo=double(bits(2))
alfa=double(bits(3))
name=bits(8)
getthefiltername,name,filtername
if (ic eq 0) then jd_list=jd
if (ic eq 0) then albedo_list=albedo
if (ic eq 0) then err_albedo_list=err_albedo
if (ic eq 0) then alfa_list=alfa
if (ic eq 0) then phase_list=phase_angle_M
if (ic eq 0) then name_list=filtername
if (ic gt 0) then jd_list=[jd_list,jd]
if (ic gt 0) then albedo_list=[albedo_list,albedo]
if (ic gt 0) then err_albedo_list=[err_albedo_list,err_albedo]
if (ic gt 0) then alfa_list=[alfa_list,alfa]
if (ic gt 0) then phase_list=[phase_list,phase_angle_M]
if (ic gt 0) then name_list=[name_list,filtername]
ic=ic+1
endwhile
close,1
; return only the B and V values
idx=where(name_list eq filterwanted)
JD_list=JD_list(idx)
alfa_list=alfa_list(idx)
albedo_list=albedo_list(idx)
phase_list=phase_list(idx)
return
end

; first read in the values
file='CLEM.profiles_fitted_results_April_24_2013.txt'
wanthisfilter='B'
getthevalues,file,wanthisfilter,B_JD,B_alfa,B_albedo,err_B_albedo,B_phase,B_name_list
print,'Found all B values...'
wanthisfilter='V'
getthevalues,file,wanthisfilter,V_JD,V_alfa,V_albedo,err_V_albedo,V_phase,V_name_list
print,'Found all V values...'
; then form suitable B and V pairs
deltajd=0.5d0/24.0d0
B_n=n_elements(B_jd)
openw,33,'BminusValbedos_fromCLEM.dat'
for i=0,B_n-1,1 do begin
idx=where(abs(V_JD-B_JD(i)) lt deltajd)
if (n_elements(idx) ge 1) then begin
for k=0,n_elements(idx)-1,1 do begin
fmt='(3(1x,f15.7),4(1x,f9.3))'
printf,33,format=fmt,B_JD(i),V_JD(idx(k)),(B_JD(i)+V_JD(idx(k)))/2.0d0,(B_phase(i)+V_phase(idx(k)))/2.0d0,(B_alfa(i)+V_alfa(idx(k)))/2.0d0,B_albedo(i)-V_albedo(idx(k)),sqrt(err_B_albedo(i)^2+err_V_albedo(idx(k))^2)
endfor
endif
endfor
close,33
; plot that
data=get_data('BminusValbedos_fromCLEM.dat')
B_JD=reform(data(0,*))
V_JD=reform(data(1,*))
avg_JD=reform(data(2,*))
avg_phase=reform(data(3,*))+0.01*randomn(seed,n_elements(data(3,*)))
avg_alfa=reform(data(4,*))
BmValbedo=reform(data(5,*))
errBmValbedo=reform(data(6,*))
!P.CHARSIZE=1.7
!P.THICK=3
!x.THICK=2
!y.THICK=2
!P.MULTI=[0,1,1]
idx=where(avg_phase lt 0)
xra=[-100.5,-99.5]
plot,xstyle=3,ystyle=3,psym=7,xrange=xra,avg_phase(idx),BmValbedo(idx),xtitle='Lunar phase [FM=0]',ytitle='B-V (albedo)'
oploterr,avg_phase(idx),BmValbedo(idx),errBmValbedo(idx)
xra=[1.4,1.8]
plot,xstyle=3,ystyle=3,psym=7,xrange=xra,avg_alfa(idx),BmValbedo(idx),xtitle='!7a!3',ytitle='B-V (albedo)'
;
n=n_elements(avg_JD)
liste=long(avg_JD)
liste=liste(sort(liste))
uniqlist=liste(uniq(liste))
print,n_elements(uniqlist),' different days ...'
colornames=['blue','red','yellow','green','orange','purple','grey','cyan','grey','cyan']
xra=[0.74,0.9]
yra=[0,0.2]
!P.MULTI=[0,4,3]
fmt='(f15.7,4(1x,f9.3),1x,i4)'
openw,55,'medianBmValbedos.dat'
for i=0,n_elements(uniqlist)-1,1 do begin
idx=where(long(avg_JD) eq uniqlist(i))
if (mean(avg_phase(idx)) lt 0) then begin
plot,xtitle='JD fraction',ytitle='B alb - V alb',title=string(uniqlist(i)),/nodata,xstyle=3,xrange=xra,yrange=yra,avg_JD(idx) mod 1,BmValbedo(idx),psym=7,color=fsc_color('black')
oplot,avg_JD(idx) mod 1,BmValbedo(idx),psym=7,color=fsc_color(colornames(i mod n_elements(colornames)))
res=linfit(avg_JD(idx) mod 1,BmValbedo(idx),/double,sigma=sigs)
print,'Slope: ',res(1),sigs(1),res(1)/sigs(1)
if (n_elements(idx) gt 10) then begin
printf,55,format=fmt,uniqlist(i),mean(avg_phase(idx)),mean(avg_alfa(idx)),median(BmValbedo(idx)),stddev(BmValbedo(idx)),n_elements(idx)
endif
endif
endfor
close,55
;
!P.MULTI=[0,1,1]
data=get_data('medianBmValbedos.dat')
jd=reform(data(0,*))
ph=reform(data(1,*))
al=reform(data(2,*))
BmV=reform(data(3,*))
errBmV=reform(data(4,*))
plot,al,BmV,psym=7,xtitle='!7a!3',ytitle='B - V [albedos]'
plot,xrange=[-130,-70],yrange=[0.05,0.1],ph,BmV,psym=7,xtitle='lunar phase [FM=0]',ytitle='Daily median B - V [albedos]'
oploterr,ph,BmV,errBmV
xyouts,ph,BmV,'   '+string(long(jd),format='(i7)'),orientation=-65,charsize=1.2
end
