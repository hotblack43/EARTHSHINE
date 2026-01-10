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


; calculates TOA albedo from ERAI
!P.CHARSIZE=2
str='ERAI TOA albedo'
file='/data/pth/CERES/MM_ERAI_TSR_TIS.nc'
ncdf_cat,file
id = NCDF_OPEN(file)
NCDF_VARGET, id, 'longitude',    lon
NCDF_VARGET, id, 'latitude',    lat
NCDF_VARGET, id, 'time',   time
NCDF_VARGET, id, 'tisr',   TIS
NCDF_VARGET, id, 'tsr',   TSR
NCDF_CLOSE,  id
; scale
idx=where(TIS eq -32767)
TIS=TIS*657.60264+21546350.
if (idx(0) ne -1) then TIS(idx)=!values.f_nan
idx=where(TSR eq -32767)
TSR=TSR*569.65977+18664902.
if (idx(0) ne -1) then TSR(idx)=!values.f_nan
;
jd=julday(1,1,1900,0,0,0)+time/24.0d0
;
spatial_albedo=1.-TSR/TIS
idx=where(spatial_albedo le 0 or spatial_albedo gt 1)
if (idx(0) ne -1) then spatial_albedo(idx)=!values.f_nan
weights=spatial_albedo*0.0
nlon=n_elements(lon)
nlat=n_elements(lat)
ntime=n_elements(time)
mm_albedo=fltarr(ntime)
; get the weights
for ilon=0,nlon-1,1 do begin
for ilat=0,nlat-1,1 do begin
for itime=0,ntime-1,1 do begin
;spatial_albedo(ilon,ilat,itime)=1.0-TSR(ilon,ilat,itime)/TIS(ilon,ilat,itime)
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
days=julday(1,1,1900,0,0,0)+time/24.0d0
caldat,days,mm,dd,yy
!P.MULTI=[0,1,3]
plot,days,mm_albedo,xtitle='JD',ytitle='ERAI albedo',xstyle=3,ystyle=3
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
endfor
plot,days mod 365.25,mm_albedo,xtitle='DOY',ytitle='ERAI albedo',psym=7,xstyle=3,ystyle=3
idx=where(finite(mm_albedo) eq 1)
oplot,days mod 365.25,climatology,color=fsc_color('red')
plot,days,mm_albedo-climatology,xtitle='JD',ytitle='ERAI albedo anomaly',xstyle=3,ystyle=3
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
openw,44,'CRU_vs_ERAI.dat'
for k=0,n_elements(mm)-1,1 do begin
idx=where(yyCRU eq yy(k) and mmCRU eq mm(k))
Tclimatology=mean(TCRU(where(mmCRU eq mm(k))))
print,mm(k),Tclimatology
print,mm(k),dd(k),yy(k),mm_albedo(k)-climatology(k),TCRU(idx)-Tclimatology
printf,44,mm(k),dd(k),yy(k),mm_albedo(k)-climatology(k),TCRU(idx)-Tclimatology
endfor
close,44
end
