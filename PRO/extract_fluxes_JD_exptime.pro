@stuff19.pro

 PRO get_EXPOSURE,h,exptime
 ;EXPOSURE=                 0.02 / Total Exposure Time
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 return
 end


 FUNCTION get_JD_from_filename,name
 ;print,'In get_JD_from_filename, trying to convert this name to a JD: ',name
 liste=strsplit(name,'/',/extract)
 idx=strpos(liste,'24')
 ipoint=where(idx ne -1)
 JD=double(liste(ipoint))
 return,JD
 end


 close,/all
 openw,2,'JD_maxcounts_illfrac_V_AIR.txt'
 openr,1,'DCR_V_AIR_gz.txt'
 while not eof(1) do begin
 file=''
 readf,1,file
 JD=get_JD_from_filename(file)
 mphase,JD,illfrac
 im = readfits(file,h)
 get_EXPOSURE,h,exptime
 printf,2,format='(f15.7,1x,f9.1,1x,f9.4,1x,f9.4)',JD,max(im),illfrac,exptime
 endwhile
close,1
close,2
 end
