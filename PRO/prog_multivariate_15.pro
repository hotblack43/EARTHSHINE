PRO plot_T_and_proxies,n,T,proxies,nproxies
!P.MULTI=[0,1,1]
plot,T
offset=2.
for i=0,nproxies-1,1 do oplot,proxies(i,*)+offset*i
return
end

PRO evaluate_regression,idx_testset,y_in,x_in,a,b,a_found,b_found,skills,nskills
 common reconstructions,Treconstructed
 x=x_in
 y=y_in
 ; First build the reconstructed T
 l=size(x,/dimensions)
 nproxies=l(0)
 nt=l(1)
 t=findgen(nt)*0.0d0
 for iproxy=0,nproxies-1,1 do T=T+b_found(iproxy)*x(iproxy,*)
 T=T+a_found
 Treconstructed=T(idx_testset)
 ; then test different skills
 ab_estimated=[a_found,b_found]
 ab_actual=[a,b]
 evaluate_skill,y(idx_testset),T(idx_testset),skills,ab_estimated,ab_actual,nskills
 return
 end
 
 
 PRO do_regression,imethod,y_in,x_in,a_found,b_found
 x=x_in
 y=y_in
 if (imethod eq 1) then begin
     ; REGRESS
     res=REGRESS(x,y,/double,yfit=yhat,const=konst,sigma=sigs)
     a_found=konst
     b_found=reform(res)
;	print,'regress: ',total(abs(res/sigs) gt 1)
     return
     endif
 if (imethod eq 2) then begin
     ; CO_REGRESS
	rh=0.8
     res=co_REGRESS(x,y,/double,yfit=yhat,const=konst,rho=rh,sigma=sigs)
     a_found=konst
     b_found=reform(res)
;	print,'co regress: ',total(abs(res/sigs) gt 1)
     return
     endif
if (imethod eq 3) then begin
; do Bayesian fitting allowing errors on y and the x's
xx=transpose(x)
l=size(xx,/dimensions)
nx=l(0)
np=l(1)
mean_error_on_any_proxy=1.0
mean_error_on_y=1.0
XVAR=fltarr(nx,np,np)+0.01
for ivar=0,nx-1,1 do begin
for k=0,np-1,1 do XVAR(ivar,k,k)=mean_error_on_any_proxy^2
endfor
YVAR=y*0+mean_error_on_y^2
XYCOV=fltarr(nx,np)
MLINMIX_ERR, XX, Y, POST, XVAR=XVAR, YVAR=YVAR, XYCOV=XYCOV, $
NGAUSS=NGAUSS,  DELTA=DELTA,MINITER=100, MAXITER=200
print,tag_names(POST)
save,POST,filename='POST.sav'
stop
return
endif
 end
 
 PRO generate_data,n,T,proxies,nproxies,a,b,eta,rho,i_case
 proxies=dblarr(nproxies,n)
 T=dindgen(n)*0.0d0
 dummy=randomn(seed,n)
 ; generate the proxies as red series with AR1=0.7
 model=pseudo_t_guarantee_ac1(dummy,0.7,1,seed) ; base model for the proxies - i.e. let all
 ; proxies have this in common and add something on to of it (noise is added later)
 for iproxy=0,nproxies-1,1 do begin
     proxies(iproxy,*)=model
     proxies(iproxy,*)=proxies(iproxy,*)+exp((indgen(n)-n*(12./15.))/30.0)
     proxies(iproxy,*)=proxies(iproxy,*)+pseudo_t_guarantee_ac1(dummy,0.7,1,seed)/3.
     endfor
 ; then generate T from the pseudo-proxies
 for iproxy=0,nproxies-1,1 do begin
     T=T+reform(b(iproxy)*proxies(iproxy,*))
     endfor
 T=T+a
 ; if want noise on proxies add this
 if (i_case eq 1) then begin
     for iproxy=0,nproxies-1,1 do begin
         noise=pseudo_t_guarantee_ac1(dummy,rho,1,seed)  ; noise AR1=rho
         proxies(iproxy,*)=reform(proxies(iproxy,*))+eta*noise
         endfor
     endif
 ; if i_case eq 2 then want noise on T
 if (i_case eq 2) then T=T+eta*pseudo_t_guarantee_ac1(dummy,rho,1,seed)
 return
 end
 
 ; Version 15
 ; code to test OLS vs CO etc on reconstruction simulations
 ; MULTI-variate
 ;---------------------------------------------------------------------
 !X.THICK=2
 !Y.THICK=2
 !P.THICK=2
 !P.CHARSIZE=2
 common reconstructions,Treconstructed
 nproxies=20
 n=150	; length of the time series 
 time=findgen(n)
 idx=indgen(n)
 fraction=0.7	; division of the time axis into trainand test sets
 ; define the training set and the test set
 idx_trainset=where(time ge fraction*max(time))
 idx_testset=where(time le fraction*max(time))
 get_lun,u
 openw,u,'tempfil2.dat'
 for rho=0.7,1.0,0.03 do begin	; loop over noise AR1
     print,'rho : ',rho
     get_lun,w
     openw,w,'tempfil1.dat'
     nloops=2000
     for iloop=0,nloops-1,1 do begin
         eta=1.6	; factor on noise
         ; set up the regression coefficients that 'really' apply
         a=1.0
         b=randomu(seed,nproxies,/double)	; regression coefficients
         ; choose the noise model
         i_case=1	; 1 is noise on the proxies, 2 is noise on T
         ; choose the regression method
         ; go and generate fake AR1 proxies and generate a T
         generate_data,n,T,proxies,nproxies,a,b,eta,rho,i_case
         ;plot_T_and_proxies,n,T,proxies,nproxies
         ; perform the regression using training data
         for imethod=1,3,1 do begin	; loop over regression methods
             do_regression,imethod,t(idx_trainset),proxies(*,idx_trainset),a_found,b_found
             ; evaluate the regression on the test set
             evaluate_regression,idx_testset,t,proxies,a,b,a_found,b_found,skills,nskills
             printf,w,format='(7(1x,g13.7),1x,i1)',rho,skills,imethod
             endfor ; end of imethod loop
         endfor	; end of iloop loop
     close,w
     free_lun,w
     data=get_data('tempfil1.dat')
     l=size(data,/dimensions)
     rho1=reform(data(0,0))
     dummy=reform(data(nskills+1,*))
     a1=dummy(sort(dummy))	
     imethods=a1(uniq(a1))
     nmethods=n_elements(imethods)
     med=fltarr(l(0)-2)
     for im=0,nmethods-1,1 do begin
         imetho=imethods(im)
         idx=where(data(nskills+1,*) eq imetho)
         for icol=1,nskills,1 do begin
         ;for icol=1,l(0)-2,1 do begin
             med(icol-1)=median(data(icol,idx))
             endfor
         print,format='(7(1x,f9.4),1x,i1)',rho1(*),med(*),imetho 
         printf,u,format='(7(1x,f12.6),1x,i1)',rho1,med,imetho 
         endfor	; end of im loop
     endfor	; end of rho loop
 close,u
 free_lun,u
 ; now analyze the data in 'tempfil2.dat'
 data=get_data('tempfil2.dat')
 xstr=['!7q!3','R','R!dlo!n','y-level Bias','Variance Bias','SLope Bias','Coefficients Bias']
 !P.MULTI=[0,2,3]
 rho=reform(data(0,*))
 med=reform(data(1:nskills,*))
 ime=reform(data(nskills+1,*))
 for icol=1,nskills,1 do begin
     for imethod=min(ime),max(ime),1 do begin
         idx=where(ime eq imethod)
         if (imethod eq min(ime)) then begin
             plot,med(icol-1,idx),rho(idx),xtitle=xstr(icol),ytitle='!7q!3',linestyle=imethod-1,xrange=[-1,1],xstyle=1,ystyle=1
             endif
         if (imethod gt min(ime)) then begin 
             oplot,med(icol-1,idx),rho(idx),linestyle=imethod-1
             endif
         endfor
	plots,[0,0],[!Y.crange],linestyle=0,thick=1
     endfor
 end
