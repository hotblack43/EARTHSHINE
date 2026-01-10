data=get_data('SKY_profile.dat')
r1=reform(data(0,*))
y1=reform(data(1,*))
!P.CHARSIZE=2
!X.THICK=2
!Y.THICK=2
!P.THICK=2
plot_oo,/NODATA,r1,y1,xrange=[1,200],xstyle=1,title='SKY profiles is red, SKE blue'
oplot,r1,y1,color=fsc_color('red'),psym=-7
data=get_data('SKE_profile.dat')
r2=reform(data(0,*))
y2=reform(data(1,*))
oplot,r2,y2,color=fsc_color('blue'),psym=-7
; plot a line to guide the eye
oplot,findgen(200),2000/findgen(200)^1.2
xyouts,3,4000,'Black line has slope -1.2',charsize=1.5
end


