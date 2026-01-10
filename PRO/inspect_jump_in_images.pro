!P.MULTI=[0,1,2]
files=['/data/pth/DARKCURRENTREDUCED/SELECTED_1/2456073.7472223MOON_V_AIR_DCR.fits',$
'/data/pth/DARKCURRENTREDUCED/SELECTED_1/2456073.7781942MOON_V_AIR_DCR.fits',$
'/data/pth/DARKCURRENTREDUCED/SELECTED_1/2456073.7882301MOON_V_AIR_DCR.fits',$
'/data/pth/DARKCURRENTREDUCED/SELECTED_1/2456073.7983881MOON_V_AIR_DCR.fits','/data/pth/DARKCURRENTREDUCED/SELECTED_1/2456073.7758928MOON_B_AIR_DCR.fits']
shifts=[-3.0,1.0,0.0,0.0,0.0]
w=9
for i=0,n_elements(files)-1,1 do begin
print,files(i)
im=readfits(files(i),header,/silent)
if (i eq 0) then imtot=im
if (i eq 1) then imtot=[[imtot],[im]]
if (i eq 2) then imtot2=im
if (i eq 3) then imtot2=[[imtot2],[im]]
 get_info_from_header,header,'RADIUS',radius
 get_info_from_header,header,'EXPOSURE',exposure
;print,'EXPOSURE: ',exposure
 get_info_from_header,header,'DISCX0',x0
 get_info_from_header,header,'DISCY0',y0
;print,'From header: x0,y0: ',x0,y0,' radius: ',radius
line=avg(im(*,y0-w:y0+w),1)
help,line
line=line/exposure(0)
help,line
line=shift(line,shifts(i))
help,line
jump=mean(line(220:270))/mean(line(100:160))
help,jump
print,'Norm w exposure: ',jump, 'expo: ',exposure
ref=avg(line(80:120))
if (i eq 0) then plot,line-ref+10,yrange=[9,200],/ylog,title='Normalized w. exposure time'
if (i gt 0) then oplot,line-ref+10
endfor
oplot,[220,220],[1,1000]
oplot,[270,270],[1,1000]
oplot,[100,100],[1,1000]
oplot,[160,160],[1,1000]
oplot,line-ref+10,color=fsc_color('blue')
totim=[imtot,imtot2]
for i=0,n_elements(files)-1,1 do begin
print,files(i)
im=readfits(files(i),header,/silent)
if (i eq 0) then imtot=im
if (i eq 1) then imtot=[[imtot],[im]]
if (i eq 2) then imtot2=im
if (i eq 3) then imtot2=[[imtot2],[im]]
 get_info_from_header,header,'RADIUS',radius
 get_info_from_header,header,'EXPOSURE',exposure
;print,'EXPOSURE: ',exposure
 get_info_from_header,header,'DISCX0',x0
 get_info_from_header,header,'DISCY0',y0
;print,'From header: x0,y0: ',x0,y0,' radius: ',radius
line=avg(im(*,y0-w:y0+w),1)
line=line/total(im)*3e9;max(smooth(im,31))*180000.0
line=shift(line,shifts(i))
jump2=mean(line(220:270))/mean(line(100:160))
print,'Norm w total flux',jump2;,' expo: ',exposure
ref=avg(line(80:120))
if (i eq 0) then plot,line-ref+10,yrange=[9,200],/ylog,title='Normalized w. total flux '
if (i gt 0) then oplot,line-ref+10
endfor
oplot,[220,220],[1,1000]
oplot,[270,270],[1,1000]
oplot,[100,100],[1,1000]
oplot,[160,160],[1,1000]
oplot,line-ref+10,color=fsc_color('blue')
end
