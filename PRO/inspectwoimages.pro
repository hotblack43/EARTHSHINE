im1raw=readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2456030/2456031.0891887MOON_B_AIR.fits.gz')
im2raw=readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2456030/2456031.0778615MOON_B_AIR.fits.gz')
im1efm=readfits('EFMCLEANED_0p7MASKED/2456031.0891887MOON_B_AIR_DCR.fits')
im2efm=readfits('EFMCLEANED_0p7MASKED/2456031.0778615MOON_B_AIR_DCR.fits')
!P.MULTI=[0,1,2]
plot,yrange=[-0.5,2.5],avg(im1efm(0:80,*),0),title='EFM_cleaned images',xtitle='Row #',ytitle='Red: 2456031.0778615, black:2456031.0891887'
oplot,avg(im2efm(0:80,*),0),color=fsc_color('red')
sumim1raw=avg(im1raw,2)
sumim2raw=avg(im2raw,2)
plot,yrange=[394,398],avg(sumim1raw(0:80,*),0),title='AVG of RAW image stacks',xtitle='Row #',ytitle='Red: 2456031.0778615, black:2456031.0891887'
oplot,avg(sumim2raw(0:80,*),0),color=fsc_color('red')
end
