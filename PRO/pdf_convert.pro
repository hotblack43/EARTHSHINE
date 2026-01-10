FUNCTION pdf_convert_pth,x,y
; transform y to the pdf that x has
nbins=1000.
maxv=max([x,y])
minv=min([x,y])
binsize=(maxv-minv)/nbins
t=findgen(nbins)*binsize+minv
x_cumul=hist_equal(x,/histogram_only,maxv=maxv,minv=minv,binsize=binsize)
y_cumul=hist_equal(y,/histogram_only,maxv=maxv,minv=minv,binsize=binsize)
t=findgen(n_elements(y_cumul))*binsize+minv
bosnyd=interpol(y_cumul,t,y);,/spline)
new=interpol(t,x_cumul,bosnyd);,/spline)
return,new
end


