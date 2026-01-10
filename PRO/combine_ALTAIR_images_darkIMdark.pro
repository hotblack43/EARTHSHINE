PRO go_add_to_the_right_one,im,exp_time2
common ims,summdimages,counts,exptimes
idx=where(exptimes eq exp_time2)
if (idx(0) eq -1) then begin
	print,'I am unprepared for ',exp_time2,', stopping.'
	stop
endif
if (counts(idx(0)) eq 0) then begin
	summdimages(*,*,idx(0))=im
	counts(idx(0))=1
	return
endif
if (counts(idx(0)) gt 0) then begin
	summdimages(*,*,idx(0))=summdimages(*,*,idx(0))+im
	counts(idx(0))=counts(idx(0))+1
	return
endif
end

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
	get_EXPOSURE,header,valout
	return
endif
return
end

 PRO get_EXPOSURE,h,exptime
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 exptime=exptime(0)
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


common ims,summdimages,counts,exptimes
exptimes=[0.3]
counts=exptimes*0
summdimages=fltarr(512,512,n_elements(counts))
openr,1,'ALTAIR.list2'
path='/media/SAMSUNG/SCIENCEPROJECTS/MOONDROPBOX/JD2455836/'
print,'-----------------------------------------'
ic=0
while not eof(1) do begin
a='' &b='' &c=''
readf,1,a & dark1=readfits(path+a,h1,/sil)
readf,1,b & im=readfits(path+b,h2,/sil)
readf,1,c & dark2=readfits(path+c,h3,/sil)
print,ic
print,a
print,b
print,c
get_info_from_header,h1,'EXPOSURE',exp_time1
get_info_from_header,h1,'DMI_ACT_EXP',measured_exptime1
dexpt1=(abs(exp_time1-measured_exptime1)/exp_time1*100.)

get_info_from_header,h2,'EXPOSURE',exp_time2
get_info_from_header,h2,'DMI_ACT_EXP',measured_exptime2
dexpt2=(abs(exp_time2-measured_exptime2)/exp_time2*100.)

get_info_from_header,h3,'EXPOSURE',exp_time3
get_info_from_header,h3,'DMI_ACT_EXP',measured_exptime3
dexpt3=(abs(exp_time3-measured_exptime3)/exp_time3*100.)
if (exp_time1 eq exp_time3 and (exp_time1 eq exp_time2) ) then begin
dark=(dark1+dark2)/2.0
im=im-dark
print,exP_time2,' ',b
go_add_to_the_right_one,im,exp_time2
endif
print,'-----------------------------------------'
ic=ic+1
endwhile
close,1
help,summdimages,counts,exptimes
for i=0,n_elements(counts)-1,1 do begin
	writefits,strcompress('ALTAIR_coadded_JD2455836_'+string(fix(exptimes(i)))+'_seconds.fits',/remove_all),reform(summdimages(*,*,i)/float(counts(i)))
endfor
end
