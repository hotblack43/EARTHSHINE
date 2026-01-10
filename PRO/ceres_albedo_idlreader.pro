
 ;+
 ;NAME:
 ;  ceres_idlreader
 ;PURPOSE:
 ;  This program will read the netcdf files that you download from
 ;  the CERES ordering tool webpage
 ;CATEGORY:
 ;  netcdf read
 ;CALLING SEQUENCE:
 ;  .r ceres_idlreader
 ;INPUT:
 ;  none
 ;OUTPUT:
 ;  ASCII file: CERES_OUT_TEST.txt
 ;KEYWORDS:
 ;  none
 ;NOTES:
 ;
 ;AUTHOR: CERES DEVELOPMENT TEAM
 ;-

openw,66,'ceres_albedo_daily_globalmean.dat'
 ncfile = 'CERES_SYN1deg-Day-lite_Terra_Ed2.6_Subset_200003-200603.nc'

 id = NCDF_OPEN(ncfile,/NOWRITE)   ;open netCDF file for READ only
     Tag = NCDF_INQUIRE(id)   ; get info about global, dimensions and parameters
     print, 'Tag Info: ', Tag.Ndims, Tag.Nvars,Tag.Ngatts
;   Tag.Nvars-Tag.Ndims = number of parameters
 print

 print,'Dimension Information'  ;show dimension variables and their attributes
FOR idim=0,Tag.Ndims-1 do begin
 result = NCDF_VARINQ(id,idim)
 print, 'Dimension', idim,' = ', result.Name
 varid = NCDF_VARID(id,result.Name)
 att_inq = NCDF_VARINQ(id,varid)   ; find all attributes for this dimension
 FOR iatt = 0,att_inq.Natts-1L DO BEGIN
   att_name = NCDF_ATTNAME(id,varid,iatt)  ;Find the attribute name. This is needed to extract the attribute from the netCDF file
   NCDF_ATTGET,id,varid,att_name,byte_var  ;extract the attribute from the netcdf file.
   sname = STRING(byte_var)   ;convert byte array into a string
 ;check to see how many elements are in the attribute, because sometimes valid_range is a 2 element array
   IF(N_ELEMENTS(sname) GT 1) THEN BEGIN
     attvalue = STRCOMPRESS(sname[0],/REMOVE_ALL) + ' to ' + STRCOMPRESS(sname[1],/REMOVE_ALL)
   ENDIF ELSE BEGIN
     attvalue = sname
   ENDELSE
   print,'   ', att_name, ' = ', attvalue
 ENDFOR
; NCDF_VARGET, id, varid, data   ; This is how you read dimension values into a "data" array
; print, data
ENDFOR
 print
 print


; show all parameters and their attributes
 print,'Parameter Name(s)'
 FOR ipar = Tag.Ndims,Tag.Nvars-1L DO BEGIN  ; find all parameters
     result = NCDF_VARINQ(id,ipar)
     print, ipar-Tag.Ndims,'  Parameter = ', result.Name
     varid = NCDF_VARID(id,result.Name)  
;     att_inq = NCDF_VARINQ(id,varid)   ; find all attributes for this parameter
;     for j = 0, att_inq.Natts-1 do begin
;           att_name = NCDF_ATTNAME(id,varid,j)
;           NCDF_ATTGET, id,varid,att_name,value
;           print, att_name, ' = ',string(value)
;      endfor
;      NCDF_VARGET, id, varid, data   ; read parameter values into "data" array
 ENDFOR ;ipar

 NCDF_CLOSE,id    ;close netCDF file

 print
 print

; ----------- the following is a data read/write example---------------

 outfile = 'CERES_OUT_TEST.txt'

 ;print 1-st parameter's attributes to the screen; it starts at Tag.Ndims
 id = NCDF_OPEN(ncfile,/NOWRITE) 
 
   varid = NCDF_VARID(id,'time')
   NCDF_VARGET, id, varid, time
   ntime = N_ELEMENTS(time)
   varid = NCDF_VARID(id,'lat')
   NCDF_VARGET, id, varid, lat
   nlat = N_ELEMENTS(lat)
   varid = NCDF_VARID(id,'lon')
   NCDF_VARGET, id, varid, lon
   nlon = N_ELEMENTS(lon) 

     result = NCDF_VARINQ(id,Tag.Ndims)
     print, '===  Example ===  Parameter Name: ',result.Name
     print, 'of dimensions',result.Dim
     varid = NCDF_VARID(id,result.Name)
     att_inq = NCDF_VARINQ(id,varid)   ; find all attributes for this parameter
     for j = 0, att_inq.Natts-1 do begin
           att_name = NCDF_ATTNAME(id,varid,j)
           NCDF_ATTGET, id,varid,att_name,value
           print, att_name, ' = ',string(value)
      endfor
      NCDF_VARGET, id, varid, data   ; read parameter values into "data" array
 NCDF_CLOSE,id
  ;convert time into IDL Julian day (time is defined as days since March 1,2000)
  date = JULDAY(3,1,2000) + time
   CALDAT,date,month,day,year  ;convert date into month,day,year

 print, 'write parameter - ',result.Name,' - values to ASCII file ',outfile
 OPENW,ounit,outfile,/GET_LUN
 printf,ounit,'Month Day Year     time      lat      lon       Value'  
  FOR itime= 0,ntime-1L DO BEGIN
  FOR ilat= 0,nlat-1L DO BEGIN
  FOR ilon= 0,nlon-1L DO BEGIN
     PRINTF,ounit,month[itime],day[itime],year[itime], $
     time[itime],lat[ilat],lon[ilon],$
     data[ilon,ilat,itime],FORMAT='(2I4,I6,I8,2F10.2,F12.4)'  
  ENDFOR ;ilon
  ENDFOR ;ilat
arr=data(*,*,itime)
print,date(itime),mean(arr(where(arr gt 0)))
printf,66,date(itime),mean(arr(where(arr gt 0)))
  ENDFOR ;itime

 FREE_LUN,ounit
close,66
; ------------------- end of example -------------------------------


 END
