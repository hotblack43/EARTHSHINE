FUNCTION interpolatezodiacaltable,table_in,tablelon,tablelat,inlon,inlat
; return ZL in units of our Andor CCD - counts/second/pixel
if (abs(inlat) gt max(abs(tablelat)) or abs(inlat) lt min(abs(tablelat))) then stop
print,'Padding table'
table=table_in
table(where(table_in lt 0))=max(table_in)
 inter=10^grid_interpol(alog10(table),tablelon,tablelat,[abs(inlon)],[abs(inlat)])
 ;print,'table,lon,lat: ',inter,inlon,inlat
 inter=10.0-2.5*alog10(inter)	; mags/sq deg
 inter=inter+2.5*alog10(3600.0d0^2)	; mags/sq asec
 inter=inter-2.5*alog10(6.67^2)	; mags/pixel on our CCD
 value=10.0^((15.1-inter)/2.5)	; counts per second per pixel for our Andor camera
return,value
end

 FUNCTION interpolatetable,zoddata,delta_lat,delta_lon,heliolon,eclipticlat
 value=10^grid_interpol(alog10(zoddata),delta_lat,delta_lon,[abs(eclipticlat)],[abs(heliolon)])
 return,value
 end

; Code to generate data for the Sun-near parts of the Kwon ZL table from
; corresponding, but sparser, parts of the Leinert table.

 common zodiacal,iflag,zoddata,delta_lon,delta_lat
 common otherstuff,heliolon,beta,phase
 common sukminkwoon,iflagSMK,delta_lon_SMK,delta_lat_SMK,zoddata_SMK
 iflag=1
 iflagSMK=1
 if (iflag ne 314) then begin
     zoddata=float(get_data('/home/pth/idl_tools/zodiacal.txt'))
     delta_lon=float([0,5,10,15,20,25,30,35,40,45,60,75,90,105,120,135,150,165,180])
     delta_lat=float([0,5,10,15,20,25,30,45,60,75])
     idx=where(zoddata lt 0)
     zoddata(idx)=max(zoddata)
     iflag=314
     endif
 if (iflagSMK ne 314) then begin
      zoddata_SMK=float(get_data('~/idl_tools/sukminnkwoonZLtablewithoutheaders.dat'))
     zoddata_SMK=transpose(zoddata_SMK)
     ; Note that the table from Suk Minn KWoon is missing 30x30 degree innermost part!
     delta_lon_SMK=findgen(91)*2
     delta_lat_SMK=findgen(46)*2
     iflagSMK=314
     endif
 ; get coords from JD
 print,'Leinert interpolated onto Kwon core part:'
 print,format='(a,16(1x,i4))','l-lo->',findgen(16)*2
 for beta=0,42,2 do begin
 row=[beta]
 for heliolon=0,30,2 do begin
; interpolate the table in log-space and convert back to linear
 inter=interpolatetable(zoddata,delta_lat,delta_lon,heliolon,beta)
 row=[row,inter]
 endfor
 print,format='(a,i3,16(1x,i4))','   ',row
 if (beta eq 42) then row_42_leinert=row
 endfor
;---------------------------------
 print,'Kwon core part:'
 print,format='(a,16(1x,i4))','l-lo->',findgen(16)*2
 for beta=0,42,2 do begin
 row=[beta]
 for heliolon=0,30,2 do begin
; interpolate the table in log-space and convert back to linear
 inter=interpolatetable(zoddata_SMK,delta_lat_SMK,delta_lon_SMK,heliolon,beta)
 row=[row,inter]
 endfor
 print,format='(a,i3,16(1x,i4))','   ',row
 if (beta eq 42) then row_42_kwon=row
 endfor
 factor=median(row_42_kwon(1:16)/row_42_leinert(1:16))
 print,'Scale factor to apply to Leinert: ',factor
 plot,row_42_leinert(1:16)*factor
 oplot,row_42_kwon(1:16),color=fsc_color('red')
 print,'Scaled Leinert interpolated onto Kwon core part:'
 print,format='(a,16(1x,i4))','l-lo->',findgen(16)*2
 for beta=0,42,2 do begin
 row=[beta]
 for heliolon=0,30,2 do begin
; interpolate the table in log-space and convert back to linear
 inter=interpolatetable(zoddata,delta_lat,delta_lon,heliolon,beta)
 row=[row,inter*factor]
 endfor
 print,format='(a,i3,16(1x,i4))','   ',row
 endfor
 end
