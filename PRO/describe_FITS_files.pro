PRO get_filter,header,filter
filter=header(where(strpos(header,'DMI_COLOR_FILTER') ne -1))
filter=strtrim(strmid(filter,29,8),2)
return
end

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

PRO get_expt,header,expt
idx=where(strpos(header, 'EXPOSURE') eq 0)
str='999'
if (idx(0) ne -1) then str=header(idx)
expt=float(strmid(str,9,strlen(str)-1))
return
end

bias=readfits('DAVE_BIAS.fits')
path='/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455741/'
path='/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455743/'
path='/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455762/'
files=file_search(path+'*.fits',count=n)
print,'Found ',n,' files.'
openw,4,'Bexposures.dat'
openw,5,'Vexposures.dat'
openw,6,'VE1exposures.dat'
openw,7,'VE2exposures.dat'
openw,8,'IRCUTexposures.dat'
for i=0,n-1,1 do begin
im=readfits(files(i),header,/sil)-bias
get_time,header,jd
get_expt,header,expt
get_filter,header,filter
fmtstr='(f9.5,1x,f12.4,1x,f20.8,1x,f7.1)'
print,format='(i3,1x,a,1x,f9.2,1x,f9.5,1x,f12.4,1x,f20.8)',i,filter,mean(im),expt,mean(im)/expt,jd
if (filter eq 'B' and median(im) gt 100) then printf,4,format=fmtstr,expt,mean(im)/expt,jd,mean(im)
if (filter eq 'V' and median(im) gt 100) then printf,5,format=fmtstr,expt,mean(im)/expt,jd,mean(im)
if (filter eq 'VE1' and median(im) gt 100) then printf,6,format=fmtstr,expt,mean(im)/expt,jd,mean(im)
if (filter eq 'VE2' and median(im) gt 100) then printf,7,format=fmtstr,expt,mean(im)/expt,jd,mean(im)
if (filter eq 'IRCUT' and median(im) gt 100) then printf,8,format=fmtstr,expt,mean(im)/expt,jd,mean(im)
endfor
close,4
close,5
close,6
close,7
close,8
dataB=get_data('Bexposures.dat')
dataV=get_data('Vexposures.dat')
dataVE1=get_data('VE1exposures.dat')
dataVE2=get_data('VE2exposures.dat')
dataIRCUT=get_data('IRCUTexposures.dat')
JDsunset=julday(7,19,2011,15,45,00)
!P.thick=2
!x.thick=2
!y.thick=2
!P.CHARSIZE=2
!P.MULTI=[0,1,3]
plot_io,/nodata,xstyle=3,24.*(dataB(2,*)-JDsunset),dataB(1,*),xtitle='Hours from sunset or dawn',ytitle='cts/s',psym=2,color=fsc_color('black')
oplot,24.*(dataB(2,*)-JDsunset),dataB(1,*),psym=2,color=fsc_color('blue')
oplot,24.*(dataV(2,*)-JDsunset),dataV(1,*),psym=4,color=fsc_color('green')
oplot,24.*(dataVE1(2,*)-JDsunset),dataVE1(1,*),psym=5,color=fsc_color('orange')
oplot,24.*(dataVE2(2,*)-JDsunset),dataVE2(1,*),psym=6,color=fsc_color('red')
oplot,24.*(dataIRCUT(2,*)-JDsunset),dataIRCUT(1,*),psym=7

plot_io,/nodata,xstyle=3,24.*(dataB(2,*)-JDsunset),dataB(0,*),xtitle='Hours from sunset or dawn',ytitle='exposure time [s]',psym=2,color=fsc_color('black')
oplot,24.*(dataB(2,*)-JDsunset),dataB(0,*),psym=2,color=fsc_color('blue')
oplot,24.*(dataV(2,*)-JDsunset),dataV(0,*),psym=4,color=fsc_color('green')
oplot,24.*(dataVE1(2,*)-JDsunset),dataVE1(0,*),psym=5,color=fsc_color('orange')
oplot,24.*(dataVE2(2,*)-JDsunset),dataVE2(0,*),psym=6,color=fsc_color('red')
oplot,24.*(dataIRCUT(2,*)-JDsunset),dataIRCUT(0,*),psym=7

plot_io,/nodata,xstyle=3,24.*(dataB(2,*)-JDsunset),dataB(3,*),xtitle='Hours from sunset or dawn',ytitle='Mean counts',psym=2,color=fsc_color('black'),yrange=[min([reform(dataB(3,*)),reform(dataV(3,*)),reform(dataVE1(3,*)),reform(dataVE2(3,*)),reform(dataIRCUT(3,*))]),max([reform(dataB(3,*)),reform(dataV(3,*)),reform(dataVE1(3,*)),reform(dataVE2(3,*)),reform(dataIRCUT(3,*))])]
oplot,24.*(dataB(2,*)-JDsunset),dataB(3,*),psym=2,color=fsc_color('blue')
oplot,24.*(dataV(2,*)-JDsunset),dataV(3,*),psym=4,color=fsc_color('green')
oplot,24.*(dataVE1(2,*)-JDsunset),dataVE1(3,*),psym=5,color=fsc_color('orange')
oplot,24.*(dataVE2(2,*)-JDsunset),dataVE2(3,*),psym=6,color=fsc_color('red')
oplot,24.*(dataIRCUT(2,*)-JDsunset),dataIRCUT(3,*),psym=7
end
