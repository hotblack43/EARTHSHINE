set_plot,'ps
device,/color,filename='idl.ps'
;device,decomposed=0
loadct,39
;
file='LSM.nc'
id = NCDF_OPEN(file)
NCDF_VARGET, id, 'lon',    lon_lsm
NCDF_VARGET, id, 'lat',    lat_lsm
NCDF_VARGET, id, 'var172',   lsm
NCDF_CLOSE,  id
print,'Done!'
;
file='/home/pth/DATA/NCfiles/GLIMPSE/SST_1500-2000.nc'
id = NCDF_OPEN(file)
NCDF_VARGET, id, 'lon',    lon

NCDF_VARGET, id, 'lat',    lat

NCDF_VARGET, id, 'time',   time
NCDF_VARGET, id, 'var139',   SST
NCDF_CLOSE,  id
print,'Done!'
nlon=n_elements(lon)
nlat=n_elements(lat)
;
lonfactor=1./2./2./2.
latfactor=1./2./2.
;
SST=REBIN(SST,128*lonfactor,64*latfactor,501)	; rebin to annual mean data
;
lon=rebin(lon,nlon*lonfactor)
lat=rebin(lat,nlat*latfactor)
nlon=n_elements(lon)
nlat=n_elements(lat)
;
; add a test signal
signal=0.*sin(indgen(501)/17.*2.*!pi)
for ilon=0,nlon-1,1 do begin
for ilat=0,nlat-1,1 do begin
sst(ilon,ilat,*)=sst(ilon,ilat,*)+signal
endfor
endfor
;
SST=reform(SST,128*lonfactor*64*latfactor,501)	;rebin for speed
;
l=size(sst,/dimensions)
;
m = l(0)    ; number of variables (space)
n = l(1)   ; number of observations (time)
means = TOTAL(SST, 2)/n
SST = SST - REBIN(means, m, n)
;--------------------------------
;Compute derived variables based upon the principal components.
;
torbens_pca, SST, variances, xtrace, eigenvectors, coefficients, nderiv = nderiv, weight = weight

   modes=reform(eigenvectors,128*lonfactor,64*latfactor,256)

   PRINT
   PRINT, '  Mode   PercentVariance'
periods=float(256)/(indgen(256)+0.00001)
FOR imode=0,4,1 DO BEGIN
	PRINT, imode+1,  variances[imode]/xtrace*100
	!P.MULTI=[0,1,3]
	map_set
	contour,modes(*,*,imode),lon,lat,/overplot,/cell_fill,nlevels=100
	map_continents,/overplot
	c=coefficients(imode,*)
    plot,c,xtitle='year',ytitle='Coefficient',ystyle=1
    z=fft(c,-1)
    zz=z*conj(z)
	plot_oo,periods,zz,xrange=[2,256/2],xtitle='Period (y)',ystyle=1,ytitle='Power'
endfor
plot_io,variances/xtrace*100.,xtitle='Eigenvalue #',ytitle='% variance explained',charsize=1.4,xrange=[0,20],ystyle=1,psym=-4
device,/close
END

