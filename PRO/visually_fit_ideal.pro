!P.MULTI=[0,1,2]
!P.thick=2
!P.CHARSIZE=1.3
!P.thick=2
!x.thick=2
!y.thick=2
file='/data/pth/CUBES/cube_MkIII_twoalfas_2456016.7917506_VE1_.fits'
im=readfits(file)
f=2e-9
tot=total(im(*,*,0),/double)*f
raw=im(*,*,0)/tot
efm=im(*,*,1)/tot
lin=im(*,*,2)/tot
log=im(*,*,3)/tot
ideal=im(*,*,4)/(total(im(*,*,4),/double)*f)
tstr=strmid(file,16,strlen(file))
; first find best fitting alfa
plot,ytitle='Counts [ADU]',xtitle='Column #',title=tstr,xrange=[0,300],xstyle=3,ystyle=3,avg(raw(*,246:266),1),yrange=[0,20]
oplot,[!X.crange],[0,0],linestyle=2
oplot,1.0+0.85*avg(ideal(*,246:266),1),color=fsc_color('purple')
; convolve the ideal model and replot
writefits,'infil.fits',ideal
;
str='./justconvolve infil.fits outfil.fits 1.7'
spawn,str
new_ideal=readfits('outfil.fits')
oplot,-.8+0.85*avg(new_ideal(*,246:266),1),color=fsc_color('red')
;
str='./justconvolve infil.fits outfil.fits 1.72'
spawn,str
new_ideal=readfits('outfil.fits')
oplot,-.5+0.85*avg(new_ideal(*,246:266),1),color=fsc_color('green')
;
str='./justconvolve infil.fits outfil.fits 1.74'
spawn,str
new_ideal=readfits('outfil.fits')
oplot,-.3+0.85*avg(new_ideal(*,246:266),1),color=fsc_color('orange')
xyouts,10,17,'Varying !7a!3'
;=======================================================
; now scale albedo for best fitting alfa
plot,ytitle='Counts [ADU]',xtitle='Column #',title=tstr,xrange=[0,300],xstyle=3,ystyle=3,avg(raw(*,246:266),1),yrange=[0,20]
oplot,[!X.crange],[0,0],linestyle=2
oplot,1.0+0.95*avg(ideal(*,246:266),1),color=fsc_color('purple')
; convolve the ideal model and replot
writefits,'infil.fits',ideal
;
str='./justconvolve infil.fits outfil.fits 1.72'
spawn,str
new_ideal=readfits('outfil.fits')
oplot,-.5+0.8*avg(new_ideal(*,246:266),1),color=fsc_color('orange')
oplot,-.6+0.9*avg(new_ideal(*,246:266),1),color=fsc_color('red')
oplot,-.7+1.0*avg(new_ideal(*,246:266),1),color=fsc_color('green')
;oplot,-.6+0.9*avg(new_ideal(*,246:266),1),color=fsc_color('blue')
xyouts,10,17,'Varying albedo for !7a!3=1.72'
end
