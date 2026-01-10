fitted_HAPKE=readfits('HAPKE_fitted.fit')
fitted_LAMBERT=readfits('LAMBERT_fitted.fit')
observed=readfits('observed.fit')
l=size(observed,/dimensions)
!P.MULTI=[0,1,2]
diffH=observed-fitted_HAPKE
diffL=observed-fitted_LAMBERT
writefits,'diffH.fit',diffH
writefits,'diffL.fit',diffL
levels=findgen(255)/128.*(max([diffL,diffH])-min([diffL,diffH]))+min([diffL,diffH])
print,'HAPKE fit:',moment(diffH)
print,'LAMBERT fit:',moment(diffL)
plot,observed(*,l(1)/2.),title='HAPKE and observed',xtitle='Columns',ytitle='Pixel value',/ylog
oplot,fitted_HAPKE(*,l(1)/2.),color=fsc_color('red')
plot,observed(*,l(1)/2.),title='LAMBERT and observed',xtitle='Columns',ytitle='Pixel value',/ylog
oplot,fitted_LAMBERT(*,l(1)/2.),color=fsc_color('red')
!P.MULTI=[0,2,3]
contour,/nodata,congrid(observed,128,128)
contour,congrid(observed,128,128),xstyle=1,ystyle=1,/isotropic,/cell_fill,levels=levels,title='Observed'
contour,congrid(fitted_LAMBERT,128,128),xstyle=1,ystyle=1,/isotropic,/cell_fill,levels=levels,title='Model, Lambert'
contour,congrid(fitted_HAPKE,128,128),xstyle=1,ystyle=1,/isotropic,/cell_fill,levels=levels,title='Model, Hapke'
contour,congrid(observed-fitted_HAPKE,128,128),xstyle=1,ystyle=1,/isotropic,/cell_fill,levels=levels,title='Obs-Model, Hapke'
contour,congrid(observed-fitted_LAMBERT,128,128),xstyle=1,ystyle=1,/isotropic,/cell_fill,levels=levels,title='Obs-Model, Lambert'
end
