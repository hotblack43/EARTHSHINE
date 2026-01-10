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
; Plot panel 1
!P.MULTI=[0,2,3]
!P.CHARSIZE=1.7
plot_io,xstyle=3,ystyle=3,xrange=[0,55],r,psf,xtitle='Radius [arcmin]',ytitle='PSF [Vol. Norm. counts]'
plot_oi,yrange=[30,10],xrange=[0.1,55],xstyle=3,ystyle=3,r,SB_psf,xtitle='Radius [arcmin]',ytitle='Surface brightness [mags/asec!u2!n]'
plot_oo,xstyle=3,ystyle=3,r,psf,xtitle='Radius [arcmin]',ytitle='PSF [counts]'
plot_oi,yrange=[23,-7],xrange=[0.01,55],xstyle=3,ystyle=3,r,SB_psf,xtitle='Radius [arcmin]',ytitle='Surface brightness [mags/asec!u2!n]'
oplot,[0.1,0.1],[22,-7],linestyle=1
oplot,[0.01,0.7],[-3.2,-3.2],linestyle=1
oplot,[0.01,4],[6.8,6.8],linestyle=2
oplot,[2.0,2.0],[23,3],linestyle=2
; overplot AvD
plot_oi,yrange=[23,-7],xrange=[0.01,55],xstyle=3,ystyle=3,r,SB_psf,xtitle='Radius [arcmin]',ytitle='Surface brightness [mags/asec!u2!n]'
data=get_data('AvDsurfbri.dat')
rAvD=10^reform(data(0,*))
SB_AvD=reform(data(1,*))
oplot,rAvD,SB_AvD-17,color=fsc_color('blue')
oplot,rAvD,SB_AvD-13,color=fsc_color('green')
end

