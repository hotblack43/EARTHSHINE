; Code that finds the shifts require dto align segments of two images.
; Uses all possible pairs of segments for nxn subdivision
im1=readfits('/data/pth/DARKCURRENTREDUCED/SELECTED_1/EFMCLEANED_0p7MASKED/2455945.1760145MOON_B_AIR_DCR.fits',Bhead)
im2=readfits('/data/pth/DARKCURRENTREDUCED/SELECTED_1/EFMCLEANED_0p7MASKED/2455945.1776847MOON_V_AIR_DCR.fits',Vhead)
offset_all = alignoffset(im1,im2, corr)
n=4
openw,22,'offsets.data'
for i=0,n-1,1 do begin
for j=0,n-1,1 do begin
ifrom=i*512/n
ito=(i+1)*512/n-1
jfrom=j*512/n
jto=(j+1)*512/n-1
;print,ifrom,ito,jfrom,jto
subim1=im1(ifrom:ito,jfrom:jto)
subim2=im2(ifrom:ito,jfrom:jto)
offset = alignoffset(subim1,subim2, corr)
if (corr gt 0.75) then begin
print,corr,offset
printf,22,offset
endif
tvscl,[subim1,subim2]
endfor
endfor
close,22
data=get_data('offsets.data')
!P.CHARSIZE=1.7
!P.MULTI=[0,2,1]
plot,/isotropic,data(0,*),data(1,*),psym=7,xtitle='X offset',ytitle='Y offset'
oplot,[median(data(0,*)),median(data(0,*))],!Y.crange                            
oplot,!X.crange,[median(data(1,*)),median(data(1,*))]
oldx=median(data(0,*))
oldy=median(data(1,*))
print,'Whole image guess: ',offset_all
print,'First guess: ',median(data(0,*)),median(data(1,*))
deltax=abs(!X.crange(1)-!X.crange(0))/1.
deltay=abs(!Y.crange(1)-!Y.crange(0))/1.
idx=where((data(0,*) gt offset_all(0)-deltax and data(0,*) lt offset_all(0)+deltax) and (data(1,*) gt offset_all(1)-deltay and data(1,*) lt offset_all(1)+deltay))
data=data(*,idx)
plot,/isotropic,data(0,*),data(1,*),psym=7,xtitle='X offset',ytitle='Y offset'
print,'Second guess: ',median(data(0,*)),median(data(1,*))
oplot,[median(data(0,*)),median(data(0,*))],!Y.crange 
oplot,!X.crange,[median(data(1,*)),median(data(1,*))]
oplot,[oldx,oldx],!Y.crange,linestyle=2                            
oplot,!X.crange,[oldy,oldy],linestyle=2
end
