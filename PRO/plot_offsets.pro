data=get_data('offsets.dat')
x=reform(data(1,*))
y=reform(data(2,*))
plot,x,y,psym=7,xstyle=1,ystyle=1,charsize=1.2,$
xtitle='Drift in x (pixels)',ytitle='Drift in y (pixels)',$
title='Files in sequence CoAdd_100frame_rX.fits October 4 2010'
end

