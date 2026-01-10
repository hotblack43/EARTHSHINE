!P.MULTI=[0,1,3]
N=10000
x=randomn(seed,n)
y=randomn(seed,n)
y=sqrt(abs(y)+2)
ytoplot=y
hx=histogram(x,min=-5,max=5,binsize=0.1)
hy=histogram(y,min=-5,max=5,binsize=0.1)
plot,hx,thick=2,xstyle=1,title='Original distributions',charsize=2
oplot,hy
;-----------
ynew=pdf_convert_pth(x,y)
hynew=histogram(ynew,min=-5,max=5,binsize=0.1)
plot,hx,thick=2,xstyle=1,title='Transformed distributions',charsize=2
oplot,hynew
;
plot,y,ynew,psym=3,charsize=2,xtitle='Old series',ytitle='New series'
end
