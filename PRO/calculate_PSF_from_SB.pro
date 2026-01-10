;----------------------------------------------------------------
; Code to find PSF  from SB
;
; get the digitized AvD surface brightness curve from right
; panel of their Figure 6.
common stuff,r,SB,lastPSF
data=get_data('AvDsurafcebrightness.dat')
xold=reform(data(0,*))
yold=reform(data(1,*))
idx=sort(xold)
xold=xold(idx)
yold=yold(idx)
;
x=xold
y=yold
r=10.0d0^x
SB=10.0d0^(-y/2.5d0)
;
PSF=SB+r*min([0.0,DERIV(r,SB)])/2.0d0
psf=psf*1d4*10.
;
!P.charsize=2
!P.charthick=2
plot_io,r,-PSF,xrange=[0,55],xstyle=3,$
yrange=[1e-7,10],ystyle=3
end
