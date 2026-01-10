PRO converttosurfacebrightrness,r,psf,mags_SB_psf
; NB: r is assumed to be in arc minutes
n=n_elements(r)
mags_SB_psf=r*0.0
for i=1,n-2,1 do begin
area0=!dpi*r(i-1)^2
area1=!dpi*r(i)^2
area2=!dpi*r(i+1)^2
anulus_area=(area2-area1)/2.+(area1-area0)/2.
flux_SB_psf=psf(i)/(anulus_area*3600.0)	; 3600 since r is in arcminutes
mags_SB_psf(i)=-2.5*alog10(flux_SB_psf)
endfor
mags_SB_psf(0)=mags_SB_psf(1)
mags_SB_psf(n-1)=mags_SB_psf(n-2)
return
end


; generate a SB profile of the AMRKAB PSF
data=get_data('PSF_MARKAB.dat')
r=reform(data(0,*))     ; in arc minutes
psf=reform(data(1,*))
;
converttosurfacebrightrness,r,psf,SB_psf
openw,33,'header_SB_MARKAB.dat'
openw,32,'noheader_SB_MARKAB.dat'
printf,33,'arcmin        mags/asec**2'
for i=0,n_elements(r)-1,1 do begin
print,r(i),SB_psf(i)
printf,32,r(i),SB_psf(i)
printf,33,r(i),SB_psf(i)
endfor
close,32
close,33
end

