PRO godobootstraplinfits,x,y,meanslope,SDslope
nMC=1000
n=n_elements(x)
slopes=fltarr(nMC)
for iMC=0,nMC-1,1 do begin
kdx=long(randomu(seed,n)*n)
res=linfit(x(kdx),y(kdx),/double)
slopes(iMC)=res(1)
endfor
meanslope=mean(slopes)
SDslope=stddev(slopes)
return
end

!P.CHARSIZE=3
str='TOA Incident Shortwave Radiation'
;file='/data/pth/DATA/NCfiles/rsdt_CERES-EBAF_L3B_Ed2-6r_200003-201206.nc'
file='/data/pth/DATA/NCfiles/rsdt_CERES-EBAF_L3B_Ed2-7_200003-201306.nc'
ncdf_cat,file
;stop
id = NCDF_OPEN(file)
NCDF_VARGET, id, 'lon',    lon
NCDF_VARGET, id, 'lat',    lat
NCDF_VARGET, id, 'time',   time
NCDF_VARGET, id, 'rsdt',   rsdt
NCDF_CLOSE,  id
print,'max rsdt:',max(rsdt)
idx=where(rsdt lt 12.0)
if (idx(0) ne -1) then rsdt(idx)=!values.f_nan
;file='/data/pth/DATA/NCfiles/rsut_CERES-EBAF_L3B_Ed2-6r_200003-201206.nc'
file='/data/pth/DATA/NCfiles/rsut_CERES-EBAF_L3B_Ed2-7_200003-201306.nc'
str='Outgoing at the top of the atmosphere'
ncdf_cat,file
id = NCDF_OPEN(file)
NCDF_VARGET, id, 'lon',    lon
NCDF_VARGET, id, 'lat',    lat
NCDF_VARGET, id, 'time',   time
NCDF_VARGET, id, 'rsut',   rsut
NCDF_CLOSE,  id
;print,'max rsut:',max(rsut)
;idx=where(rsut lt 12)
;if (idx(0) ne -1) then rsut(idx)=!values.f_nan
;
spatial_albedo=rsut/rsdt
weights=spatial_albedo*0.0
nlon=n_elements(lon)
nlat=n_elements(lat)
ntime=n_elements(time)
mm_albedo=fltarr(ntime)
; get the weights
for ilon=0,nlon-1,1 do begin
for ilat=0,nlat-1,1 do begin
for itime=0,ntime-1,1 do begin
spatial_albedo(ilon,ilat,itime)=rsut(ilon,ilat,itime)/rsdt(ilon,ilat,itime)
weights(ilon,ilat,itime)=cos(lat(ilat)*!dtor)
if (spatial_albedo(ilon,ilat,itime) gt 1) then stop
endfor
endfor
endfor
; normalize the weights
weights=weights/mean(weights,/nan)
; get the weighted global means
for itime=0,ntime-1,1 do begin
mm_albedo(itime)=mean(spatial_albedo(*,*,itime)*weights(*,*,itime),/NaN)
endfor
idx=where(abs(lat) gt 80)
mm_albedo(idx)=!values.f_nan
climatology=mm_albedo*0.0
;
;mm_albedo=avg(avg(weights*spatial_albedo,0,/NaN),0,/NaN)
days=julday(3,1,2000)+time
caldat,days,mm,dd,yy
!P.MULTI=[0,1,3]
plot,days,mm_albedo,xtitle='JD',ytitle='CERES albedo',xstyle=3,ystyle=3
idx=where(finite(mm_albedo) eq 1)
res=linfit(days(idx),mm_albedo(idx),yfit=yhat,/double,sigma=sigs)
print,'Slope: ',res(1),' +/- ',sigs(1)
print,'Mean albedo: ',mean(mm_albedo,/NaN),' +/- ',stddev(mm_albedo,/nan)
oplot,days(idx),yhat,color=fsc_color('red')
;
for im=1,12,1 do begin
idx=where(mm eq  im)
print,im,mean(mm_albedo(idx),/nan),' +/- ',stddev(mm_albedo(idx),/nan),' or, +/- ',stddev(mm_albedo(idx),/nan)/mean(mm_albedo(idx),/nan)*100.,' %.'
climatology(idx)=mean(mm_albedo(idx),/nan)
print,im,climatology(idx)
endfor
plot,days mod 365.25,mm_albedo,xtitle='DOY',ytitle='CERES albedo',psym=7,xstyle=3,ystyle=3
idx=where(finite(mm_albedo) eq 1)
oplot,days mod 365.25,climatology,color=fsc_color('red')
plot,days,mm_albedo-climatology,xtitle='JD',ytitle='CERES albedo anomaly',xstyle=3,ystyle=3
res=linfit(days(idx),mm_albedo(idx)-climatology(idx),yfit=yhat,/double,sigma=sigs)
print,'Slope: ',res(1),' +/- ',sigs(1)
print,'Mean albedo: ',mean(mm_albedo,/NaN)
oplot,days(idx),yhat,color=fsc_color('red')
godobootstraplinfits,days(idx),mm_albedo(idx)-climatology(idx),meanslope,SDslope
print,'MC mean slope: ',meanslope,' SD: ',SDslope
;
; get the CRUTEM4 data
dataT=get_data('~/CRUTEMP4_linear.dat')
yyCRU=reform(dataT(0,*))
mmCRU=reform(dataT(1,*))
TCRU=reform(dataT(2,*))
openw,44,'CRU_vs_CERES.dat'
for k=0,n_elements(mm)-1,1 do begin
idx=where(yyCRU eq yy(k) and mmCRU eq mm(k))
Tclimatology=mean(TCRU(where(mmCRU eq mm(k))))
print,mm(k),Tclimatology
print,mm(k),dd(k),yy(k),mm_albedo(k)-climatology(k),TCRU(idx)-Tclimatology
printf,44,mm(k),dd(k),yy(k),mm_albedo(k)-climatology(k),TCRU(idx)-Tclimatology
endfor
close,44
end
