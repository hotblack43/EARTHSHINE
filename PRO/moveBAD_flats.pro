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
; Code to inspect flat fields and to move the bad ones manually
;--------------------------------------------------------------
;
path='/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455827/'
files=file_search(path,'*DUSK*.fits',count=n)
a=''
ic=0
while (a ne 'q') do begin
im=readfits(files(ic),h,/silent)
mn=mean(im)
print,mn,files(ic)
if (mn lt 10000 or mn gt 56000) then begin
	file_move,files(ic),strcompress(path+'BAD/',/remove_all)
endif else begin
tvscl,(im)
;tvscl,histomatch(im,findgen(256)*0+1)
a=get_kbrd()
endelse
ic=ic+1
endwhile
end
