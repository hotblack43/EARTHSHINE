im=readfits('capella_coadded.fits')
;
x0=31.1
y0=34.9
;j=y0
openw,44,'capella_profile.dat'
for i=0,63,1 do begin
for j=0,63,1 do begin
r=sqrt((i-x0)^2+(j-y0)^2)
printf,44,r,im(i,j)
endfor
endfor
close,44
sky=0.0;1.1
data=get_data('capella_profile.dat')
r=reform(data(0,*))
f=reform(data(1,*))
plot_oi,ytitle='Instr. magnitudes',yrange=[29,20],r*6.67/60.,30-2.5*alog10(f-sky),xrange=[0.0025,400],psym=3,title='Sky subtracted: '+string(sky)
openw,47,'azi_profile_capella.dat'
for rr=0,50,2 do begin
idx=where(r ge rr and r le rr+2)
if (idx(0) ne -1) then printf,47,mean(r(idx))*6.67/60.,mean(30-2.5*alog10(f(idx)-sky)),n_elements(idx)
endfor
close,47
data=get_data('azi_profile_capella.dat')
rr=reform(data(0,*))
ff=reform(data(1,*))
oplot,rr,ff,color=fsc_color('red'),psym=-7
end

