PRO go_interpolate,array_in,lon_in,lat_in,array_gridded,longrid,latgrid
 ; will interpolate the data given as array_in,lon_in,lat_in onto the
 ; grid given by longrid,latgrid. The output data will be array_gridded
 help,array_in,lon_in,lat_in,array_gridded,longrid,latgrid
 datvector=array_in
 lonvector=lon_in
 latvector=lat_in
 l=size(array_in,/dimension)
 if (n_elements(l) ne 1) then begin
     datvector=reform(array_in,float(l(0)*l(1)))
     if (n_elements(lon_in) eq l(0)*l(1)) then begin
         lonvector=reform(lon_in,float(l(0)*l(1)))
         latvector=reform(lat_in,float(l(0)*l(1)))
         endif
     if (n_elements(lon_in) eq l(0)) then begin
         lonvector=lon_in
         latvector=lat_in
         for k=1,l(1)-1,1 do lonvector=[lonvector,lon_in]
         for k=1,l(0)-1,1 do latvector=[latvector,lat_in]
         endif
     endif
 l2=size(longrid,/dimension)
 xoutvector=reform(longrid,float(l2(0)*l2(1)))
 youtvector=reform(latgrid,float(l2(0)*l2(1)))
 Result = GRIDDATA( lonvector,  latvector,  datvector,  /SPHERE, /DEGREES, xout=xoutvector, yout=youtvector ) 
 help,Result
 array_gridded=reform(Result,l2(0),l2(1))
 return
 end
 
