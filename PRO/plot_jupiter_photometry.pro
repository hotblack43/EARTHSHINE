!P.MULTI=[0,1,5]
file='jupiter_photometry.dat'
data=get_data(file)
numb=reform(data(0,*))
Vflux=reform(data(3,*))
sky=reform(data(4,*))
plot,numb,sky,xtitle='Image #',ytitle='Annulus count',charsize=2,xstyle=3,title='Sky'
plot,numb,Vflux,xtitle='Image #',ytitle='V filter counts',charsize=2,xstyle=3,title='Jupiter'
idx=where(Vflux gt 8.5e5)
plot,ystyle=3,numb(idx),Vflux(idx),title='Jupiter, After selection',xtitle='Image #',ytitle='V filter counts',charsize=2,xstyle=3
print,'Jupiter S.D. of Vflux: ',stddev(Vflux(idx))
print,'Jupiter S.D. relative to Vflux in pct: ',stddev(Vflux(idx))/mean(Vflux(idx))*100.0
plot,ystyle=3,numb(idx),sky(idx),title='Sky, After selection',xtitle='Image #',ytitle='Sky annulus count',charsize=2,xstyle=3
res=poly_fit(numb(idx),sky(idx),6,yfit=yhat_sky)
oplot,numb(idx),yhat_sky,color=fsc_color('red')
; remove any linear trends
res=linfit(numb(idx),Vflux(idx),/double,yfit=yhat)
plot,ystyle=3,numb(idx),Vflux(idx)-yhat+mean(Vflux(idx)),title='Jupiter, After selection and detrending',xtitle='Image #',ytitle='V filter counts',charsize=2,xstyle=3
print,'Sky S.D. after selection; ',stddev(sky(idx))/mean(sky(idx))*100.,' in pct.'
print,'Sky S.D. after poly_fit; ',stddev(sky(idx)-yhat_sky)/mean(sky(idx))*100.,' in pct.'
print,'Jupiter S.D. of Vflux: ',stddev(Vflux(idx)-yhat)
print,'Jupiter S.D. relative to Vflux in pct: ',stddev(Vflux(idx)-yhat)/mean(Vflux(idx))*100.0
n_MC=10000
       iflag=1
       array1=Vflux(idx)
       array2=sky(idx)-yhat_sky
       mc_correlate,array1,array2,MC_siglevel,n_MC,R,iflag
print,' R(Jupiter, Sky): ',R,' at S.L. ',100-MC_siglevel,' %.'
end
