PRO get_time,header,obstime
;
idx=where(strpos(header, 'DATE') eq 0)
str=header(idx)
if (idx(0) ne -1) then str=header(idx)
yy=fix(strmid(str,11,4))
mm=strmid(str,16,2)
dd=strmid(str,19,2)
hh=strmid(str,22,2)
mi=strmid(str,25,2)
sec=strmid(str,28,2)
obstime=julday(mm,dd,yy,hh,mi,sec)
return
end

files=file_search('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455741/*DARK*.fits',count=n)
openw,1,'cycle.dat'
fs='(f20.8,1x,f9.4,1x,f7.1)'
for i=0,n-1,1 do begin
im=double(readfits(files(i),header))
get_time,header,jd
printf,1,format=fs,jd,mean(im,/double),median(im)
endfor
close,1
data=get_data('cycle.dat')
set_plot,'ps'
device,/color
plot,reform(data(0,*)),reform(data(1,*)),ystyle=1
oplot,reform(data(0,*)),reform(data(2,*)),color=fsc_color('red')
device,/close
end

