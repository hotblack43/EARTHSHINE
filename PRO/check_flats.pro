PRO get_meanhalfmedianval,im,meanhalfmedianval
l=size(im,/dimensions)
lo=fix(l(2)*0.2)
hi=fix(l(2)*0.8)
meanhalfmedianval=fltarr(l(0),l(1))
for i=0,l(0)-1,1 do begin
for j=0,l(1)-1,1 do begin
line=im(i,j,*)
line=line(sort(line))
middle=line(lo:hi)
meanhalfmedianval(i,j)=mean(middle)
endfor
endfor
return
end

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
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 return
 end
 
 
 PRO parse_str,str,flatname,darkname
 darkname=strmid(str,0,12)
 flatname=strmid(str,12,strlen(str)-1)
	darkname=strtrim(darkname)
	flatname=strtrim(flatname)
help,darkname,flatname
return
end

 
 ;
 path='Flatfield_2010_10_11/'
 openr,1,'files_darks_flats.txt'
 openw,33,'dusk_flats.txt'
 while not eof(1) do begin
 str=''
 readf,1,str
 parse_str,str,flatname,darkname
     dark=readfits(path+darkname)
	get_meanhalfmedianval,dark,meanhalfmedianval
	dark=meanhalfmedianval
	help,dark
     flat=readfits(path+flatname,h)
	get_meanhalfmedianval,flat,meanhalfmedianval
	flat=meanhalfmedianval
	help,flat
 	im=flat-dark
     get_date,h,time
     get_EXPOSURE,h,exptime
     print,format='(f20.9,1x,f9.4,1x,f9.3,1x,a)',time,exptime,mean(im),flatname
     printf,33,format='(f20.9,1x,f9.4,1x,f9.3)',time,exptime,mean(im)
	print,'---------------------------------'
 endwhile
 close,33
 end
