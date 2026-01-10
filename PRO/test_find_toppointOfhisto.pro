ratio=readfits('ratio.fits')
minval=0.0
maxval=1.0
bins=0.001
h=histogram(ratio,min=minval,max=maxval,binsize=bins)
n=(maxval-minval)/bins+1
xx=findgen(n)/float(n)*(maxval-minval)+minval
plot,xx,h,psym=10
idx=where(xx gt 0.25 and xx lt 0.4)
print,median(xx(idx))
degree=2
res=poly_fit(xx(idx),h(idx),degree,yfit=yhat)
oplot,xx(idx),yhat,color=fsc_color('red')
toppoint=-res(1)/2.0d0/res(2)
print,'Top at: ',toppoint
oplot,[toppoint,toppoint],[!Y.crange],linestyle=0
end
