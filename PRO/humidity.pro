PRO get_match,x1,x2,idx1,idx2
; will check the match between x1 and x2 returning indexes for matched values in x1 in idx1
; and for x2 in idx2
idx1=-911
idx2=-911
for i=0,n_elements(x1)-1,1 do begin
index=where(x2 eq x1(i))
if (index(0) ne -1) then begin
idx1=[idx1,i]
idx2=[idx2,index(0)]
endif
endfor
n1=n_elements(idx1)
n2=n_elements(idx2)
idx1=idx1(0:n1-1)
idx2=idx2(0:n2-1)
return
end


file='shum.mon.mean.nc'
ncdf_cat,file
id = NCDF_OPEN(file)
NCDF_VARGET, id, 'level',    level
NCDF_VARGET, id, 'lon',    lon
NCDF_VARGET, id, 'lat',    lat
NCDF_VARGET, id, 'shum',   shum
NCDF_VARGET, id, 'time',   time
NCDF_CLOSE,  id
shum=shum*0.00100000+32.6650
jd=julday(1,1,1)+time/24.
caldat,jd,mm,dd,yy
fracyear=yy+(mm-1)/12.+(dd+15.)/365.25
;
; get p and T from hgt files
file='/home/pth/SCIENCEPROJECTS/work_idl/nc_files/air.mon.mean.nc'
ncdf_cat,file
id = NCDF_OPEN(file)
NCDF_VARGET, id, 'level',    hgt_level
NCDF_VARGET, id, 'lon',    lon
NCDF_VARGET, id, 'lat',    lat
NCDF_VARGET, id, 'air',   air
NCDF_VARGET, id, 'time',   time
NCDF_CLOSE,  id
pressure=hgt_level*101.325
air=air*0.01+127.65+273.15	; degrees K
jd2=julday(1,1,1)+time/24.
caldat,jd2,mm2,dd2,yy2
fracyear2=yy2+(mm2-1)/12.+(dd2+15.)/365.25
molarweight=0.028	; the weight in kilograms of one mole of air (N2, we guess)
R=8.314			; gas konstant
ratio=1./air
for idx=0,n_elements(hgt_level)-1,1 do ratio(*,*,idx,*)=pressure(idx)*ratio(*,*,idx,*)
density=ratio*molarweight/R
surface,density(*,*,0,100),lon,lat,charsize=2,title='Air density at surface'
;
; match time scales up
get_match,fracyear,fracyear2,idx1,idx2
fracyear=fracyear(idx1)
fracyear2=fracyear2(idx2)
shum=shum(*,*,*,idx1)
density=density(*,*,0:n_elements(level)-1,idx2)
shum_density=shum*density
; select latitude and altitude bands
idx_lat=where(lat gt -20 and lat lt 20)
idx_lev=where(hgt_level le 750)
shum_density=shum_density(*,idx_lat,idx_lev,*)
;
zonal_water=total(shum_density,1)
levels_water=total(zonal_water,1)
total_water=total(levels_water,1)
plot,fracyear,total_water
; get anomalies
anomalies=total_water*0.0
for im=1,12,1 do begin
idx=where(mm eq im)
mn=mean(total_water(idx))
anomalies(idx)=total_water(idx)-mn
print,im,mn
endfor
plot,fracyear,anomalies,xtitle='Year',ytitle='Total water anomaly',title='NCEP',charsize=2
oplot,fracyear,smooth(anomalies,13.*3,/edge_truncate),thick=3
res=linfit(fracyear,anomalies,yfit=yfit)
anomalies=anomalies-yfit
plot,fracyear,anomalies,xtitle='Year',ytitle='Total water anomaly',title='NCEP',charsize=2
oplot,fracyear,smooth(anomalies,13.*3,/edge_truncate),thick=3
; get SOlar flux
file='SSNo.annual'
data=get_data(file)
ssyear=reform(data(0,*))
ssno=reform(data(1,*))
ssno=(ssno-mean(ssno))/stddev(ssno)*500-2000
oplot,ssyear,ssno,thick=3
end
