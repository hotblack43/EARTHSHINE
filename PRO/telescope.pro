scale=8
n=1000
x1prime=(indgen(n))/float(n)*scale+0.0023
dprime=2.+x1prime+1./x1prime
y2prime=1./x1prime
plot,dprime,y2prime,xtitle="D' (x1+2f+x2)/f ",ytitle="I'/I",charsize=1.8,xrange=[0,10],yrange=[0,1],psym=3
plots,[0,4.5],[0.5,0.5],linestyle=2
plots,[4.5,4.5],[0.5,0.],linestyle=2
plots,[0,5.3333],[0.3333,0.3333],linestyle=2
plots,[5.3333,5.3333],[0.3333,0.],linestyle=2
end
