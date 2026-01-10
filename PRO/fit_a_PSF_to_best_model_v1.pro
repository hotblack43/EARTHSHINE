FUNCTION fitVoigtprofile,rr,pars
common imdims,obs,mdl,lobs
common keeps,folded
; Voigt profile with just one parameter
impact=pars(0)
factor=pars(1)
bias=pars(2)
V=voigt(impact,rr)
V=V*factor
; fold model image with PSF
shftmdl=shift(mdl,lobs(0)/2.,lobs(1)/2.)
folded=double(fft(fft(V,-1,/DOUBLE)*fft(shftmdl,-1,/DOUBLE),1,/DOUBLE))+bias
print,mean(obs)
print,mean(folded)
print,mean(obs-folded)
contour,obs-folded,/cell_fill,nlevels=11
return,folded
end

; code to generate a best-fitting PSF by minimising on the bright-side aureole
; using a model lunar disc and an observed image of themoon
;
common imdims,obs,mdl,lobs
common keeps,folded
; Observed image:
obs=readfits('obs.fit')
lobs=size(obs,/dimensions)
; Model image:
mdl=readfits('HAPKE_fitted.fit')	;  LAMBERT_fitted.fit
lmod=size(mdl,/dimensions)
if ((lobs(0) ne lmod(0)) or (lobs(1) ne lmod(1))) then stop
; now set up a PSF
 ncol=lmod(0)
 nrow=lmod(1)
 midx=lmod(0)/2.
 midy=lmod(1)/2.
 XR = indgen(Ncol)
 YC = indgen(Nrow)
 X = double(XR # (YC*0 + 1))
 Y = double((XR*0 + 1) # YC)
rr=sqrt((x-midx)^2+(y-midy)^2)
parinfo=replicate({mpside:2,value:0.D,$
fixed:0,limited:[0,0],limits:[0.D,0],$
relstep:0.0e-1},3) 
; set up impact parameter
parinfo(0).limited(0)=1
parinfo(0).limited[1]=0           
parinfo(0).limits[0]=0.0d0 
parinfo(0).limits[1]=1e1     
parinfo(0).fixed=0
; set up factor
parinfo(1).limited(0)=1
parinfo(1).limited[1]=0           
parinfo(1).limits[0]=0.0d0 
parinfo(1).limits[1]=1e1     
parinfo(1).fixed=0
; set up bias
parinfo(1).limited(0)=0
parinfo(1).limited[1]=0           
parinfo(1).limits[0]=90.
parinfo(1).limits[1]=110.   
parinfo(1).fixed=0
	; starting guesses - k,A and r_disc
	parinfo(*).value=[0.024,1000.,100.0]
	a=parinfo(*).value
        X=rr
        Y=obs
	erry=sqrt(y)
	maxiter=1000
	print,'a=',a
        parms = MPFITFUN('fitVoigtprofile', X, Y, erry, a,yfit=yfit, $
                PARINFO=parinfo, $
                PERROR=sigs,maxiter=maxiter,niter=niter)
        print,'number of iterations;',niter,' of ',maxiter
        a=parms
        residuals=y-yfit
        RMSE=sqrt(total(residuals^2)/n_elements(y))
	for k=0,n_elements(a)-1,1 do print,a(k),' +/- ',sigs(k)
; plot
plot_io,obs(*,85)
oplot,folded(*,85),color=fsc_color('blue')
end
