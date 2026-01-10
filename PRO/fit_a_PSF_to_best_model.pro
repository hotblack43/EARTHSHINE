PRO pad_image,in,out,nx,ny
; will take an array 'in' and pad it on all sides
; with equal sized arrays so that it becomes
; the middle of 9 such arrays.
z=in*0.0d0+min(in)
top=[z,z,z]
bottom=top
middle=[z,in,z]
out=[[top],[middle],[bottom]]
l=size(out,/dimensions)
nx=l(0)
ny=l(1)
return
end

;
FUNCTION fitVoigtprofile,rr,pars
common imdims,obs,mdl,lobs
common keeps,folded
common masks,mask
; Voigt profile
impact=pars(0)
factor=pars(1)
bias=pars(2)
pinheight=factor
; evaluate a rectangular array V
; e.g. the Vogt profile
V=voigt(impact,rr)
V=V/total(V)
; pad V and mdl to avoid edge effects
pad_image,v,v_padded,nx,ny
v_padded(where(v_padded eq max(v_padded)))=pinheight
pad_image,mdl,mdl_padded,nx,ny
;
shftmdl=shift(mdl_padded,nx/2.,ny/2.)
; fold padded model image with padded PSF
folded=double(fft(fft(V_padded,-1,/DOUBLE)*fft(shftmdl,-1,/DOUBLE),1,/DOUBLE))+bias
; clip out the middle 9th
out1=folded[lobs(0):2*lobs(0)-1,*]
folded=out1(*,lobs(1):2*lobs(1)-1)
;
contour,bytscl(mask*(obs/obs-folded/obs)),/cell_fill,nlevels=31,xstyle=1,ystyle=1,/isotropic
kdx=where(folded le 0)
if (kdx(0) ne -1) then folded(where(folded le 0))=1.e-9
return,alog10(folded/obs)*mask
;return,folded/obs*mask
end

; code to generate a best-fitting PSF by minimising on the bright-side aureole
; using a model lunar disc and an observed image of the moon
;
loadct,19
decomposed=0
common imdims,obs,mdl,lobs
common keeps,folded
common masks,mask
obs=readfits('observed.fit')
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
; set up the mask
mask=obs*0.0
mask(where((x gt 95) and (y gt 30 and y lt 140)))=1
;mask(where((x gt 130)))=1
rr=sqrt((x-midx)^2+(y-midy)^2)
parinfo=replicate({mpside:2,value:0.D,$
	fixed:0,limited:[0,0],limits:[0.D,0],$
	relstep:0.0e-5},3)
; set up impact parameter
parinfo(0).limited(0)=1
parinfo(0).limited[1]=0
parinfo(0).limits[0]=0.0d0
parinfo(0).limits[1]=1e1
parinfo(0).fixed=0
parinfo(0).value=.08
; set up factor
parinfo(1).limited(0)=1
parinfo(1).limited[1]=0
parinfo(1).limits[0]=0.0d0
parinfo(1).limits[1]=1e4
parinfo(1).fixed=0
; set up bias
parinfo(2).limited(0)=1
parinfo(2).limited[1]=1
parinfo(2).limits[0]=90.
parinfo(2).limits[1]=110.
parinfo(2).fixed=1
parinfo(2).value=100.
	; starting guesses - impact,factor,bias
	parinfo(*).value=[.01,1.04,100.]
	a=parinfo(*).value
        X=rr
        Y=alog10(obs/obs)*mask
        erry=y*0.0+1.0
        ;Y=obs/obs*mask
	;erry=sqrt(obs)/obs*mask
	;erry=erry+mean(erry)/1e4
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
plot,obs(*,85),/ylog;,yrange=[100,1e3]
oplot,folded(*,85),color=fsc_color('red')
end
