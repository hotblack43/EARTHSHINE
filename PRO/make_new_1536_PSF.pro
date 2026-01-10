FUNCTION assymptote,x,y,d
value=interpol(y,x,max(x))*(max(x)/d)^3	; let die down as 1/r^3
return,value
end

im=dblarr(1536,1536)
data=get_data('PSF_MARKAB.dat')
x=reform(data(0,*))	; in arc minutes
y=reform(data(1,*))
;
x=x*60./6.67	; now in pixels
x0=1536./2.
y0=1536./2.
for i=0,1536-1,1 do begin
for j=0,1536-1,1 do begin
d=sqrt((i-x0)^2+(j-x0)^2)
if (d le max(x)) then psf=INTERPOL(y,x,d)
if (d gt max(x)) then psf=assymptote(x,y,d)
im(i,j)=psf
endfor
endfor
; normalize
im=im/total(im,/double)
im=shift(im,x0,y0)
surface,im,/zlog
writefits,'MARKAB_1536_PSF.fits',im
end
