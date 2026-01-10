restore,'aligned_stack.sav'
l=size(stack2,/dimensions)
n=l(2)
psf=total(stack2,3)/100.0d0
line=psf(*,253)
line=line(252:511)
plot_oo,line,xrange=[1,20],xstyle=1,yrange=[1,2e4],xtitle='Distance from center of psf (pixels)'
oplot,3e4/dindgen(20)^3.,color=fsc_color('red')
end
