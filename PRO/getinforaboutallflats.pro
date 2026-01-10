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
 PRO get_EXPOSURE,h,exptime
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 return
 end

file='flats.txt'
openr,1,file
openw,45,'flatsinfo.txt'
while not eof(1) do begin
str=''
readf,1,str
im=readfits(str,header,/SIL)
;print,header
get_temperature,header,temperature
getJDfromheader,header,JD
get_EXPOSURE,header,exptime
printf,45,format='(f15.7,1x,f6.1,1x,f9.5,1x,a)',jd,temperature*1.0,exptime,str
endwhile
close,1
close,45
end
