FUNCTION minimize_me,pars
common stuff,profile,x,rhs,rh1,rh2
a0=pars(0)
gamma0=pars(1)
a1=pars(2)
;gamma1=pars(3)
rh1=a0*exp(-gamma0*x)
rh2=a1*exp(-0.0019425*x)
rhs=rh1+rh2
SSE=total((profile-RHS)^2)
print,' parameters, SSE:',pars,SSE
return,SSE
end

common stuff,profile,x,rhs,rh1,rh2
; restore Bos numerical simulation
restore,'slabocean_test.sav'
profile=t_diffusive_now
;...................................................................
; set up the input to the solver
Ftol=1e-8
;start_parms=[randomu(seed,4)] ; these are h,lamda,kappa starting guesses
;Xi=[[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]]
start_parms=[randomu(seed,3)] ; these are h,lamda,kappa starting guesses
Xi=[[1,0,0],[0,1,0],[0,0,1]]
;start_parms=[randomu(seed,2)] ; these are h,lamda,kappa starting guesses
;Xi=[[1,0],[0,1]]

POWELL, start_parms, Xi, Ftol, Fmin, 'minimize_me' , /DOUBLE ; , ITER=variable] [, ITMAX=value]

PRINT, 'Solution point, min: ', start_parms,fmin
print,'Rescaled solutions:'
print,'a0:',start_parms(0)
print,'gamma0:',start_parms(1)
print,'a1:',start_parms(2)
;print,'gamma1:',start_parms(3)
plot_io,x,profile,title='T-profile and fits',xtitle='Depth (m)',ytitle='T'
oplot,x,rh1,color=fsc_color('red')
;oplot,x,rh2,color=fsc_color('blue')
;oplot,x,rhs,color=fsc_color('green')
end
