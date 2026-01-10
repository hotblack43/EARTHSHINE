function imagefocusnumber,im
value=total(sobel(im)/total(im))
return,value
end

im=readfits('/media/HITACHI/BOOTSTRAPPEDOBSERVATINS/2456016.8566625MOON_VE2_AIR_aligned_integershifts_sum_of_100_#0_boot_frames.fits')
ntries=30
openw,12,'focus.dat'
for itry=0,ntries-1,1 do begin
im=smooth(im,3)
printf,12,itry,imagefocusnumber(im)
endfor
close,12
data=get_data('focus.dat')
plot,xstyle=3,ystyle=3,data(0,*),data(1,*),xtitle='Smooth #',ytitle='Focus'

im=readfits('/media/HITACHI/BOOTSTRAPPEDOBSERVATINS/2456016.7615454MOON_VE2_AIR_aligned_integershifts_sum_of_100_#0_boot_frames.fits')
ntries=30
openw,12,'focus.dat'
for itry=0,ntries-1,1 do begin
im=smooth(im,3)
printf,12,itry,imagefocusnumber(im)
endfor
close,12
data2=get_data('focus.dat')
oplot,data2(0,*),data2(1,*),color=fsc_color('red')
end
