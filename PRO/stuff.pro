FUNCTION minimize_me,pars
common space_time_and_their_opposites,x,time,z,s
common complexities,theta_x0_t0,f,f_Joe_s,theta_0_z,LHS,RHS
; unpack the parameter guesses
h=pars(0)
lamda=pars(1)
kappa=pars(2)
;
; for now just give a0 and gamma0 here
; test
a0=0.34603562
gamma0=0.0019425025
;test_2
;a0=0.33506321
;gamma0=0.0019327628

; One way to do the 'strange sum':
;StrangeSum=a0/(gamma0+sqrt(-s/kappa))
; other method:
StrangeSum=Laplace(theta_0_z,x,sqrt(-s/kappa))
RHS=(f_Joe_s-h*theta_x0_t0-StrangeSum)/(lamda-h*s+sqrt(-kappa*s))
!P.MULTI=[0,1,4]
plot4,s,LHS,RHS,pars
thing=double(total((LHS-RHS)*conj(LHS-RHS)))
print,' parameters, SSE:',thing,pars
return,thing
end

;...................................................................
; set up the input to the solver
start_parms=[75, 4.8425410e-07 , 0.0003] ; these are h,lamda/(rho*Cp),kappa starting guesses
Xi=[[0,0,1],[0,1,0],[1,0,0]]
Ftol=1e-9
POWELL, start_parms, Xi, Ftol, Fmin, 'minimize_me' , /DOUBLE ; , ITER=variable] [, ITMAX=value]
PRINT, 'Solution point, min: ', start_parms,fmin
print,'Rescaled solutions:'
print,'h:',start_parms(0)
print,'lamda:',start_parms(1)*(rho*Cp)
print,'kappa:',start_parms(2)
