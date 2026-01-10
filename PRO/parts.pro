FUNCTION LapTrsf_OneValue,z_or_svalue,f,x_or_t
; Performs a Laplace transform for one value of z
y=f*exp(-x_or_t*z_or_svalue)
realpart=int_tabulated(x_or_t,float(y),/double)
imagpart=int_tabulated(x_or_t,imaginary(y),/double)
onevalue=complex(realpart,imagpart)
return,onevalue
end

FUNCTION Laplace,f,x_or_t,z_or_s
n=n_elements(z_or_s)
laptrsf=dcomplexarr(n)
for i=0,n-1,1 do laptrsf(i)=LapTrsf_OneValue(z_or_s(i),f,x_or_t)
return,laptrsf
end

PRO plot4,s,LHS,RHS,start_parms
common physics,rho,Cp
!P.MULTI=[0,1,4]
;
plot_oi,imaginary(s),double(LHS),title='Real part',xrange=[1e-10,max(imaginary(s))],xstyle=1,charsize=3
oplot,imaginary(s),double(RHS),color=fsc_color('red')
xyouts,/normal,0.15,0.925,'h = '+string(start_parms(0))
xyouts,/normal,0.15,0.9,'!7k!3 = '+string(start_parms(1)*(rho*Cp))
xyouts,/normal,0.15,0.875,'!7j!3 = '+string(start_parms(2))
;
plot_oi,imaginary(s),(double(LHS)-double(RHS))/double(LHS)*100.0,ytitle='% error',title='Residuals: Real part',xrange=[1e-10,max(imaginary(s))],xstyle=1,charsize=3
;
plot_oi,imaginary(s),imaginary(LHS),title='Imaginary part',xrange=[1e-10,max(imaginary(s))],xstyle=1,charsize=3
oplot,imaginary(s),imaginary(RHS)
;
plot_oi,imaginary(s),(imaginary(LHS)-imaginary(RHS))/imaginary(LHS)*100.0,ytitle='% error',title='Residuals: Imaginary part',xrange=[1e-10,max(imaginary(s))],xstyle=1,charsize=3
;
return
end

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
;  version 5 - introduced the straight Laplace transform for use in
; expressing the depth profile as a laplace transform, rather than a
; series expansion.
common complexities,theta_x0_t0,f,f_Joe_s,theta_0_z,LHS,RHS
common space_time_and_their_opposites,x,time,z,s
common physics,rho,Cp
openw,3,'Ocean_results.dat'
nits=1
for iter=0,nits-1,1 do begin

rho=1005.
Cp=4.1813e3
; restore Bos numerical simulation
;restore,'slabocean_test_2.sav'
;restore,'slabocean_test3.sav'
restore,'slabocean_newtest.sav'
;..................................................................
;Forcing 	- F               			Array[3650]
;Time		- TIME            			Array[3650]
;		- T_DIFFUSIVE_NOW (T profile at end) 	Array[400]
;theta		- T_SLAB          (T at surface) 	Array[3650]
;Depth		- X		  			Array[400]
;..................................................................
theta_0_z=T_DIFFUSIVE_NOW
; rebin to annual values
if_annual_rebin=0
if (if_annual_rebin eq 1) then begin
	F=rebin(F,365)
	TIME=Rebin(TIME,365)
	T_SLAB=REBIN(T_SLAB,365)
endif
;
Nt=n_elements(TIME)
Nx=n_elements(X)
;
depth_span=max(abs(X))-min(abs(x))

; shift in time
time=time-max(time)
time_span=max(time)-min(time)
; cut stuff off the front of the series
from=Nt/5.
from=0
to=Nt-1
F=F(from:to)
Time=Time(from:to)
T_SLAB=T_SLAB(from:to)
; set theta_x0_t0 which is T_DIFFUSIVE_NOW at x=0
theta_x0_t0=T_DIFFUSIVE_NOW(0)
;;theta_x0_t0=T_SLAB(Nt-1)
; set theta at the surface
theta_t_x0=T_SLAB
; get f the forcing
f=F/(rho*Cp)
;...................................................................
; set up the frequency s
array=(1+dindgen(Nt))/(time_span)
sarray=array(sort(array))
s=complex(0,1)*sarray     ;   +1e-8
zarray=(1+dindgen(NX))/(depth_span)
z=complex(0,1)*zarray
; get f transform f_Joe_s
f_Joe_s=JoeLaplace(f,TIME,s)
; do S transform of LHS
LHS=JoeLaplace(theta_t_x0,TIME,s)
;...................................................................
; set up the input to the solver
start_parms=[60.639172,  4.8747334e-07,  0.00029165780 ] ; these are h,lamda/(rho*Cp),kappa starting guesses
Xi=[[0,0,1],[0,1,0],[1,0,0]]
Ftol=1e-9
POWELL, start_parms, Xi, Ftol, Fmin, 'minimize_me' , /DOUBLE ; , ITER=variable] [, ITMAX=value]
PRINT, 'Solution point, min: ', start_parms,fmin
print,'Rescaled solutions:'
print,'h:',start_parms(0)
print,'lamda:',start_parms(1)*(rho*Cp)
print,'kappa:',start_parms(2)
!P.MULTI=[0,1,4]
plot4,s,LHS,RHS,start_parms
print,format='(3(g12.5,1x))',Xi
!P.MULTI=[0,1,4]
plot4,s,LHS,RHS,start_parms
printf,3,format='(3(1x,g20.10))',start_parms(0),start_parms(1)*(rho*Cp),start_parms(2)
endfor	; end of its loop
close,3
end
