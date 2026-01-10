efm=readfits('/data/pth/DARKCURRENTREDUCED/SELECTED_1/EFMCLEANED_0p7MASKED/2456047.8598536MOON_B_AIR_DCR.fits')
stack=readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2456047/2456047.8598536MOON_B_AIR.fits.gz')
l=size(satck,/dimensions)
nx=13
ny=ceil(100./nx)
!P.MULTI=[0,nx,ny]
for i=0,100-1,1 do begin
im=reform(stack(*,*,i))
plot,avg(im(0:100,*),0),xstyle=3,ystyle=3
endfor
;
!p.MULTI=[0,1,2]
im=avg(stack,2)
plot,xtitle='Row number',title='Red: EFM-cleaned; Black: RAW image stack mean',avg(im(0:100,*),0),xstyle=3,ystyle=3
oplot,avg(efm(0:100,*),0)+398-0.27,color=fsc_color('red')
;

end
