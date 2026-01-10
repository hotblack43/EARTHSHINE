PRO gfunct, X, pars, F
	a=pars(0)
	b=pars(1)
  	f = a+exp(cos(x)-b)
return
END


FUNCTION likelihood2,x,y,a,b
 common model,imodel
 ; mean for b
 n=n_elements(x)
 if (imodel eq 1) then std2=12.0*1.4*2.
 if (imodel eq 2) then std2=4.0
 P=1.0d0
 for i=0,n-1,1 do begin
 if (imodel eq 1) then model_i=a+b*x(i)
 if (imodel eq 2) then model_i=a+exp(cos(x(i))-b)
     stuff=((y(i)-model_i)/std2)^2
     P=P*exp(-stuff)/std2;	*1e10
     endfor
 return,P
 end

 FUNCTION likelihood1,x,y,a,b
 common model,imodel
 ; mean for a
 n=n_elements(x)
 if (imodel eq 1) then std2=4.0*1.4*2.
 if (imodel eq 2) then std2=4.0
 P=1.0d0
 for i=0,n-1,1 do begin
 if(imodel eq 1) then model_i=a+b*x(i)
 if(imodel eq 2) then model_i=a+exp(cos(x(i))-b)
     stuff=((y(i)-model_i)/std2)^2
     P=P*exp(-stuff)/std2;	*1e10
     endfor
 return,P
 end

 PRO generate_data_1,x,y,pars
 common model,imodel
 a=pars(0)
 b=pars(1)
 c=pars(2)
 n=200
 x=randomu(seed,n)*20
 x=x-mean(x)
 if (imodel eq 1) then y=a+b*x+c*randomn(seed,n)
 if (imodel eq 2) then y=a+exp(cos(x)-b)+c*randomn(seed,n)
 return
 end


 ; build some data that is a straight line with scatter, a,b=1,2
 common model,imodel
 imodel=2	; imodel = 1 is  a line, = 2 is a nonlinear function
 pars=[1.0,-0.2,0.2]
 generate_data_1,x,y,pars
 ;
 yes1=0L
 yes2=0L
 nloop=800000L
 get_lun,w
 openw,w,'data.dat'
 ; generate starting guess for the parameters a and b
 ag=0.0
 bg=0.0
 for iloop=0L,nloop-1,1 do begin
     printf,w,ag,bg
     ; first
     ; calculate prob of current model fitted to data (p2)
     p2=likelihood1(x,y,ag,bg)
     ; generate a random-walk new guess for one of the parameters
     agupdated=ag+randomn(seed)*1.0
     ; calculate prob of updated model fitted to data (p1)
     p1=likelihood1(x,y,agupdated,bg)
     ; let alpha=min[1,p1/p2]
     alpha = min([1,p1/p2])
     ; draw u
     u=randomu(seed)
     ; if u le alpha accept new parameter
     if (u lt alpha) then begin
         ag=agupdated
         yes1=yes1+1L
         endif
     ; if not use old
     if (u ge alpha) then begin
         ag=ag
         endif
     ; then
     ; calculate prob of current model fitted to data (p2)
     p2=likelihood2(x,y,ag,bg)
     ; generate a random-walk new guess for the other parameter
     bgupdated=bg+randomn(seed)*1.0
     ; calculate prob of updated model fitted to data (p1)
     p1=likelihood2(x,y,ag,bgupdated)
     ; let alpha=min[1,p1/p2]
     alpha2 = min([1,p1/p2])
     ; draw u
     u=randomu(seed)
     ; if u le alpha accept new parameter
     if (u lt alpha2) then begin
         bg=bgupdated
         yes2=yes2+1L
         endif
     ; if not use old
     if (u ge alpha2) then begin
         bg=bg
         endif
     endfor
 close,w
 free_lun,w
 data=get_data('data.dat')
 l=size(data)
 !P.MULTI=[0,2,3]
 !P.CHARSIZE=2
 plot,data(0,*),ytitle='a',xtitle='Iteration'
 plot,data(1,*),ytitle='b',xtitle='Iteration'
 print,'==========================================================='
 print,'Input parameters a,b :',pars
 print,'==========================================================='
 print,'METROPOLIS results :'
 print,'Acceptance rate for a:',float(yes1)/float(nloop)*100.,' %'
 print,'Acceptance rate for b:',float(yes2)/float(nloop)*100.,' %'
 histo,data(0,*),min(data(0,*)),max(data(0,*)),(max(data(0,*))-min(data(0,*)))/100.,xtitle='a'
 histo,data(1,*),min(data(1,*)),max(data(1,*)),(max(data(1,*))-min(data(1,*)))/100.,xtitle='b'
 print,'mean, a,b:',mean(data(0,*)),mean(data(1,*))
 print,'std a,b:',std(data(0,*)),std(data(1,*))
 print,'std_m a,b:',std(data(0,*))/sqrt(nloop-1),std(data(1,*))/sqrt(nloop-1)
 print,'Auto-corr :',a_correlate(data(0,*),1),a_correlate(data(1,*),1)
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
	yhat = CURVEFIT(X, Y, weights, pars, SIGMA, FUNCTION_NAME='gfunct',/noderivative)
	 print,'a,b : ',pars
	 print,'+/- : ',sigma
	oplot,x,yhat,color=fsc_color('red')
	oplot,z,mean(data(0,*))+exp(cos(z)-mean(data(1,*))),color=fsc_color('blue')
 endif
	 print,'==========================================================='

 end
