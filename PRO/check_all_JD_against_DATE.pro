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

PRO gogettheJD,str,jd
bist=strsplit(str,'/',/extract)
jdx=strpos(bist,'245')
substr=strmid(bist(where(jdx eq 0)),0,15)
kdx=strpos(substr,'_')
if (kdx ne -1) then begin
strput,substr,'.',kdx(0)
endif
jd=double(substr)
return
end

file='allfits'
openw,44,'JD_differences.dat'
openr,1,file
while not eof(1) do begin
str=''
readf,1,str
print,'file: ',str
im=readfits(str,header,/SIL)
gogettheJD,str,jd
get_time,header,dectime
print,format='(2(1x,f15.7),1x,f9.3)',jd,dectime,jd-dectime
printf,44,format='(2(1x,f15.7),1x,f9.3)',jd,dectime,jd-dectime
endwhile
close,1
close,44
end
