FUNCTION minimize_me,pars
common space_time_and_their_opposites,x,time,z,s
common complexities,theta_x0_t0,f,f_Joe_s,theta_0_z,LHS,RHS
; unpack the parameter guesses
h=pars(0)
lamda=pars(1)
kappa=pars(2)
;
; for now just give a0 and gamma0 here
a0=0.346
gamma0=0.00194
;
StrangeSum=a0/(gamma0+sqrt(-s/kappa))
RHS=(f_Joe_s-h*theta_x0_t0-StrangeSum)/(lamda-h*s+sqrt(-kappa*s))
!P.MULTI=[0,1,2]
plot_oi,imaginary(s),double(LHS),title='Real part',xrange=[1e-10,max(imaginary(s))],xstyle=1
oplot,imaginary(s),double(RHS),color=fsc_color('red')
plot_oi,imaginary(s),imaginary(LHS),title='Imaginary part',xrange=[1e-10,max(imaginary(s))],xstyle=1
oplot,imaginary(s),imaginary(RHS),color=fsc_color('red')
thing=double(total((LHS-RHS)*conj(LHS-RHS)))
print,' parameters, SSE:',thing,pars
return,thing
end

FUNCTION JoeLapTrsf_OneValue,z_or_svalue,f,x_or_t
; Performs a Joe transform for one value of z
y=f*exp(x_or_t*z_or_svalue)
realpart=int_tabulated(x_or_t,float(y),/double)
imagpart=int_tabulated(x_or_t,imaginary(y),/double)
onevalue=complex(realpart,imagpart)
return,onevalue
end

FUNCTION JoeLaplace,f,x_or_t,z_or_s
n=n_elements(z_or_s)
laptrsf=dcomplexarr(n)
for i=0,n-1,1 do laptrsf(i)=JoeLapTrsf_OneValue(z_or_s(i),f,x_or_t)
return,laptrsf
end

;===================================================
;  Laplace Transform Solution to mixed-layer ocean + diffusive deep ocean.
;
common complexities,theta_x0_t0,f,f_Joe_s,theta_0_z,LHS,RHS
common space_time_and_their_opposites,x,time,z,s

openw,3,'Ocean_results.dat'
nits=100
for iter=0,nits-1,1 do begin
set_plot,'win

rho=1.0e3
Cp=4.1813e3
; restore Bos numerical simulation
;restore,'slabocean_test.sav'
restore,'slabocean_newtest.sav'
;..................................................................
;Forcing 	- F               			Array[3650]
;Time		- TIME            			Array[3650]
;		- T_DIFFUSIVE_NOW (T profile at end) 	Array[400]
;theta		- T_SLAB          (T at surface) 	Array[3650]
;Depth		- X		  			Array[400]
;..................................................................
Nt=n_elements(TIME)
Nx=n_elements(X)
;


; shift in time
time=time-max(time)
time_span=max(time)-min(time)

; set theta_x0_t0 which is T_DIFFUSIVE_NOW at x=0
theta_x0_t0=T_DIFFUSIVE_NOW(0)
; set theta at the surface
theta_t_x0=T_SLAB
; add a little noise
eps=0.05
theta_t_x0=theta_t_x0*(1.0d0+eps*randomn(seed,n_elements(theta_t_x0)))
; get f the forcing
f=F/(rho*Cp)
;...................................................................
; set up the frequency s
array=(0+dindgen(Nt))/(time_span)
array=array(sort(array))
s=complex(0,1)*array
;array=(0+dindgen(NX))/(time_span)
;z=complex(0,1)*array
; get f transform f_Joe_s
f_Joe_s=JoeLaplace(f,TIME,s)
; do S transform of LHS
LHS=JoeLaplace(theta_t_x0,TIME,s)
;...................................................................
; set up the input to the solver
start_parms=[randomu(seed,3)] ; these are h,lamda,kappa starting guesses
Xi=[[0,0,1],[0,1,0],[1,0,0]]
Ftol=1e-8
POWELL, start_parms, Xi, Ftol, Fmin, 'minimize_me' , /DOUBLE ; , ITER=variable] [, ITMAX=value]
PRINT, 'Solution point, min: ', start_parms,fmin
print,'Rescaled solutions:'
print,'h:',start_parms(0)
print,'lamda:',start_parms(1)*(rho*Cp)
print,'kappa:',start_parms(2)
!P.MULTI=[0,1,2]
plot_oi,imaginary(s),double(LHS),title='Real part',xrange=[1e-10,max(imaginary(s))],xstyle=1
oplot,imaginary(s),double(RHS),color=fsc_color('red')
xyouts,/normal,0.45,0.85,'h = '+string(start_parms(0))
xyouts,/normal,0.45,0.8,'!7k!3 = '+string(start_parms(1)*(rho*Cp))
xyouts,/normal,0.45,0.75,'!7j!3 = '+string(start_parms(2))
plot_oi,imaginary(s),imaginary(LHS),title='Imaginary part',xrange=[1e-10,max(imaginary(s))],xstyle=1
oplot,imaginary(s),imaginary(RHS),color=fsc_color('red')
print,format='(3(g12.5,1x))',Xi
set_plot,'ps
device,/color
device,xsize=18,ysize=24.5,yoffset=2
!P.MULTI=[0,1,2]
plot_oi,imaginary(s),double(LHS),title='Real part',xrange=[1e-10,max(imaginary(s))],xstyle=1
oplot,imaginary(s),double(RHS),color=fsc_color('red')
xyouts,/normal,0.45,0.85,'h = '+string(start_parms(0))
xyouts,/normal,0.45,0.8,'!7k!3 = '+string(start_parms(1)*(rho*Cp))
xyouts,/normal,0.45,0.75,'!7j!3 = '+string(start_parms(2))
plot_oi,imaginary(s),imaginary(LHS),title='Imaginary part',xrange=[1e-10,max(imaginary(s))],xstyle=1
oplot,imaginary(s),imaginary(RHS),color=fsc_color('red')
device,/close
printf,3,format='(3(1x,g20.10))',start_parms(0),start_parms(1)*(rho*Cp),start_parms(2)
endfor	; end of its loop
close,3
end
