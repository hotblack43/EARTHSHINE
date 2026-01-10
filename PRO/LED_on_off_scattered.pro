path='/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455641/'
dark=readfits(path+'meanhalfmedian_dark.fits')
;
LEDON_stack=readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455641/2455641.6396417Moon-CoAdd-SKE-MoonRightside-LEDON.fits')
LEDOF_STACK=readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455641/2455641.6402639Moon-CoAdd-SKE-MoonRightside.fits')
imon=LEDON_stack(*,*,0);-dark
imof=LEDOF_stack(*,*,0);-dark
projected_on=avg(imon,1)
projected_of=avg(imof,1)
!P.multi=[0,1,2]
factor=1.62
factor=1.0045
plot,projected_on,xtitle='Column #',title='LED on vs. off (red)',$
ytitle='Row-average intensity after DF subtracted'
oplot,projected_of/factor,color=fsc_color('red')
oplot,[254,254],[!Y.CRANGE]
pctdiff=(projected_on-projected_of/factor)/projected_on*100.0
plot,pctdiff,ytitle='% difference',ystyle=1
oplot,[!X.crange],[0,0]
end
