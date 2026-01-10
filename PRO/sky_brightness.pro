PRO schaeffer_model
rhostart=1.0
rhostop=40.0
rhostep=0.1
n=(rhostop-rhostart)/rhostep
x=fltarr(n)+9999
y1=fltarr(n)
y2=fltarr(n)
i=0
for rho=rhostart,rhostop-rhostep,rhostep do begin	; loop over Moon-sky separations in degrees
f_large_angle=10^(6.15-rho/40.)
f_small_angle=6.2e7*rho^(-2)
x(i)=rho
y1(i)=f_large_angle
y2(i)=f_small_angle
i=i+1
endfor						; end of rho loop
idx=where(x ne 9999)
x=x(idx)
rho=x
f_large_angle=y1(idx)
f_small_angle=y2(idx)
idx=where(f_small_angle gt f_large_angle)
jdx=where(f_small_angle le f_large_angle)
plot_oi,rho(idx),f_small_angle(idx),title='small angle: solid, large angle: dashed',ytitle='f(rho)',xtitle='rho (degrees)',xrange=[1,rhostop*1.1]
oplot,rho(jdx),f_large_angle(jdx),linestyle=2
return
end

schaeffer_model
end
