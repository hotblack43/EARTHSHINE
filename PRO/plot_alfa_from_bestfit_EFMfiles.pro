PRO get_phase,h,ph
idx=strpos(h,'MPHAS')
ipt=where(idx eq 0)
ph=double(strmid(h(ipt),12,20))
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

 PRO getALFAfromheader,header,alfa
 idx=where(strpos(header, 'ALFA') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 alfa=float(strmid(str,14,14))
 return
 end

;--------------------------------------------------------------
str=strcompress('/data/pth/CUBES/*MkIII_one*.fits',/remove_all)
files=file_search(str,count=n)
print,'found ',n,' files.'
get_lun,ww
openw,ww,strcompress('alfas_.dat',/remove_all)
for i=0,n-1,1 do begin
im=readfits(files(i),h,/silent)
getALFAfromheader,h,alfa
get_time,h,dectime
get_phase,h,ph
printf,ww,format='(f15.7,2(1x,f10.5))',dectime,alfa,ph
print,format='(f15.7,2(1x,f10.5))',dectime,alfa,ph
endfor
close,ww
free_lun,ww
end


