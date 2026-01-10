 PRO get_date,h,time
 ;DATE             file creation date (YYYY-MM-DDThh:mm:ss)
 ;strmid(h(ipos),11,19)
 ;2010-09-23T09:43:02
 ipos=where(strpos(h,'DATE') ne -1)
 date_str=strmid(h(ipos),11,19)
 yy=fix(strmid(date_str,0,4))
 mm=fix(strmid(date_str,5,2))
 dd=fix(strmid(date_str,8,2))
 hh=fix(strmid(date_str,11,2))
 mi=fix(strmid(date_str,14,2))
 se=fix(strmid(date_str,17,2))
 time=double(julday(mm,dd,yy,hh,mi,se))
 return
 end

 PRO get_EXPOSURE,h,exptime
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 return
 end

; generate flatfields from images and dark frames
; V1
files=file_search('~/Desktop/ASTRO/home/pth/TEMPSTORAGE/*.fits',count=n)
; look for the DARKS
darkstring='DARK'
for i=0,n-1,1 do begin
idx=strpos(files(i),darkstring)
if (idx ne -1) then begin
if (i eq 0) then darkpointer=i
if (i gt 0) then darkpointer=[darkpointer,i]
dark=readfits(files(i),h)
get_date,h,time
get_EXPOSURE,h,exptime
endif
endfor
for i=0,n-1,1 do begin
im=readfits(files(i),h)
get_date,h,time
get_EXPOSURE,h,exptime
print,time,exptime,files(darkpointer(i))
endfor
end
