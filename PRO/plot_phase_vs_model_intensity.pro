PRO get_mphase,h,phase
idx=where(strpos(h,'MPHASE') eq 0)
phase=float(strmid(h(idx),12,30-12))
return
end


ifcalcfirst=0
if (ifcalcfirst eq 1) then begin
files=file_search('HAPKE/ideal_LunarI*',count=n)
openw,1,'HAPKEfluxes.dat'
for i=0,n-1,1 do begin
im=readfits(files(i),h,/silent)
get_mphase,h,phase
print,format='(f9.3,1x,e20.10)',phase,total(im,/double)
printf,1,format='(f9.3,1x,e20.10)',phase,total(im,/double)
endfor
close,1
files=file_search('LAMBERT/ideal_LunarI*',count=n)
openw,1,'LAMBERTfluxes.dat'
for i=0,n-1,1 do begin
im=readfits(files(i),h,/silent)
get_mphase,h,phase
print,format='(f9.3,1x,e20.10)',phase,total(im,/double)
printf,1,format='(f9.3,1x,e20.10)',phase,total(im,/double)
endfor
close,1
endif
data=get_data('HAPKEfluxes.dat')
ph=reform(data(0,*))
hapke=reform(data(1,*))
plot_io,ph,hapke,psym=7
data=get_data('LAMBERTfluxes.dat')
ph=reform(data(0,*))
lambert=reform(data(1,*))
oplot,ph,lambert,psym=7,color=fsc_color('blue')
; get Allen brightness
k=1.5e7
Allen=k*10^(-(0.026*abs(ph)+4e-9*ph^4)/2.5) 
oplot,ph,Allen,psym=4,color=fsc_color('red')
xyouts,-150,4e7,'Black    : Allen'
xyouts,-150,2e7,'Blue     : Lambert'
xyouts,-150,1e7,'Red      : Hapke 63'
end
