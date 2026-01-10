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
id = NCDF_OPEN(file)
NCDF_VARGET, id, 'lon',    lon
NCDF_VARGET, id, 'lat',    lat
NCDF_VARGET, id, 'time',   time
NCDF_VARGET, id, 'var139',   SST
NCDF_CLOSE,  id
print,'Done!'
;

;
SST=REBIN(SST,128,64,501)	; rebin to annual mean data
!P.MULTI=[0,2,2]
ntime=501
periods=float(ntime)/(indgen(ntime)+0.0001)

nlon=n_elements(lon)
nlat=n_elements(lat)
sea_summed_zz=fltarr(ntime)
land_summed_zz=fltarr(ntime)
for i=0,nlon-1,1 do begin
for j=0,nlat-1,1 do begin
idx=where(lon_lsm eq lon(i))
jdx=where(lat_lsm eq lat(j))
mask=lsm(idx,jdx)
if (mask eq 0) then begin
	x=sst(i,j,*)	;	+sin(indgen(ntime)/70.*2.*!pi)
	res=linfit(indgen(ntime),x,yfit=yfit,/double)
	x=x-yfit
	z=fft(x,-1)
	zz=z*conj(z)
	plot_oo,periods,zz,xtitle='Period (y)',ytitle='Power',ystyle=1,xrange=[2,500./2.],xstyle=1
	sea_summed_zz=sea_summed_zz+zz
endif
if (mask eq 1) then begin
	x=sst(i,j,*)	;	+sin(indgen(ntime)/70.*2.*!pi)
	res=linfit(indgen(ntime),x,yfit=yfit,/double)
	x=x-yfit
	z=fft(x,-1)
	zz=z*conj(z)
	plot_oo,periods,zz,xtitle='Period (y)',ytitle='Power',ystyle=1,xrange=[2,500./2.],xstyle=1
	land_summed_zz=land_summed_zz+zz
endif
endfor
endfor
!P.MULTI=[0,1,3]
plot_oo,periods,land_summed_zz,xtitle='Period (y)',ytitle='Power',ystyle=1,xrange=[2,500./2.],xstyle=1,title='Land'
plot_oo,periods,sea_summed_zz,xtitle='Period (y)',ytitle='Power',ystyle=1,xrange=[2,500./2.],xstyle=1,title='Sea'
plot_oo,periods,sea_summed_zz/land_summed_zz,xtitle='Period (y)',ytitle='Power',ystyle=1,xrange=[2,500./2.],xstyle=1,title='Sea/Land'


end