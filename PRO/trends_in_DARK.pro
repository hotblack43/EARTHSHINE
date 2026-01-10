!P.CHARSIZE=2
!P.THICK=2
!x.THICK=3
!y.THICK=3
!P.MULTI=[0,2,3]
for k=0,4,1 do begin
if (k eq 0) then im=readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455643/2455643.4932200DARK_DARK-50ms.fits.gz')
if (k eq 1) then im=readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455643/2455643.4957035DARK_DARK-500ms.fits.gz')
if (k eq 2) then im=readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455643/2455643.4942722DARK_DARK-300ms.fits.gz')
if (k eq 3) then im=readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455643/2455643.4949637DARK_DARK-400ms.fits.gz')
if (k eq 4) then im=readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455643/2455643.4932200DARK_DARK-50ms.fits.gz')
openw,44,'p.dat'
for i=0,49,1 do begin
printf,44,mean(im(*,*,i),/double)
endfor
close,44
data=get_data('p.dat')
d=(max(data)-min(data))/mean(data)*100.0
plot,ytitle='Bias mean.',xtitle='Image #',data,ystyle=3,title=string(k)+'. Range: '+string(d,format='(f5.2)')+' % or '+string((max(data)-min(data)),format='(f5.2)')+' cts.'
endfor
end
