;+
; programme to calculate mean land, se and land+sea layer thicknesses in GLIMPSE data
;-
device,decomposed=0
loadct,39
;
file='C:\RSI\WORK\LSM.nc'
id = NCDF_OPEN(file)
NCDF_VARGET, id, 'lon',    lon_lsm
NCDF_VARGET, id, 'lat',    lat_lsm
NCDF_VARGET, id, 'var172',   lsm
NCDF_CLOSE,  id
print,'Done!'
;
file='C:\SST_1500-2000.nc'
ncdf_cat,file
id = NCDF_OPEN(file)
NCDF_VARGET, id, 'lon',    lon
nlon=n_elements(lon)*1.0
NCDF_VARGET, id, 'lat',    lat
nlat=n_elements(lat)*1.0
NCDF_VARGET, id, 'time',   time
year=fix(time/10000.)
rest=time-year*10000L
month=fix(rest/100.)
fracyear=year+(month-0.5)/12.
NCDF_VARGET, id, 'var139',   SST
NCDF_CLOSE,  id
print,'Done!'
;
If_summer=1
If_winter=0
if_NHT=1
if_SHT=0
; set up for NHT or SHT averages
if (if_NHT eq 1) then begin
	str2=' NHT '
	lat_dx=where(lat gt 30)
endif
if (if_SHT eq 1) then begin
	str2=' SHT '
	lat_dx=where(lat lt 30)
endif
; make summer average
if (If_summer eq 1) then begin
str='SSTs summer'
ntime=501
mean_SST=fltarr(nlon,nlat,ntime)
for iyear=0,ntime-1,1 do begin
idx=where(year eq iyear+1500 and (month eq 6 or month eq 7 or month eq 8))
for ilon=0,nlon-1,1 do begin
for ilat=0,nlat-1,1 do begin
	mean_SST(ilon,ilat,iyear)=mean(SST(ilon,ilat,idx))
endfor
endfor
endfor
endif
; or make winter average
if (If_winter eq 1) then begin
str='SSTs winter'
ntime=501
mean_SST=fltarr(nlon,nlat,ntime)
for iyear=0,ntime-1,1 do begin
idx=where(year eq iyear+1500 and (month eq 1 or month eq 2 or month eq 3))
for ilon=0,nlon-1,1 do begin
for ilat=0,nlat-1,1 do begin
	mean_SST(ilon,ilat,iyear)=mean(SST(ilon,ilat,idx))
endfor
endfor
endfor
endif
;
air=mean_SST
;
; or just make annual mean
if (If_winter ne 1 and if_summer ne 1) then begin
str='SSTs annual'
ntime=501
air=REBIN(SST,128,64,501)	; rebin to annual mean data
endif
;
weight=dblarr(nlon,nlat)
for ilon=0,nlon-1,1 do begin
for ilat=0,nlat-1,1 do begin
weight(ilon,ilat)=cos(lat(ilat)/360.*2.*!pi)
endfor
endfor
;

;
mean_land=dblarr(ntime)
mean_sea=dblarr(ntime)
mean_global=dblarr(ntime)
; LAND & SEA averages
idx=where(lsm eq 1)
jdx=where(lsm eq 0)
for i=0,ntime-1,1 do begin
	slice=reform(air(*,lat_dx,i))
	mean_land(i)=total(slice(idx)*weight(idx))/total(weight(idx))
	mean_sea(i)=total(slice(jdx)*weight(jdx))/total(weight(jdx))
	mean_global(i)=total(slice*weight)/total(weight)
endfor


!P.MULTI=[0,1,3]

plot,mean_land-273.15,xtitle='Year',ytitle='Mean weighted land T',charsize=2,ystyle=1,title=str+' over land.'+str2
plot,mean_sea-273.15,xtitle='Year',ytitle='Mean weighted ocean T',charsize=2,ystyle=1,title=str+' over ocean.'+str2
plot,mean_global-273.15,xtitle='Year',ytitle='Ocean T/Land T',charsize=2,ystyle=1,title=str+' land and sea.'+str2
openw,11,'Land_Sea_LandSea_GLIMPSE_SST.dat'
for i=0,ntime-1,1 do begin
printf,11,format='(i5,3(1x,f7.2))',i+1500,mean_land(i)-273.15,mean_sea(i)-273.15,mean_global(i)-273.15
print,format='(i5,3(1x,f7.2))',i+1500,mean_land(i)-273.15,mean_sea(i)-273.15,mean_global(i)-273.15

endfor
close,11
;
lag1=a_correlate(mean_land,1)
f = SPECTRUM(mean_land,1.,FREQ=freq,PERIOD=period,siglvl=0.01,signif=signif,lag1=lag1)
plot_oi,period,f,xrange=[2,30],xstyle=1,ystyle=1,title=str+' over land.'+str2,xtitle='Years',ytitle='Power'
oplot,period,signif
;
z=fft(mean_sea,-1)
zz=z*conj(z)
periods=float(501.)/(indgen(501)+0.0000)
plot_oi,periods,zz,xrange=[2,30],xstyle=1,ystyle=1,title=str+' over ocean.'+str2,xtitle='Years',ytitle='Power'
;
z=fft(mean_global,-1)
zz=z*conj(z)
periods=float(501.)/(indgen(501)+0.0000)
plot_oi,periods,zz,xrange=[2,30],xstyle=1,ystyle=1,title=str+' over land and sea.'+str2,xtitle='Years',ytitle='Power'
;
end