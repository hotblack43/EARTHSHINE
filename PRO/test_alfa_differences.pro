!P.MULTI=[0,1,2]
!P.thick=2
!P.CHARSIZE=1.3
!P.thick=2
!x.thick=2
!y.thick=2
file='./synthetic_2455864.fits'
ideal=readfits(file)
writefits,'infil.fits',ideal
;
alfa1=1.73
str='./justconvolve infil.fits outfil.fits '+string(alfa1)
spawn,str
out1=readfits('outfil.fits')
alfa1=1.73*1.04
str='./justconvolve infil.fits outfil.fits '+string(alfa1)
spawn,str
out2=readfits('outfil.fits')
out1=-2.5*alog10(out1)
out2=-2.5*alog10(out2)
diff=out1-out2+0.92
contour,/isotropic,ideal,xstyle=3,ystyle=3
plot,/noerase,yrange=[0.2,1.4],ystyle=3,xstyle=3,diff(*,256),ytitle='mag difference'
end
