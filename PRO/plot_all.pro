; plot all files relevant to fitting model to lunar image
observed=readfits('observed.fit')
;
residuals_HAPKE=readfits('diffH.fit')
HAPKE_FITTED=readfits('HAPKE_fitted.fit')
;
residuals_LAMBERT=readfits('diffL.fit')
lambert_FITTED=readfits('LAMBERT_fitted.fit')
l=size(residuals_HAPKE,/dimensions)
!P.MULTI=[0,2,3]
; real and fitted
row=observed(*,100)
plot,row,ystyle=1,ytitle='Intensity in row',title='Original and HAPKE (red)',xtitle='Row #'
row=HAPKE_FITTED(*,100)
oplot,row,color=FSC_color('RED')
; real and fitted
row=observed(*,100)
plot,row,ystyle=1,ytitle='Intensity in row',title='Original and LAMBERT (red)',xtitle='Row #'
row=LAMBERT_FITTED(*,100)
oplot,row,color=FSC_color('RED')
; residuals
row1=residuals_HAPKE(*,100)
row2=residuals_LAMBERT(*,100)
plot,row1,yrange=[min([row1,row2]),max([row1,row2])],ystyle=1,ytitle='Residual in row',title='HAPKE',xtitle='Row #'
plot,row2,yrange=[min([row1,row2]),max([row1,row2])],ystyle=1,ytitle='Residual in row',title='LAMBERT',xtitle='Row #'
end
