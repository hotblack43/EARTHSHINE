
FUNCTION likelihood,a,b,c
 common model,imodel,x,y,n
 common hyperparameters,lamda,factor
 if (imodel eq 1) then model_val=a+b*x
 if (imodel eq 2) then model_val=a+exp(cos(x)-b)
     P=Product(exp(-(y-model_val)^2/c^2))
; multiply by the somewhat uninformative priors of the parameters
      P=P*exp(-lamda*a^2)*exp(-lamda*b^2)*exp(-lamda*c^2)
if (p eq 0) then p=1e-10
 return,P
 end

 FUNCTION parameter_update,a,scale,ivar,prior
 ; takes a random walk step
 update=randomn(seed)*scale
 value=a+update
 prior=1.0
 if (ivar eq 3 and value le 0) then prior=0.0
 return,value
 end

     PRO metropolis_RW,ag,bg,cg,ivar,scale,yes,alpha
     ; calculate prob of current model fitted to data (p2)
     p2=likelihood(ag,bg,cg)
     ; generate a random-walk new guess for one of the parameters
     if (ivar eq 1) then  begin
	updated=parameter_update(ag,scale,1,prior_new)
	p1=likelihood(updated,bg,cg)
     endif
     if (ivar eq 2) then  begin
	updated=parameter_update(bg,scale,2,prior_new)
	p1=likelihood(ag,updated,cg)
     endif
     if (ivar eq 3) then  begin
	updated=parameter_update(cg,scale,3,prior_new)
	p1=likelihood(ag,bg,updated)
     endif
     ; let alpha=min[1,p1/p2]
     ; alpha = min([1,p1/p2])
	prior_old=1.0
        alpha = min([1,p1*prior_new/(p2*prior_old)])
	if (p1 eq p2) then print,p1,p2,prior_new,prior_old
     ; draw u
     u=randomu(seed)
     ; if u le alpha accept new parameter
     truth=(u lt alpha)
     if (truth and ivar eq 1) then ag=updated
     if (truth and ivar eq 2) then bg=updated
     if (truth and ivar eq 3) then cg=updated
     if (truth) then yes=yes+1L
 if (cg le 0) then stop
     return
     end

PRO gfunct, X, pars, F
	a=pars(0)
	b=pars(1)
  	f = a+exp(cos(x)-b)
return
END


 PRO generate_data_1,pars
 common model,imodel,x,y,n
 a=pars(0)
 b=pars(1)
 c=pars(2)
 n=100
 x=randomu(seed,n)*15
;x=x-mean(x)
 if (imodel eq 1) then y=a+b*x+c*randomn(seed,n)
 if (imodel eq 2) then y=a+exp(cos(x)-b)+c*randomn(seed,n)
 return
 end


 common model,imodel,x,y,n
 common hyperparameters,lamda,factor
 lamda=0.03	; factor in seeting the prior
 imodel=1	; imodel = 1 is  a line, = 2 is a nonlinear function
 for inoise=0.1,1.,.2 do begin
 get_lun,w
 openw,w,'data.dat'
 pars=[4.0,-1.,inoise]
 ; build some data
 generate_data_1,pars
 ;
 yes1=0L
 yes2=0L
 yes3=0L
 nloop=20000L
 ; generate starting guess for the parameters a and b
 	res=linfit(x,y,/double,yfit=yhat,sigma=sigs)
 ag=randomu(seed)
 bg=randomu(seed)
 cg=stddev(y)*10.
 factor=3.
 ag_scale=1.*factor
 bg_scale=.2*factor
 cg_scale=4.*factor
 print,'scales : ',ag_scale,bg_scale,cg_scale
 for iloop=0L,nloop-1,1 do begin
     printf,w,ag,bg,cg
     metropolis_RW,ag,bg,cg,2,bg_scale,yes2,alpha2
     metropolis_RW,ag,bg,cg,1,ag_scale,yes1,alpha
     metropolis_RW,ag,bg,cg,3,cg_scale,yes3,alpha3
 endfor
 close,w
 free_lun,w
 data=get_data('data.dat')
 l=size(data,/dimensions)
 print,l
; discard burn-in
 data=data(*,l(1)/5.:l(1)-1)
 l=size(data,/dimensions)
 print,l
 window,0,xsize=900,ysize=750
 !P.MULTI=[0,3,4]
 !P.CHARSIZE=2
 plot,data(0,*),ytitle='a',xtitle='Iteration',ystyle=1,xrange=[1,nloop],xstyle=1
 plots,[!X.CRANGE],[pars(0),pars(0)],linestyle=4
 plot,data(1,*),ytitle='b',xtitle='Iteration',ystyle=1,xrange=[1,nloop],xstyle=1
 plots,[!X.CRANGE],[pars(1),pars(1)],linestyle=4
 plot,data(2,*),ytitle='c',xtitle='Iteration',ystyle=1,xrange=[1,nloop],xstyle=1
 print,'==========================================================='
 print,'Input parameters a,b,c :',pars
 print,'==========================================================='
 print,'METROPOLIS results :'
 print,'Acceptance rate for a:',float(yes1)/float(nloop)*100.,' %'
 print,'Acceptance rate for b:',float(yes2)/float(nloop)*100.,' %'
 print,'Acceptance rate for c:',float(yes3)/float(nloop)*100.,' %'
 if (stddev(data(0,*)) ne 0) then histo,data(0,*),min(data(0,*)),max(data(0,*)),(max(data(0,*))-min(data(0,*)))/100.,xtitle='a'
 if (stddev(data(1,*)) ne 0) then histo,data(1,*),min(data(1,*)),max(data(1,*)),(max(data(1,*))-min(data(1,*)))/100.,xtitle='b'
 if (stddev(data(2,*)) ne 0) then histo,data(2,*),min(data(2,*)),max(data(2,*)),(max(data(2,*))-min(data(2,*)))/100.,xtitle='c'
 plot,data(0,*),data(1,*),psym=3,xstyle=1,ystyle=1,/isotropic
 plot,data(0,*),data(2,*),psym=3,xstyle=1,ystyle=1
 plot,data(1,*),data(2,*),psym=3,xstyle=1,ystyle=1
 print,'mean   a,b,c:',mean(data(0,*)),mean(data(1,*)),mean(data(2,*))
 print,'median a,b,c:',median(data(0,*)),median(data(1,*)),median(data(2,*))
 print,'std    a,b,c:',std(data(0,*)),std(data(1,*)),std(data(2,*))
 plot,x,y,psym=7,xtitle='x',ytitle='y',title='red : regression, blue : metropolis'
	 print,'==========================================================='
 if (imodel eq 1) then begin
 	res=linfit(x,y,/double,yfit=yhat,sigma=sigs)
	 print,'LINFIT results :'
	 print,'a,b : ',res
	 print,'+/- : ',sigs
	oplot,x,yhat,color=fsc_color('red')
 	oplot,x,mean(data(0,*))+mean(data(1,*))*x,color=fsc_color('blue')
 endif
 if (imodel eq 2) then begin
	 print,'CURVEFIT results :'
 	idx=sort(x)
	x=x(idx)
	y=y(idx)
	z=x
;Define a vector of weights.
	weights = 1.0/Y

;Provide an initial guess of the function's parameters.
	pars = [1.0,1.0]

;Compute the parameters.
	yhat = CURVEFIT(X, Y, weights, pars, SIGS, FUNCTION_NAME='gfunct',/noderivative)
	 print,'a,b : ',pars
	 print,'+/- : ',sigs
	oplot,x,yhat,color=fsc_color('red')
	oplot,z,mean(data(0,*))+exp(cos(z)-mean(data(1,*))),color=fsc_color('blue')
 endif
	 print,'==========================================================='
	endfor	; end of inoise loop
 end
