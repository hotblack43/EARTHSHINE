PRO plotbox,data
xL=reform(data(0))
xR=reform(data(1))
yD=reform(data(2))
yU=reform(data(3))
oplot,[xl,xl],[yd,yu],color=fsc_color('red')
oplot,[xl,xr],[yu,yu],color=fsc_color('red')
oplot,[xr,xr],[yu,yd],color=fsc_color('red')
oplot,[xr,xl],[yd,yd],color=fsc_color('red')
return
end

; WIll generate a 1-page report on what is going on
mask=readfits('mask.fits',/SIL)
observed=readfits('presentinput.fits',/SIL)
best=readfits('bestdifference.fits',/SIL)
ideal=readfits('ideal_unpadded.fits',/SIL)
!P.MULTI=[0,2,3]
!P.CHARSIZE=1.2
n=64
obs=histomatch(smooth(observed,21,/edge_truncate),findgen(256)*0+1)
contour,rebin(obs,n,n),xstyle=1,ystyle=1,/isotropic,nlevels=7,title='Observed'
;contour,/overplot,rebin(obs,n,n),xstyle=1,ystyle=1,/isotropic,nlevels=11
;
contour,mask,xstyle=1,ystyle=1,/isotropic,title='Mask and DS, BS boxes'
data=get_data('boxes.dat')
plotbox,data(0:3)
plotbox,data(4:7)
;
contour,rebin(ideal,n,n),xstyle=1,ystyle=1,/isotropic,title='Ideal'
;
contour,rebin(best,n,n),xstyle=1,ystyle=1,/isotropic,title='Difference'
;
openr,1,'justthefilename.txt'
s=''
readf,1,s
close,1
xyouts,/normal,0.1,0.32,'Filename: '+s
;
data=get_data('coords.dat')
x0=reform(data(0,*))
y0=reform(data(1,*))
radius=reform(data(2,*))
xyouts,/normal,0.1,0.30,strcompress('x0,y0,radius of disc: '+string(x0)+string(y0)+string(radius))
;
data=get_data('bestalfa.dat')
err=reform(data(0,*))
alfa=reform(data(1,*))
xyouts,/normal,0.1,0.28,strcompress('Err & alfa: '+string(err)+string(alfa))
;
data=get_data('ratio_and_relerr.dat')
ratio=reform(data(0,*))
pcterr=reform(data(1,*))
xyouts,/normal,0.1,0.26,strcompress('DS/BS & % err: '+string(ratio)+string(pcterr))

end

