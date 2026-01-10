PRO performbootstrap,x_in,y_in,res,coef_sig
 nMC=40000L
 n=n_elements(x_in)
 intercept=[]
 slope=[]
 for iMC=0,nMC-1,1 do begin
     idx=fix(randomu(seed,n)*n)
     x=x_in(idx)
     y=y_in(idx)
     res=linfit(x,y,/double)
     intercept=[intercept,res(0)]
     slope=[slope,res(1)]
     endfor
 res=dblarr(2)
 coef_sig=dblarr(2)
 res(0)=mean(intercept,/double)
 res(1)=mean(slope,/double)
 coef_sig(0)=stddev(intercept,/double)
 coef_sig(1)=stddev(slope,/double)
 return
 end
 
 n=100
 x=findgen(n)+100
 a=12.34
 b=1.234
 sig=3.44
 noise=randomn(seed,n)*sig
; make the noise 'red'
 eta=0.3
 sdold=stddev(noise)
 noise=pseudo_t_guarantee_ac1(noise,eta,1,seed)
 noise=noise/stddev(noise)*sdold
 y=a+b*x+noise
 plot,x,y,psym=7
 print,'-------------------------------------------------------------'
 res=linfit(x,y,/double,sigma=coef_sigs,yfit=yhat)
 print,'LINFIT results without MEASURE_ERRORS:'
 print,'res: ',res
 print,'unc: ',coef_sigs
 oplot,x,yhat,color=fsc_color('red')
 residuals=y-yhat
 print,'SD of residuals: ',stddev(residuals)
 print,'-------------------------------------------------------------'
 res=linfit(x,y,/double,sigma=coef_sigs,yfit=yhat,measure_errors=y*0.0+sig)
 print,'LINFIT results with MEASURE_ERRORS:'
 print,'res: ',res
 print,'unc: ',coef_sigs
 oplot,x,yhat,color=fsc_color('red')
 residuals=y-yhat
 print,'SD of residuals: ',stddev(residuals)
 print,'-------------------------------------------------------------'
 print,'Bootsrapping with replacement:'
 performbootstrap,x,y,res,coef_sig
 print,'MC res: ',res
 print,'MC unc: ',coef_sig
 print,'-------------------------------------------------------------'
 end
