PRO go_find_best_x0y0radius,x0_out,y0_out,radius_out
common stuff,FFTideal,observed,ideal,maxerr,n,test_err,llim,rrlim,dlim,ulim,tstr,x0,y0,radius,mask,r
a=''
while (a ne 'q') do begin
	im=observed
	make_circle,x0,y0,radius,x,y
	im(x,y)=3.*max(observed)
	tvscl,im
	a=get_kbrd()
	if (a eq 'b') then radius=radius*1.001
	if (a eq 's') then radius=radius/1.001
	if (a eq 'r') then x0=x0+1
	if (a eq 'l') then x0=x0-1
	if (a eq 'u') then y0=y0+1
	if (a eq 'd') then y0=y0-1
endwhile
x0_out=x0
y0_out=y0
radius_out=radius
return
end

FUNCTION minimize_me,pars
 common stuff,FFTideal,observed,ideal,maxerr,n,test_err,llim,rrlim,dlim,ulim,tstr,x0,y0,radius,mask,r
 ; unpack the parameter guesses
 p=pars(0)
 pars(1)=min([pars(1),3.])
 w=pars(1)
 pedestal=pars(2)
 get_kernel,kernel,p,w
 ;calculate the SSE to be returned as the target tominimize
 ; convolve
 imout=double(FFT(FFTideal*fft(kernel,-1,/double),1,/double))+pedestal
 scattered=imout-ideal
 ;diff=(observed-imout)	; the whole frame
 diff=mask*(observed-imout)	; ust the Sky
 ;err=total(diff^2)	
 ;err=total(diff(0:200,*)^2)
 err=total(diff(n-1-200:n-1,*)^2)
 ;err=total(diff(200:500,*)^2)
 ;err=total(diff(0:62,*)^2) 	;SkyOnly
 test_err=total(diff(llim:rrlim,dlim:ulim)^2)
 thing=err
 if (err lt maxerr) then begin
     ; write out the results
     writefits,strcompress(tstr+'imout.fit',/remove_all),imout
     writefits,strcompress(tstr+'scattered.fit',/remove_all),scattered
     writefits,strcompress(tstr+'cleaned.fit',/remove_all),observed-scattered
     writefits,strcompress(tstr+'kernel.fit',/remove_all),kernel
     maxerr=err
     ;tvscl,[observed,imout,diff*mask]
     tvscl,diff*mask
     print,'Best so far: parameters =',pars,'SSE =',thing
     endif
 return,thing
 end
 
 PRO get_kernel,kernel,peakval,widthfactor
 common stuff,FFTideal,observed,ideal,maxerr,n,test_err,llim,rrlim,dlim,ulim,tstr,x0,y0,radius,mask,r
 data=get_data('TOMSTONE/nozeros_ROLO_765nm_Vega_psf.dat')
 x=reform(data(0,*))
 y=reform(data(1,*))
 kernel=dblarr(n,n)
 fillval=9e-4
 kernel=INTERPOL(y,x,r*widthfactor)
 ;put a variable-height spike in the centre
 kernel(n/2.,n/2.)=kernel(n/2.,n/2.)*peakval
 ; and normalize
 kernel=kernel/total(kernel)*float(n*n)
 ; shift to origin
 kernel=shift(kernel,n/2.,n/2.)
 return
 end
 
 
 CPU, TPOOL_MIN_ELTS=1000, TPOOL_NTHREADS=2
 common stuff,FFTideal,observed,ideal,maxerr,n,test_err,llim,rrlim,dlim,ulim,tstr,x0,y0,radius,mask,r
 ; read in the image to be corrected
 observed=readfits('TOMSTONE/2709_ROLO_rotatedm90.fit')
 l=size(observed,/dimensions)
 if (l(0) ne l(1)) then stop
 n=l(0)
 ; set the testing area limits
 llim=10
 rrlim=150
 dlim=200
 ulim=300
; define centre and radius of Moon in pixel coords
x0=282.5
y0=250.5
radius=223.5
if (file_test('lunarRim.dat') eq 1) then begin
openr,3,'lunarRim.dat'
readf,3,x0
readf,3,y0
readf,3,radius
close,3
endif
go_find_best_x0y0radius,x0,y0,radius
openw,3,'lunarRim.dat'
printf,3,x0
printf,3,y0
printf,3,radius
close,3
; set the string for the experiment name
 tstr='Cols40to80_'
 tstr='WholeDisk_'
 tstr='SkyOnly_'
 tstr='Cols0to200_'
 tstr='Cols312to511_'
 openw,2,strcompress(tstr+'limits.dat',/remove_all)
 printf,2,llim,rrlim,dlim,ulim
 close,2
; set up the arrayfor the PSF
 r=dblarr(n,n)
 rr=dblarr(n,n)
 for i=0,n-1,1 do begin
     for j=0,n-1,1 do begin
         r(i,j)=sqrt((i-n/2.)^2+(j-n/2.)^2)
         rr(i,j)=sqrt((i-x0)^2+(j-y0)^2)
         endfor
     endfor
; setup the the sky mask
 mask=intarr(n,n)*0+1
 kdx=where(rr le radius)
 mask(kdx)=0
;
 writefits,strcompress(tstr+'imin.fit',/remove_all),observed
 ideal=readfits('rotatedandscaled.fit')
 writefits,strcompress(tstr+'ideal.fit',/remove_all),ideal
 ;
 FFTideal=FFT(ideal,-1,/double)
 maxerr=1e33
 ;...................................................................
 ; set up the input to the solver
 start_parms=[1002.0889 ,    0.71209907 , 0.00011521302] ; these are p,w,and pedestal starting guesses
 Xi=[[1,0,0],[0,1,0],[0,0,1]]
 Ftol=1e-9
 POWELL, start_parms, Xi, Ftol, Fmin, 'minimize_me' , /DOUBLE ; , ITER=variable] [, ITMAX=value]
 PRINT, 'Solution point, min: ', start_parms,fmin
 print,'Solutions:'
 print,'p',start_parms(0)
 print,'w:',start_parms(1)
 print,'pedestal:',start_parms(2)
 get_lun,w
openw,w,strcompress(tstr+'results.dat',/remove_all)
 PRINTf,w,'Error in target : ',fmin
 printf,w,'Delta peak:',start_parms(0)
 printf,w,'PSF width par :',start_parms(1)
 printf,w,'Pedestal :',start_parms(2)
 printf,w,'Error in test area: ',test_err
close,w
free_lun,w
 print,'Done! Now see results.dat'
 end
 
