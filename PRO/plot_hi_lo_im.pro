;ideal=readfits('basic_ideal_image_nearNEWmoon.fits')
;im=readfits('hi_lo_im_nearNEWmoon.fits')
ideal=readfits('basic_ideal_image_nearHALFmoon.fits')
im=readfits('hi_lo_im_nearHALFmoon.fits')
;
line=im(*,256)
line1=line(0:511)
line2=line(512:1023)
!P.MULTI=[0,1,1]
;!P.MULTI=[0,2,2]
!X.style=3
!y.style=3
!P.charsize=2
!P.charthick=4
!P.thick=4
!x.thick=3
!y.thick=3
x=findgen(512)
yran=[0.0001,200]
plot_io,yrange=yran,x,line1,xtitle='Image column #',ytitle='Intensity',/nodata,$
    title='!7a!3!dPSF!n=3 (blue) and 2.7 (red)'
oplot,x,ideal(*,256)
oplot,x,line2,color=fsc_color('red')
oplot,x,line1,color=fsc_color('blue')
end

; use regression on DS sky to remove halo
res=linfit(x(450:511),line1(450:511),yfit=yhat)
yhat=res(0)+res(1)*x
oplot,x(200:511),yhat(200:511),color=fsc_color('green')
clean1=line1-yhat
res=linfit(x(450:511),line2(450:511),yfit=yhat)
yhat=res(0)+res(1)*x
oplot,x(200:511),yhat(200:511),color=fsc_color('orange')
clean2=line2-yhat
; plot difference in %
plot,yrange=[-10,30],x,(line2-line1)/(0.5*(line1+line2))*100,xtitle='Image column #',ytitle='% difference'
pctdiff=(line2-line1)/(0.5*(line1+line2))*100
oplot,[!x.crange],[0,0],linestyle=1
;
plot_io,yrange=[yran],x,clean1,xtitle='Image column #',ytitle='Intensity',/nodata
oplot,x,clean2,color=fsc_color('red')
oplot,x,clean1,color=fsc_color('blue')
; plot difference in %
plot,yrange=[-10,30],x,(clean2-clean1)/(0.5*(clean1+clean2))*100,xtitle='Image column #',ytitle='% difference'
oplot,[!x.crange],[0,0],linestyle=1
oplot,x,pctdiff,linestyle=2
end
