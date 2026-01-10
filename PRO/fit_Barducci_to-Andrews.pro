@Pilletprofile.pro
;========================================
common names,varname
im=readfits('ANDREW/sydney_2x2.fit')
l=size(im,/dimensions)
x0=76.95
Y0=86.45
r_disc=108.6/2.
radius=findgen(l(0))-X0	; Signed radius from center of disc along line through center
help,radius
contour,im,/isotropic,/cell_fill
line=im(*,75)
help,line
a=4.7*r_disc
k=950.
bias=100.
power=1.0
; fit Snow or Pillet profile to real profile
parinfo=replicate({mpside:2,value:0.D,fixed:0,limited:[0,0],limits:[0.D,0],step:0.0e-5},5) 
; set up k
parinfo(0).limited(0)=1
parinfo(0).limited[1]=0           
parinfo(0).limits[0]=0.0d0 
parinfo(0).limits[1]=1e9     
parinfo(0).fixed=0
; set up A (or B, depends on profile used)
parinfo(1).limited(0)=1
parinfo(1).limited[1]=0           
parinfo(1).limits[0]=0.0d0 
parinfo(1).limits[1]=1e9
parinfo(1).fixed=0
; set up r_disc 
parinfo(2).limited(0)=1
parinfo(2).limited[1]=1           
parinfo(2).limits[0]=40.
parinfo(2).limits[1]=60.   
parinfo(2).fixed=1
; set up bias 
parinfo(3).limited(0)=1
parinfo(3).limited[1]=1           
parinfo(3).limits[0]=90.
parinfo(3).limits[1]=110.   
parinfo(3).fixed=1
; set up power
parinfo(4).limited(0)=1
parinfo(4).limited[1]=1           
parinfo(4).limits[0]=1.
parinfo(4).limits[1]=3.   
parinfo(4).fixed=0
	; starting guesses - k,A and r_disc
	parinfo(*).value=[k,A,r_disc,bias,power]
	a=parinfo(*).value
	idx=where(radius ge r_disc)
	X=radius(idx)
	Y=line(idx)
	erry=sqrt(y(idx))
	maxiter=1000
        parms = MPFITFUN('Pilletprofile', X, Y, erry, a,yfit=yfit, $
                PARINFO=parinfo, $
                PERROR=sigs,maxiter=maxiter,niter=niter)
        print,'number of iterations;',niter,' of ',maxiter
        a=parms
        residuals=y-yfit
        RMSE=sqrt(total(residuals^2)/n_elements(y))
        zeds=abs(residuals/erry)
	for k=0,n_elements(a)-1,1 do print,varname(k),a(k),' +/- ',sigs(k)
; plot
!P.MULTI=[0,1,2]
plot_io,radius,line,yrange=[100,5000],ystyle=1,xtitle='Signed radius fromd isc centre'
oplot,x,yfit,color=fsc_color('red')
plots,[a(2),a(2)],[100,5000],color=fsc_color('yellow')
plots,[!X.CRANGE],[a(3),a(3)],color=fsc_color('blue')
plot,radius,line,xtitle='Signed radius fromd isc centre',yrange=[100,500],ystyle=1,xrange=[50,100],xstyle=1
oplot,x,yfit,color=fsc_color('red')
end

