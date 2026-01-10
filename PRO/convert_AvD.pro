; get the digitized AvD surface brightness curve from right
; panel of their Figure 6.
data=get_data('AvDsurafcebrightness.dat')
x=reform(data(0,*))
y=reform(data(1,*))
r=10^(x)
SB=10^(y/(-2.5))
!P.CHARSIZE=2
!P.CHARTHICK=2
!P.THICK=5
!X.thick=4
!Y.thick=4
!P.multi=[0,1,2]
plot_oo,xstyle=3,ystyle=3,r,SB,ytitle='Surface brightness [counts/area]',xtitle='Radius [ªrcmin]'
;
SBderiv=deriv(r,sb)
f=2.*!dpi*sb+!dpi*r^2*SBderiv
plot_oo,r,f-min(f)+1e-5,xstyle=3,ystyle=3,xtitle='r [arcmin]',ytitle='PSF(r)'
end

