PRO get_info_from_header,header,str,valout
if (str eq 'ACT') then begin
        get_cycletime,header,valout
	return
endif
if (str eq 'UNSTTEMP') then begin
        get_temperature,header,valout
	return
endif
if (str eq 'DMI_ACT_EXP') then begin
        get_measuredexptime,header,valout
	return
endif
if (str eq 'DMI_COLOR_FILTER') then begin
        get_filtername,header,valout
	return
endif
if (str eq 'FRAME') then begin
	get_time,header,valout
	return
endif
if (str eq 'EXPOSURE') then begin
        get_exptime,header,valout
	return
endif
return
end

PRO get_exptime,header,exptime
idx=where(strpos(header, 'EXPOSURE') eq 0)
str='999'
if (idx(0) ne -1) then str=header(idx)
exptime=float(strmid(str,9,strlen(str)-1))
return
end


 PRO get_cycletime,header,acttime
 idx=where(strpos(header, 'ACT') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 acttime=float(strmid(str,16,15))
 return
 end

 PRO get_temperature,header,temperature
 idx=where(strpos(header, 'UNSTTEMP') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 temperature=float(strmid(str,16,15))
 return
 end

 PRO get_measuredexptime,header,measuredtexp
 idx=where(strpos(header, 'DMI_ACT_EXP') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 measuredtexp=float(strmid(str,24,8))
 return
 end

 PRO get_filtername,header,name
 ;
 idx=where(strpos(header, 'DMI_COLOR_FILTER') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 name=strmid(str,29,8)
 return
 end

 PRO get_time,header,dectime
 ;
 idx=where(strpos(header, 'FRAME') eq 0)
 str='999'
 if (idx(0) ne -1) then str=header(idx)
 yy=fix(strmid(str,11,4))
 mm=fix(strmid(str,16,2))
 dd=fix(strmid(str,19,2))
 hh=fix(strmid(str,22,2))
 mi=fix(strmid(str,25,2))
 se=float(strmid(str,28,6))
 dectime=julday(mm,dd,yy,hh,mi,se)
 return
 end


;--------------------------------------------------------------
; Code to inspect falt fields and will report on the man / max and so on
;--------------------------------------------------------------
;
bias=readfits('TTAURI/superbias.fits')
files=file_search("/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455826/2455826.*.fits",count=n)
oldJD=1.0
openw,44,'shutterdata.dat'
for ifile=0,n-1,1 do begin
im=readfits(files(ifile),h,/silent)
mn=mean(im-bias)
get_info_from_header,h,'FRAME',JD
get_info_from_header,h,'DMI_COLOR_FILTER',filter
get_info_from_header,h,'DMI_ACT_EXP',measured_exptime
get_info_from_header,h,'UNSTTEMP',temp
get_info_from_header,h,'ACT',cycle_time
get_info_from_header,h,'EXPOSURE',requested_exptime
print,format='(2(1x,f20.10))',requested_exptime,measured_exptime
printf,44,format='(2(1x,f20.10))',requested_exptime,measured_exptime
endfor
close,44
end
