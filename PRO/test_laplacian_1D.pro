!P.MULTI=[0,1,2]
n=100
x=1./(findgen(100)^3)
x(25:99)=1
x(75:99)=x(75:99)+3.
plot,x,ystyle=3
oplot,x/2.,color=fsc_color('red')
;
lap= CONVOL( x, [-1,2,-1])
plot,lap
lap=CONVOL( x/2., [-1,2,-1])
oplot,lap,color=fsc_color('red'),thick=3
;
plot_io,abs(lap)
end
