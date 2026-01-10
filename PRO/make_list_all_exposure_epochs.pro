
 PRO get_info_from_header,header,str,valout
 if (str eq 'UNSTTEMP') then begin
     get_temperature,header,valout
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
 return
 end
 
 PRO get_temperature,header,temperature
 idx=where(strpos(header, 'UNSTTEMP') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 temperature=float(strmid(str,16,15))
 return
 end
PRO getJDfromheader,header,JD
idx=where(strpos(header,'DATE') ne -1)
line=header(idx)
line=strmid(line,11,strlen(line)-1)
line=strmid(line,0,19)
yyyy=fix(strmid(line,0,4))
mm=strmid(line,5,2)
dd=strmid(line,8,2)
hh=strmid(line,11,2)
mi=strmid(line,14,2)
ss=strmid(line,17,2)
JD=double(julday(mm,dd,yyyy,hh,mi,ss))
return
end

PRO getallbiasframenames_fromlist,files,n
listname='allFITS'
get_lun,w
openr,w,listname
name=''
i=0
while not eof(w) do begin
    readf,w,name
    if (i eq 0) then files=name
    if (i gt 0) then files=[files,name]
    i=i+1
    endwhile
close,w
free_lun,w
n=n_elements(files)
return
end

getallbiasframenames_fromlist,files,n
openw,23,'allEPOCHs.dat'
for i=0,n-1,1 do begin
file=files(i)
im=readfits(file,h,/silent)
l=size(im)
getJDfromheader,h,JD
print,format='(f15.7)',jd
printf,23,format='(f15.7)',jd
endfor
close,23
end
