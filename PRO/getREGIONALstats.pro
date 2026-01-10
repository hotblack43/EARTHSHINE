;2455932.9334966MOON_V_AIR_averaged_DCR.fits
;2455932.9440606MOON_V_AIR_averaged_DCR.fits
;2455932.9546809MOON_V_AIR_averaged_DCR.fits

im=readfits('FLATTEN/DARKCURRENTREDUCED/2455932.9546809MOON_V_AIR_averaged_DCR.fits')
l=size(im,/dimensions)
a=-500
r0=7
meshgrid,l(0),l(1),x,y
while (a lt l(0)) do begin
im=readfits('FLATTEN/DARKCURRENTREDUCED/2455932.9380116MOON_VE2_AIR_averaged_DCR.fits',/silent)
tvscl,im
cursor,a,b,/device
radius_surface=sqrt((x-a)^2+(y-b) ^2)
idx=where(radius_surface le r0)
jdx=where(radius_surface le r0+1 and radius_surface gt r0-1)
print,'mean/stddev = ',mean(im(idx))/stddev(im(idx))
im(jdx)=max(im)
tvscl,im
wait,1
endwhile
end
