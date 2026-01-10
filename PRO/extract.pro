file='hgt.mon.mean.nc'
ncdf_cat,file
id = NCDF_OPEN(file)
NCDF_VARGET, id, 'level',    level
NCDF_VARGET, id, 'lon',    lon
NCDF_VARGET, id, 'lat',    lat
NCDF_VARGET, id, 'hgt',   height
NCDF_VARGET, id, 'time',   time
NCDF_CLOSE,  id
jd=julday(1,1,1)+time/24.
caldat,jd,mm,dd,yy
fracyear=yy+(mm-1)/12.+(dd+15.)/365.25
idx=where(level eq 700)
surface=reform(height(*,*,idx,*))
idx=where(lat ge 10 and lat le 30)
surface=reform(surface(*,idx,*))
band=total(surface,2)/n_elements(idx)
zonal=total(band,1)/n_elements(lon)
plot,fracyear,zonal
;---
; smooth
zonal3=smooth(zonal,3,/edge_truncate)
zonal5=smooth(zonal,5,/edge_truncate)
fmt='(1x,f8.3,1x,i2,1x,i2,1x,i4,3(1x,f11.3))'
openw,34,'ZonalMean_700HPahgt10Nto30N'
for i=0,n_elements(zonal)-1,1 do begin
printf,34,format=fmt,fracyear(i),mm(i),dd(i),yy(i),zonal(i),zonal3(i),zonal5(i)
print,format=fmt,fracyear(i),mm(i),dd(i),yy(i),zonal(i),zonal3(i),zonal5(i)
endfor
close,34
end
