file='lon_lat_clem_wild_2p5x2p5.txt'
;file='lon_lat_clem_wild_5x5.txt'
data=get_data(file)
lon=reform(data(0,*))
lat=reform(data(1,*))
Clem=reform(data(2,*))
Wild=reform(data(3,*))
!P.CHARSIZE=2
plot,Clem,Wild,/isotropic,psym=3,xtitle='Clementine box-averaged albedo',ytitle='Wildey box-averaged albedo'
plots,[0,0.2],[0,0.2],linestyle=2
idx=where(Clem lt Wild)
Clem=Clem(idx)
Wild=Wild(idx)
oplot,Clem,Wild,color=fsc_color('green'),psym=4
; fit it
Result = ROBUST_POLY_FIT( Clem, Wild, 2, yhat )
oplot,Clem,yhat,color=fsc_color('red')
print,Result
end
