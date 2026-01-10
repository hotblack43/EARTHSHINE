PRO getnearest,JDwanted,lon,lat,jd,tcdc,nearest_tcdc
; interpolates or finds nearest map
d=abs(jd-JDwanted)
idx=where(d eq min(d))
print,'Nearest :',idx
nearest_tcdc=reform(tcdc(*,*,idx(0)))
return
end

PRO getthedata,JDwanted,lon,lat,nearest_tcdc
if (JDwanted lt julday(1,1,2010,0,0,0) or JDwanted gt julday(12,31,2012,23,59,59)) then begin
print,'That date not available yet!'
stop
endif
if (JDwanted ge julday(1,1,2010,0,0,0) and JDwanted le julday(12,31,2010,23,59,59)) then begin
file='/data/pth/NETCDF/X172.25.40.228.10.0.56.49.nc'
fetchdata,file,lon,lat,tcdc,jd
getnearest,JDwanted,lon,lat,jd,tcdc,nearest_tcdc
endif
if (JDwanted ge julday(1,1,2011,0,0,0) and JDwanted le julday(12,31,2011,23,59,59)) then begin
file='/data/pth/NETCDF/X172.25.40.228.10.0.59.3.nc'
fetchdata,file,lon,lat,tcdc,jd
getnearest,JDwanted,lon,lat,jd,tcdc,nearest_tcdc

endif
if (JDwanted ge julday(1,1,2012,0,0,0) and JDwanted le julday(12,31,2012,23,59,59)) then begin
file='/data/pth/NETCDF/X172.25.40.228.10.1.0.20.nc'
fetchdata,file,lon,lat,tcdc,jd
getnearest,JDwanted,lon,lat,jd,tcdc,nearest_tcdc
endif
return
end

PRO get_daynightmap,jd,lon_in,lat_in,daynightmap
nlon=n_elements(lon_in)
nlat=n_elements(lat_in)
daynightmap=findgen(nlon,nlat)*0.0
     sunPOS, jd, ra, dec, dis
for ilon=0,nlon-1,1 do begin
for ilat=0,nlat-1,1 do begin
eq2hor, RA, DEC, jd, alt, az, ha, lat=lat_in(ilat), lon=lon_in(ilon)
if (alt gt 0) then daynightmap(ilon,ilat)=1.0
endfor
endfor
return
end

PRO fetchdata,file,lon,lat,tcdc,jd
;file='/data/pth/NETCDF/X172.25.40.228.10.1.0.20.nc'
;ncdf_cat,file
 ncid = NCDF_OPEN(file)            ; Open The NetCDF file
 NCDF_VARGET, ncid,  'lat', lat      ; Read in variable 'lat'
 NCDF_VARGET, ncid,  'lon', lon      ; Read in variable 'lon'
 NCDF_VARGET, ncid,  'tcdc', tcdc ; Read in variable 'lsm'        ; minus 1 is land and +1 is sea
 NCDF_VARGET, ncid,  'time', time; Read in variable 'lsm'        ; minus 1 is land and +1 is sea
 jd=julday(1,1,1,0,0,0)+time/24.0d0
 tcdc=tcdc*0.1+3276.50
; 
 NCDF_CLOSE, ncid
 tcdc=[tcdc,tcdc(191,*,*)]
 lon=[lon,lon(0)]
return
end 


 ;....................Will produce a map of the Earth with clouds as seenf rom the Moon for any JD
 ; Only 2010, 2011, and 2012 possible right now
 ;
 for ih=1,23,1 do begin
 JD=julday(12,12,2011,ih,12,12)
 getthedata,JD,lon,lat,nearest_tcdc
     tcdc=nearest_tcdc
     MOONPOS, jd, ra, dec, dis
     eq2hor, RA, DEC, jd, alt, az, ha,  OBSNAME='mlo'
     ra=ra/360.0*24.0
     CT2LST, Lst, 360.-155.6027, 3, jd
     ha_new=lst-ra
     if (ha_new lt 0) then ha_new=24.+ha_new
     sublunar_longitude=360.-155.6027-ha
     if (sublunar_longitude lt 0) then sublunar_longitude=360.+sublunar_longitude
     map_set,dec,sublunar_longitude,0,/satellite,/isotropic,sat_p=[dis/6371.0d0,0,0]
    get_daynightmap,jd,lon,lat,daynightmap
    maptoshow=tcdc(*,*)*daynightmap
    contour,/overplot,/cell_fill,maptoshow,lon,lat
     map_continents,/overplot
     map_grid,/overplot
 print,format='(f15.7,1x,f9.3)',jd,avg(maptoshow)
 endfor
 end
