original=readfits('/data/pth/DARKCURRENTREDUCED/HAVEBEENSUMMED/2455858.1010291MOON_B_AIR_DCR.fits')
efm=readfits('/data/pth/DARKCURRENTREDUCED/EFM_CLEANED/DS_by_EFM_2455858.1010291MOON_B_AIR_DCR.fits')
log=readfits('/data/pth/DARKCURRENTREDUCED/BBSO_CLEANED_LOG/2455858.1010291MOON_B_AIR_DCR_INDIADD.fits')
linear=readfits('/data/pth/DARKCURRENTREDUCED/BBSO_CLEANED/2455858.1010291MOON_B_AIR_DCR_INDIADD.fits')
!P.CHARSIZE=2
!P.THICK=2
!x.THICK=2
!y.THICK=2
plot,xstyle=3,avg(original(*,246:266),1),yrange=[-3,20]
oplot,avg(efm(*,246:266),1),color=fsc_color('red')
oplot,avg(log(*,246:266),1),color=fsc_color('blue')
oplot,avg(linear(*,246:266),1),color=fsc_color('green')
print,'Mean in box original: ',mean(original(20:40,246:266)),std(original(20:40,246:266))/sqrt(n_elements(original(20:40,246:266)))
print,'Mean in box log     : ',mean(log(20:40,246:266)),std(log(20:40,246:266))/sqrt(n_elements(log(20:40,246:266)))
print,'Mean in box linear  : ',mean(linear(20:40,246:266)),std(linear(20:40,246:266))/sqrt(n_elements(linear(20:40,246:266)))
print,'Mean in box EFM     : ',mean(efm(20:40,246:266)),std(efm(20:40,246:266))/sqrt(n_elements(efm(20:40,246:266)))

end
