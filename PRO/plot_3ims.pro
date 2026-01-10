!P.charsize=1.3
!P.thick=4
!P.charthick=3
x0=227.71
y0=191.46
im1=readfits('/media/thejll/OLDHD/ASTRO/EARTHSHINE/data/pth/DARKCURRENTREDUCED/SELECTED_10/BBSO_CLEANED/2456091.1056433MOON_IRCUT_AIR_DCR.fits')
im1=shift(im1,256-x0,256-y0)
im2=readfits('/media/thejll/OLDHD/ASTRO/EARTHSHINE/data/pth/DARKCURRENTREDUCED/SELECTED_10/2456091.1056433MOON_IRCUT_AIR_DCR.fits')
totfl=total(im2,/double)
im2=shift(im2,256-x0,256-y0)
im3=readfits('/media/thejll/OLDHD/ASTRO/EARTHSHINE/data/pth/DARKCURRENTREDUCED/SELECTED_10/BBSO_CLEANED_LOG/2456091.1056433MOON_IRCUT_AIR_DCR.fits')
im3=shift(im3,256-x0,256-y0)
ideal=readfits('./OUTPUT/IDEAL/ideal_image_JD2456091.0300958.fits')
ideal=reverse(ideal)/total(ideal,/double)*totfl
plot,xrange=[31,250],im1(*,256),ystyle=3,yrange=[-1,10],xstyle=3,xtitle='Image column #',ytitle='Counts'
oplot,im2(*,256),color=fsc_color('red')
oplot,im3(*,256),color=fsc_color('green')
oplot,0.32*ideal(*,256),color=fsc_color('blue')
oplot,[!X.crange],[0,0]
end

