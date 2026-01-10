PRO get_SSNo,fracyear,SSNo
file='C:\Documents and Settings\Peter Thejll\My Documents\WORK\DATA\MONTHLY.PLT'
data=get_data(file)
yy=reform(data(0,*))
mm=reform(data(1,*))
SSNo= reform(data(2,*))
fracyear=yy+(mm-1)/12.
return
end



;*************************************************************
; IDL script for reading NetCDF file:
;*************************************************************

print, 'Warning:  If you have moved C:\air.mon.mean.nc from the current directory'+string(10B)+$
	string(9B)+'idl will not be able to open the file unless you modify'+$
	string(10B)+string(9B)+'the NCDF_OPEN line in this script to reflect the new path.'

ncid = NCDF_OPEN('C:\air.mon.mean.nc')            ; Open The NetCDF file

NCDF_VARGET, ncid,  0, lat      ; Read in variable 'lat'

NCDF_VARGET, ncid,  1, lon      ; Read in variable 'lon'

NCDF_VARGET, ncid,  2, time      ; Read in variable 'time'

NCDF_VARGET, ncid,  3, air      ; Read in variable 'air'

NCDF_CLOSE, ncid      ; Close the NetCDF file

; Also get Monthly SSNo
get_SSNo,SSNo_fracyear,SSNo
;
jd=julday(1,1,1)+time/24.
caldat,jd,mm,dd,yy
fracyear=yy+(mm-1.)/12.

; clip SSNo range to match NCEP file
idx=where(SSNo_fracyear ge min(fracyear) and SSNo_fracyear le max(fracyear)   )
SSNo_fracyear=SSNo_fracyear(idx)
SSNo=SSNo(idx)

!P.MULTI=[0,1,1]
nlon=n_elements(lon)
nlat=n_elements(lat)
ntime=n_elements(time)


nlon=n_elements(lon)
nlat=n_elements(lat)

period=float(ntime)/(1.+findgen(ntime))/12.
signal=fltarr(nlon,nlat)

max_index=-9e10
for ilon=0,nlon-1,1 do begin
print,ilon
for ilat=0,nlat-1,1 do begin

y=reform(air(ilon,ilat,*))
; remove linear trend
res=linfit(indgen(ntime),y,yfit=yfit)
y=y-yfit

z=fft(y,-1)

zz=float(z*conj(z))

;   plot,period,zz,xrange=[2,ntime/12./2.],xstyle=1

index=total(zz(where(period gt 9 and period lt 15)))/total(zz(where(period gt 4 and period lt 20)))
;   if (index gt max_index) then max_index=index
;   print,index,max_index
signal(ilon,ilat)=(index)
if (index gt 0.7 ) then begin
    !P.MULTI=[0,1,2]
    plot_oi,period,zz,xrange=[2.,25],xstyle=1,title=string(lon(ilat))+string(lat(ilat))
    smoo=smooth(y,13*2)
    plot,fracyear,smoo,thick=3
    ; regress SSno against the smoothed curve to get re-scaling
    res=linfit(SSNo,y(0:ntime-1-2),yfit=yfit)
    print,correlate(SSNo,y(0:ntime-1-2))
    oplot,fracyear,yfit,thick=4
endif
endfor
endfor

print,max(signal)

map_set,0,120,0,/isotropic,/mollweide;,limit=[-20,90,20,160]
contour,signal,lon,lat,/cell_fill,/overplot,nlevels=100
levels=-findgen(15)*0.05-0.13
levels=levels(sort(levels))
;contour,signal,lon,lat,/overplot,levels=levels,/downhill
map_continents,/overplot,/coasts,color=0,mlinethick=5
map_grid,latdel=30,londel=30,/overplot,latlab=30,lonlab=30
end