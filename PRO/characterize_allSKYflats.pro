PRO get_expt,header,expt
idx=where(strpos(header, 'EXPOSURE') eq 0)
str='999'
if (idx(0) ne -1) then str=header(idx)
expt=float(strmid(str,9,strlen(str)-1))
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

s=''
bias=readfits('DAVE_BIAS.fits',/silent)
openr,1,'~/allSKYflats.txt'
while not eof(1) do begin
readf,1,s
im=readfits(s,header,/silent)-bias
get_expt,header,expt
print,format='(f6.3,1x,f7.1,1x,a)',expt,mean(im),s
endwhile
close,1
end
