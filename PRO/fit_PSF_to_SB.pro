FUNCTION SBfunct,x,a
common stuff,r,SB,lastPSF
; calculates a SB function given a trial PSF
; the parameters, a, contain the cvlues of the PSF
;
n=n_elements(x)
integral=dblarr(n)
y=a	; set the PSF to the guess
;...........
arg=x*y ; the integrand is r*PSF(r)
lastPSF=y
; now integrate to gte SB
for i=1,n-1,1 do begin
integral(i)= 2.0d0*!dpi*INT_TABULATED(x(0:i),arg(0:i),/DOUBLE)
endfor
; get the surface brightness
f=integral/(2.0d0*!dpi*x*x)
f(0)=f(1)
;---------------------------------------------
!P.CHARSIZE=2
!P.CHARTHICK=2
plot_oo,xtitle='radius [arcminutes]',ytitle='SB',/nodata,r,SB,color=fsc_color('red'),xstyle=3,ystyle=3
oplot,r,SB,color=fsc_color('red')
oplot,x,f,psym=7
return,f
end

;----------------------------------------------------------------
; Code to find PSF by fitting surface brightness curve
;
; get the digitized AvD surface brightness curve from right
; panel of their Figure 6.
common stuff,r,SB,lastPSF
data=get_data('AvDsurafcebrightness.dat')
x=reform(data(0,*))
y=reform(data(1,*))
r=10^x
SB=10^(-y/2.5)
x=r
y=SB
n=n_elements(x)
start_guess=randomu(seed,n)
; find PSF by forward integration of trial PSFs until it matches SB
 parinfo = replicate({mpside:2, value:0.D, $
 fixed:0, limited:[1,1], limits:[0.D,1.0d0],step:1d-13}, n)
 parinfo[*].value = start_guess
 ;
 erry=y*0+1.0
 niter=1000
 parms = MPFITFUN('SBfunct', X, Y, erry,  yfit=yfit, $
                PARINFO=parinfo, $
                PERROR=sigs,niter=niter,status=hej)
	print,'Status=',hej
for i=0,n-1,1 do print,r(i),lastPSF(i)
end 

