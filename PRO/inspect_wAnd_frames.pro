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


files=file_search('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455462/Dark*.fits',count=n)
files=file_search('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455461/DoubleStar-WAnd/00*.fits',count=n)
openw,5,'mean_dark.dat'
for i=0,n-1,1 do begin
im_big=readfits(files(i),h)
l=size(im_big,/dimensions)
get_date,h,time
get_EXPOSURE,h,exptime
im=im_big
print,format='(f20.7,2(1x,f9.4),1x,f12.8)',time,mean(im),stddev(im),exptime
printf,5,format='(f20.7,2(1x,f9.4),1x,f12.8)',time,mean(im),stddev(im),exptime
endfor
close,5
data=get_data('mean_dark.dat')
t=reform(data(0,*))
mn=reform(data(1,*))
sd=reform(data(2,*))
exptime=reform(data(3,*))
idx=sort(t)
t=t(idx)
mn=mn(idx)
sd=sd(idx)
exptime=exptime(idx)
print,exptime
;
!P.MULTI=[0,1,1]
yrange=[min(mn),max(mn)]
idx=where(abs(exptime-7) lt 1e-7)
plot,psym=7,(t(idx)-min(t))*24.0,mn(idx),xtitle='Time (hours)',ytitle='Mean of each image',charsize=2,title='1e-5 s',yrange=yrange,ystyle=1,xrange=[0,1.2],xstyle=1
end
