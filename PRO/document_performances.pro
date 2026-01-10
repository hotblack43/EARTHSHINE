; generate all the files
; make the observed image from the synthetic image. 
spawn,'./justconvolve ideal_testcase1.fits observed.fits 1.8'
; correct the 'observed' image by subtracting an estimated bias term
im=readfits('observed.fits')
bias=mean(im(0:20,0:20))
bias=0.0
im=im-bias
writefits,'observed.fits',im
; generate the '1/75th' source image
im=readfits('observed.fits')
idx=where(im lt 100)
im(idx)=0
writefits,'source.fits',im
im=readfits('source.fits')
idx=where(im eq 0)
spawn,'./justconvolve source.fits brightside_folded_1p8.fits 1.8'
spawn,'rm timing.temp'
; then plot the results
!P.MULTI=[0,1,4]
; read in the truth image - this is what the Moon is really like 
; and the sky is 0
ideal=readfits('ideal_testcase1.fits')
; Read in observed image - this is ideal folded with a PSF and a pedestal added
observed=readfits('observed.fits')
; Read in the image that is a observed version of an idealised
; source image - i.e. the image made from the observation, cutting out 
; all pixels below 1/75 of the smoothed maximum of the observed 
; image - PLUS an offset in all 0 pixels identical to the bias known 
; or assumed in the observed image
brightside_folded_1p8=readfits('brightside_folded_1p8.fits')
; calculate things needed for the plots
diff2=(brightside_folded_1p8-ideal)/ideal*100.0
diff=(observed-ideal)/ideal*100.0
idx=where(diff lt 0)
coo=array_indices(diff,idx)
;
;...........................
!P.CHARSIZE=1.3
; panel 1
contour,ideal,/isotropic,xstyle=3,ystyle=3,$
	title='Red: diff < 0'
oplot,coo(0,*),coo(1,*),psym=3,color=fsc_color('red')
; panel2
plot_io,/nodata,ideal(*,256),xstyle=3,$
        ystyle=3,$
	yrange=[0.1,5e4],xtitle='Column #',$
	ytitle='Pct difference (C-I)/I*100',$
	thick=2,$
title='Testing conservation of counts. !7a!3=1.8. Red = ideal; Black = Observed; Blue = Model'
oplot,ideal(*,256),thick=2,color=fsc_color('red')
oplot,observed(*,256)
oplot,brightside_folded_1p8(*,256),color=fsc_color('blue')
; panel 3
plot,yrange=[-1,3],ideal(*,256),xstyle=3,xtitle='Column #',ytitle='ideal (black) and model (green)',thick=2
oplot,observed(*,256)-brightside_folded_1p8(*,256),color=fsc_color('green'),thick=2
; panel 4
delta=(observed(*,256)-brightside_folded_1p8(*,256))-(ideal(*,256))
plot,xstyle=3,delta/ideal(*,256)*100.,$
ytitle='% diff',yrange=[-20,20]
oplot,[!X.crange],[0,0],linestyle=3
end 
