FUNCTION am,zenith_angle,im
if (im eq 1) then am=1./cos(zenith_angle*!dtor)*[1.0-0.0012*((1./cos(zenith_angle*!dtor))^2-1.0)]
; Rosenberg formula
if (im eq 2) then am=1.0d0/(cos(zenith_angle*!dtor)+0.025*exp(-11.*cos(zenith_angle*!dtor)))
return,am
end

extinction=0.2	; mags per airmass
n=85.0
openw,3,'diff.dat'
for i=0,n-1,1 do begin
z=i*1.0
printf,3,format='(3(1x,f12.5))',90.-z,extinction*(am(z+0.25,1)-am(z-0.25,1)),extinction*(am(z+0.25,2)-am(z-0.25,2))
endfor
close,3
data=get_data('diff.dat')
plot_io,reform(data(0,*)),reform(data(1,*)),yrange=[0.96e-3,0.11],xtitle='altitude (degrees)',ytitle='!7D!3 extinction across lunar disk [mags]',charsize=1.6,xrange=[0,60],ystyle=1,title='Differential extinction'
oplot,reform(data(0,*)),reform(data(2,*)),linestyle=2
end


