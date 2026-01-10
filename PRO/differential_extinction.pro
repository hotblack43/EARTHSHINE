FUNCTION airmass,z
airmass=1.0/cos(z*!dtor)
return,airmass
end

FUNCTION flux,m
flux=10^(-m/2.5)
return,flux
end

w=1.5	; width of field in degrees
k=0.271
dk=0.02
count=0
z=findgen(70)
!P.MULTI=[0,1,3]
d_extinction=k*airmass(z-w/2.)-k*airmass(z+w/2.)
plot,z,d_extinction,xtitle='Zenith angle (degrees)',ytitle='!7D!3m (mags)',title='!7D!3 extinction across 1.5 degree field'
fluxval=flux(d_extinction)
lower_d_extinction=(k+dk)*(airmass(z-w/2.)-airmass(z+w/2.))
lower_flux=flux(lower_d_extinction)
oplot,z,lower_d_extinction,linestyle=2
upper_d_extinction=(k-dk)*(airmass(z-w/2.)-airmass(z+w/2.))
upper_flux=flux(upper_d_extinction)
oplot,z,upper_d_extinction,linestyle=2
xyouts,/data,10,-0.02,'For k!dB!n=0.271 +/- 0.01',charsize=1.4
uncert_delta_ext=upper_d_extinction-lower_d_extinction
plot,z,uncert_delta_ext,xtitle='Zenith angle (degrees)',ytitle='!7D!3!ds!nm (mags)'
plot,z,(upper_flux-lower_flux)/fluxval*100.,xtitle='Zenith angle (degrees)',ytitle='Flux difference in % across field'
plots,[!X.crange],[-0.1,-0.1],linestyle=3
end
