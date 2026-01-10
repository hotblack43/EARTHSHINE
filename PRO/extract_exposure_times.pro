 PRO get_filtername,header,name
 ;
 idx=where(strpos(header, 'DMI_COLOR_FILTER') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 name=strmid(str,29,8)
 return
 end

 PRO get_EXPOSURE,h,exptime
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 return
 end

 FUNCTION get_JD_from_filename,name
 JD=strmid(name,strpos(name,'/24')+1,15)
 return,JD
 end

file='MOON_files.txt'
openr,1,file
openw,33,'JD_exptime_filtername.txt'
while not eof(1) do begin
str=''
readf,1,str
im=readfits(str,header)
JD=get_JD_from_filename(str)
get_EXPOSURE,header,exptime 
get_filtername,header,name
help,im,JD,exptime(0),name
printf,33,format='(f15.7,1x,f9.5,1x,a)',jd,exptime,name
endwhile
close,1
close,33
end
