 FUNCTION LapTrsf_OneValue,z_or_svalue,f,x_or_t
 ; Performs a Laplace transform for one value of z
 y=f*exp(-x_or_t*z_or_svalue)
 realpart=int_tabulated(x_or_t,float(y),/double)
 imagpart=int_tabulated(x_or_t,imaginary(y),/double)
 onevalue=complex(realpart,imagpart)
 return,onevalue
 end

 FUNCTION Laplace,f,x_or_t,z_or_s
 common sizes,n,nx,t
 laptrsf=dcomplexarr(n)
 for i=0,n-1,1 do laptrsf(i)=LapTrsf_OneValue(z_or_s(i),f,x_or_t)
 return,laptrsf
 end
 
 FUNCTION likelihood,h,lamda,kappa
 common space_time_and_their_opposites,x,time,z,s
 common complexities,theta_x0_t0,f,f_Joe_s,theta_0_z,LHS,RHS
 StrangeSum=Laplace(theta_0_z,x,sqrt(-s/kappa))
 RHS=(f_Joe_s-h*theta_x0_t0-StrangeSum)/(lamda-h*s+sqrt(-kappa*s))
;
 std2=1e16
 P=1.0d0
 diff=(LHS-RHS)
 diff2=double(diff*conj(diff))
 P=product(exp(-diff2/std2),/nan)
 PRINT,'p:',P,mean(diff2/std2)
 return,P
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
 common sizes,n,nx,t
 ;n=n_elements(z_or_s)
 laptrsf=dcomplexarr(n)
 for i=0,n-1,1 do laptrsf(i)=JoeLapTrsf_OneValue(z_or_s(i),f,x_or_t)
 return,laptrsf
 end
 
 PRO prepare_all
 ; Set up the Ocean diffusivity problem
 common complexities,theta_x0_t0,f,f_Joe_s,theta_0_z,LHS,RHS
 common space_time_and_their_opposites,x,time,z,s
 common physics,rho,Cp
 common sizes,n,nx,t
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
 if_annual_rebin=1
 if (if_annual_rebin eq 1) then begin
     nvalue=365
     F=rebin(F,nvalue)
     TIME=Rebin(TIME,nvalue)
     T_SLAB=REBIN(T_SLAB,nvalue)
     endif
 ;
 Nt=n_elements(TIME)
 Nx=n_elements(X)
 n=nt
 ;
 depth_span=max(abs(X))-min(abs(x))
 
 ; shift in time
 time=time-max(time)
 time_span=max(time)-min(time)
 ; cut
 from=0
 to=Nt-1
 F=F(from:to)
 Time=Time(from:to)
 T_SLAB=T_SLAB(from:to)
 ; set theta_x0_t0 which is T_DIFFUSIVE_NOW at x=0
 theta_x0_t0=T_DIFFUSIVE_NOW(0)
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
 return
 end
 
 FUNCTION parameter_update,a,scale
 ; takes a random walk step
 return,a+randomn(seed)*scale
 end
 
     PRO metropolis_randomwalk,ag,bg,cg,ivar,scale,yes,alpha
     ; calculate prob of current model fitted to data (p2)
     p2=likelihood(ag,bg,cg)
     ; generate a random-walk new guess for one of the parameters
     if (ivar eq 1) then  begin
	updated=parameter_update(ag,scale)
	p1=likelihood(updated,bg,cg)
     endif
     if (ivar eq 2) then  begin
	updated=parameter_update(bg,scale)
	p1=likelihood(ag,updated,cg)
     endif
     if (ivar eq 3) then  begin
	updated=parameter_update(cg,scale)
	p1=likelihood(ag,bg,updated)
     endif
     ; calculate prob of updated model fitted to data (p1)
     ; let alpha=min[1,p1/p2]
     alpha = min([1,p1/p2])
     ; draw u
     u=randomu(seed)
     ; if u le alpha accept new parameter
     if (u lt alpha) then begin
         if (ivar eq 1) then ag=updated
         if (ivar eq 2) then bg=updated
         if (ivar eq 3) then cg=updated
         yes=yes+1L
         endif
     return
     end
 
 ; =========================================
 ; model Ocean sensitivity with Metropolis-Hastings
 ; v1.
 common physics,rho,Cp
 ; set up the model situation
 prepare_all
 ;
 yes1=0L
 yes2=0L
 yes3=0L
 nloop=100L
 get_lun,w
 openw,w,'data.dat'
 
 ; generate starting guess for the parameters a and b
 start_parms=[75.639172,  4.8747334e-07,  0.00029165780 ] ; these are h,lamda/(rho*Cp),kappa starting guesses
 
 ag=start_parms(0) & ag_scale=60./7.
 bg=start_parms(1) & bg_scale=4e-7/3.
 cg=start_parms(2) & cg_scale=.0002/3.
 
 for iloop=0L,nloop-1,1 do begin
     printf,w,ag,bg,cg
     print,iloop,ag,bg,cg
;------------------------------------------------------------------------------
     metropolis_randomwalk,ag,bg,cg,1,ag_scale,yes1,alpha
     metropolis_randomwalk,ag,bg,cg,2,bg_scale,yes2,alpha2
     metropolis_randomwalk,ag,bg,cg,3,cg_scale,yes3,alpha3
;------------------------------------------------------------------------------
     print,alpha,alpha2,alpha3 
     endfor
 close,w
 free_lun,w
 print,'Acceptance rates : ',float(yes1)/float(nloop),float(yes2)/float(nloop),float(yes3)/float(nloop)
 
 data=get_data('data.dat')
 ag=reform(data(0,*))
 bg=reform(data(1,*))*rho*Cp
 cg=reform(data(2,*))
 !p.multi=[0,2,3]
 !P.charsize=2
 PLOT,AG,ystyle=1 & HISTO,AG,MIN(AG),MAX(AG),(MAX(AG)-MIN(AG))/10.
 PLOT,BG,ystyle=1 & HISTO,BG,MIN(BG),MAX(BG),(MAX(BG)-MIN(BG))/10.
 PLOT,CG,ystyle=1 & HISTO,CG,MIN(CG),MAX(CG),(MAX(CG)-MIN(CG))/10.
 end
