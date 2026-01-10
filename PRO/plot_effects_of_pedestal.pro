file='effects_of_pedestal.dat'
data=get_data(file)
ped=reform(data(0,*))
alfa=reform(data(1,*))
offset=reform(data(2,*))
!P.MULTI=[0,2,2]
plot,psym=7,ped,alfa,xtitle='Added pedestal',ytitle='!7a!3',ystyle=3,xstyle=3
plot,psym=7,ped,offset,xtitle='Added pedestal',ytitle='Offset',ystyle=3,xstyle=3
oplot,ped,ped
plot,xrange=[9,15],psym=7,ped,alfa,xtitle='Added pedestal',ytitle='!7a!3',ystyle=3,xstyle=3
plot,xrange=[9,15],psym=7,ped,offset-ped,xtitle='Added pedestal',ytitle='Offset',ystyle=3,xstyle=3
end
