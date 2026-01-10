; plot
!P.MULTI=[0,1,1]
data=get_data('data.plt')
x=reform(data(0,*))
y=reform(data(1,*))
z=reform(data(2,*))
idx=where(y ne 0)
plot,x(idx),y(idx),xtitle='Mean Poisson distributed flux count',ytitle='Number of pixels at 1% error.',charsize=1.6,xstyle=1,ystyle=1,title='Simulation, ideal case (dot-dashed)'
oplot,x(idx),z(idx)
oplot,x(idx),100.*100./x(idx),linestyle=4
end

