file='best_altitude.dat'
data=get_data(file)
help
sunalt=reform(data(1,*))
alt=reform(data(0,*))
plot,sunalt,alt,xtitle='Solar altitude',ytitle='Alt of darkest spot (antisolar az.)',charsize=1.3,ystyle=1
idx=where(sunalt lt 40)
res=linfit(sunalt(idx),alt(idx),/double,yfit=yhat)
oplot,sunalt(idx),yhat,thick=2
end

