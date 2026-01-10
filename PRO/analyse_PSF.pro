PRO VOIGT_FUN,x,a,F
common stuff2,y
apar=a(0)
bpar=a(1)
F=voigt(apar,x)/bpar
return
end

;===================================
common stuff2,y
str='LAMBERT'
str='HAPKE'
PSF_orig=readfits(strcompress(str+'_PSF.fit',/remove_all))
psf=PSF_orig
l=size(psf,/dimensions)
; shift to center of image
ind=max(psf,location)
center=array_indices(psf,location)
psf=shift(psf,l(0)/2.-center(0),l(1)/2.-center(1))
surface,psf,/lego,title=strcompress('Calculated PSF, for '+str)
;surface,rebin(psf,l(0)/4,l(1)/4),/lego,title=strcompress('Calculated PSF, for '+str)
; fit a 3d gaussian
yfit= GAUSS2DFIT( PSF, A)
;yfit=sqrt(yfit)
print,'Fitted this center coord:',a(4),a(5)
; now spin and smear around that coord 
count=0
rlim=25.0
for i=0,l(0)-1,1 do begin
for j=0,l(1)-1,1 do begin
r=sqrt((i-a(4))^2+(j-a(5))^2)
if (count eq 0) then begin
	x=r
	if (r le rlim) then y=psf(i,j)
	if (r gt rlim) then begin 
		psf(i,j)=0.0
		y=psf(i,j)
	endif
endif
if (count gt 0) then begin
	x=[x,r]
	if (r le rlim) then y=[y,psf(i,j)]
	if (r gt rlim) then begin
		psf(i,j)=0.0
		y=[y,psf(i,j)]
	endif
endif
count=count+1
endfor
endfor
idx=sort(x)
x=x(idx)
y=y(idx)
plot_oi,x,y,xtitle='r [pixels]',ytitle='PSF height',psym=4,xstyle=1,ystyle=1
; fit a Voigt profile
	P=[1.76+randomu(seed)*0.1,380.+randomu(seed)*3.]
	weights=y*0.0+1.0
	yfit = CURVEFIT( X, Y, Weights, P, TOL=1.0d-8,  /DOUBLE, FUNCTION_NAME='VOIGT_FUN' , /NODERIVATIVE,status=stat ) 
	print,'Status=',stat
	oplot,x,yfit
	print,'Voigt pars=',P
	print,'RMSE=',sqrt(total((y-yfit)^2)/n_elements(yfit))
; having fitted the Voigt profile now build a smooth one
voigt_psf=dblarr(l(0),l(1))
for i=0,l(0)-1,1 do begin
for j=0,l(1)-1,1 do begin
r=sqrt((i-a(4))^2+(j-a(5))^2)
voigt_psf(i,j)=voigt(p(0),r)
endfor
endfor
; shift Voigt_psf back to origin
;voigt_psf=shift(voigt_psf,-a(4),-a(5))
;voigt_psf(0,0)=0.0
voigt_psf=voigt_psf/total(voigt_psf)
writefits,'voigt_psf.fit',voigt_psf
; shift found psf back to origin
;psf=shift(psf,-(l(0)/2.-center(0)),-(l(1)/2.-center(1)))
;psf(0,0)=0.0	; remove_mean value
psf=psf/total(psf)
; finally correct the observed image with both psf and voigt_psf
observed=readfits('observed.fit')
;
clean=FFT(FFT(observed,-1,/double)/FFT(psf,-1,/double),1,/double)
clean=sqrt(double(clean*conj(clean)))
writefits,'cleaned.fit',clean
print,'A cleaned image has been put in cleaned.fit'
;
voigt_clean=FFT(FFT(observed,-1,/double)/FFT(voigt_psf,-1,/double),1,/double)
voigt_clean=sqrt(double(voigt_clean*conj(voigt_clean)))
writefits,'voigt_cleaned.fit',voigt_clean
print,'A Voigt cleaned image has been put in voigt_cleaned.fit'
end

