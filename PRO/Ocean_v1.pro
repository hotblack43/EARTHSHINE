FUNCTION minimize_me,s,pars
;common space_time_and_their_opposites,x,time,z,s
common complexities,theta_x0_t0,theta_x_t0,f,f_s,theta_0_z,LHS
h=pars(0)
lamda=pars(1)
kappa=pars(2)
;
thingy=0.0	; for now! it is really the Z-transfor of the
		;profile evaluated at sqrt(s/kappa)
RHS=(h*theta_x0_t0+f_s+thingy)/(h*s+lamda+sqrt(kappa*s))
minimize_me=total((LHS-RHS)*conj(LHS-RHS))
return,RHS
end

FUNCTION laptrsf_onevalue,z_or_svalue,f,x_or_t
; Performs a forward Laplace transform of Joe's type for one value of z
y=f*exp(-x_or_t*z_or_svalue)
realpart=int_tabulated(x_or_t,float(y))
imagpart=int_tabulated(x_or_t,imaginary(y))
onevalue=complex(realpart,imagpart)
return,onevalue
end

FUNCTION forwLaplace,f,x_or_t,z_or_s
n=n_elements(z_or_s)
laptrsf=dcomplexarr(n)
for i=0,n-1,1 do begin
	laptrsf(i)=laptrsf_onevalue(z_or_s(i),f,x_or_t)
endfor
return,laptrsf
end

;===================================================
;  Laplace Transform Solution to mixed-layer ocean + diffusive deep ocean.
;
common complexities,theta_x0_t0,theta_x_t0,f,f_s,theta_0_z,LHS
common space_time_and_their_opposites,x,time,z,s
; restore Bos numerical simulation
restore,'slabocean_test.sav'
;..................................................................
;Forcing 	- F               			Array[3650]
;Time		- TIME            			Array[3650]
;		- T_DIFFUSIVE_NOW (T profile at end) 	Array[400]
;theta_x_t0	Note that profile at start was 0 everywhere
;theta		- T_SLAB          (T at surface) 	Array[3650]
;Depth		- X		  			Array[400]
;..................................................................
f=rebin(f,365)
time=rebin(time,365)
t_slab=rebin(t_slab,365)
Nx=n_elements(X)
Nt=n_elements(TIME)
; set theta_x0_t0 which is T_DIFFUSIVE_NOW at x=0
theta_x0_t0=T_DIFFUSIVE_NOW(0)
; set theta_x_t0 the temperature profile at time=0
theta_x_t0=x*0.0
; set theta at the surface
theta_t_x0=T_SLAB
; get f the forcing
f=F
;...................................................................
; set up the frequency s
s=complex(0,1)*dindgen(Nt)/float(Nt)
z=complex(0,1)*dindgen(Nx)/float(Nx)
; get f transform f_S
help,f,TIME,s
f_S=forwLaplace(f,TIME,s)
; do S transform of LHS
LHS=forwLaplace(theta_t_x0,TIME,s)
;...................................................................
; set up the input to the solver
start_parms=[randomu(seed,3)*10.] ; these are h,lamda,kappa starting guesses
; set up the PARINFO array - indicate double-sided derivatives (best)
 parinfo = replicate({value:0.D, fixed:0, limited:[1,1], limits:[0.0D0,10000.0],relstep:1.0d-5}, 3)

; parinfo[0].fixed = 0
parinfo[0].value = 10.
parinfo[0].limited(0) = 1
parinfo[0].limited(1) = 1
parinfo[0].limits(0)  = 0.0
parinfo[0].limits(1)  = 20.0
;
; parinfo[1].fixed = 0
parinfo[1].value = 3.8
parinfo[1].limited(0) = 1
parinfo[1].limited(1) = 1
parinfo[1].limits(0)  = 0.0
parinfo[1].limits(1)  = 10.
;
; parinfo[2].fixed = 0
parinfo[2].value = 3.8e-4
parinfo[2].limited(0) = 1
parinfo[2].limited(1) = 1
parinfo[2].limits(0)  = 0.0
parinfo[2].limits(1)  = 1.

;parinfo[*].value = start_parms
; go ahead and minimize
ERR=LHS*1.0e-2
RESULTS = MPFITFUN('minimize_me', s, LHS, ERR, PARINFO=parinfo,maxiter=2000)
; Print the solution point:
PRINT, 'Solution point: ', results
end
