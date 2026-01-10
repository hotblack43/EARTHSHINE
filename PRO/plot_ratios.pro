openr,2,'JDmaxmin.dat'
readf,2,jdmax,jdmin
close,2
file='ratios.dat'
data=get_data(file)
ph_e=reform(data(0,*))
mbox1=reform(data(1,*))
mbox2=reform(data(2,*))
ratio1=reform(data(3,*))
ratio2=reform(data(4,*))
deltapct=abs(reform(data(5,*)))
moon_alt=abs(reform(data(6,*)))
sun_alt=abs(reform(data(7,*)))
!P.MULTI=[0,1,2]
plot,ph_e,deltapct,xtitle='Phase angle!dE!n',ytitle='Digitization error [%]',charsize=2,psym=7,/ylog,xrange=[-180,180],xstyle=1,yrange=[1e-2,1000]
plot,ph_e,mbox1,/ylog,xtitle='Phase angle!dE!n',ytitle='mean int. box 1 & 2 (red)',charsize=2,psym=7,yrange=[1e-4,1e6],xrange=[-180,180],xstyle=1
oplot,ph_e,mbox2,psym=6   ; color=fsc_color('red'),psym=6
;plot,ph_e,moon_alt,xtitle='Phase angle!dE!n',ytitle='Altitudes',charsize=2,psym=7,title='Moon (black), Sun (red)',xrange=[-180,180],xstyle=1
;oplot,ph_e,sun_alt,psym=5   ;   color=fsc_color('red'),psym=5
end
