file='plotme3.dat'
data=get_data(file)
d1=reform(data(0,*))
elatsun=reform(data(1,*))
elatmoon=reform(data(2,*))
phase=reform(data(3,*))
orient=reform(data(4,*))
; d1,Elat_sun,Elat_moon*!dtor,k,(Elong_moon gt Elong_sun)
!P.MULTI=[0,1,1]
plot,phase,yrange=[-2,6],ytitle='k and delong'
oplot,d1,linestyle=2
oplot,orient,linestyle=4
oplot,elatmoon,linestyle=5
plot,elatmoon
oplot,orient,linestyle=5
end