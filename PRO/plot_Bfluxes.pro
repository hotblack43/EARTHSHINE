data=get_data('holdBfluxes.dat')
tot=reform(data(0,*))
expt=reform(data(1,*))
am=reform(data(2,*))
ph=reform(data(3,*))
minval=reform(data(4,*))
geofac=reform(data(5,*))
type=reform(data(6,*))
help,data
; select good data
idx=where(tot gt 0 and minval gt -20); and am lt 3)
data=data(*,idx)
tot=reform(data(0,*))
expt=reform(data(1,*))
am=reform(data(2,*))
ph=reform(data(3,*))
minval=reform(data(4,*))
geofac=reform(data(5,*))
type=reform(data(6,*))
help,data
;
offset=0.010	; s - determined fromanalysis of two bias frames
fluxobs=tot/(expt-offset)
; correct for airmass
kB=0.1	; estimate only!
factor=10^(+kB*am/2.5)
flux=fluxobs*factor
flux=flux*geofac
plot_io,yrange=[1e7,1e12],ph,flux,xtitle='SEM',ytitle='AM-corrected flux',psym=7
kdx=where(type eq 2)
oplot,ph(kdx),flux(kdx),psym=4,color=fsc_color('yellow')
; get the LLAMAS data
data2=get_data('LLAMAS.dat')
LLAMASphase=reform(data2(0,*))-180
LLAMASflux=reform(data2(1,*))
idx=where(LLAMASphase lt -180)
LLAMASphase(idx)=LLAMASphase(idx)+360
oplot,LLAMASphase,LLAMASflux*4.5e12,psym=2,color=fsc_color('red')
end
