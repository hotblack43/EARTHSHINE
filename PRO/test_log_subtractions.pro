x=findgen(100)/12.3+.3
noise=randomn(seed,n_elements(x))
y=10.2+3.4/x^1.8+noise
plot_oi,x,y,xstyle=3,ystyle=3
res=linfit(alog10(x),y,/double,yfit=yhat)
oplot,x,yhat
residuals=y-yhat
end
