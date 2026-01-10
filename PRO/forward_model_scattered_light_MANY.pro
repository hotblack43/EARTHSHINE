PRO go_do_mpfitstuff,observed,start_parms,n
 ; Find best parametrs using MPFIT2DFUN method
 Nx=n
 Ny=n
 XR = indgen(Nx)
 YC = indgen(Ny)
 X = double(XR # (YC*0 + 1))        ;     eqn. 1
 Y = double((XR*0 + 1) # YC)        ;     eqn. 2
 err=sqrt(observed>1) ; Poisson noise ...
 z=observed
 ; set up the PARINFO array - indicate double-sided derivatives (best)
 parinfo = replicate({mpside:2, value:0.D, $
 fixed:0, step:0, limited:[0,0], limits:[0.D,0]}, 3)
 parinfo[0].fixed = 0
 parinfo[1].fixed = 0
 parinfo[2].fixed = 0
 ; Peak value
 parinfo[0].limited(0) = 1
 parinfo[0].limits(0)  = 0.0
 parinfo[0].limited(1) = 1
 parinfo[0].limits(1)  = 200000.0d0
 
 ; Width
 parinfo[1].limited(0) = 1
 parinfo[1].limits(0)  = 0.0d0
 parinfo[1].limited(1) = 1
 parinfo[1].limits(1)  = 2.0d0
 
 ; Pedestal
 parinfo[2].limited(0) = 1
 parinfo[2].limits(0)  = 0.0d0
 parinfo[2].limited(1) = 1
 parinfo[2].limits(1)  = 100.0d0
 
 ;
 parinfo[*].value = start_parms
 ; print out limits and startiong values
 for ipar=0,2,1 do begin
     print,'........................................'
     print,'Paramter ',ipar,' : ', start_parms(ipar)
     print,'Is limited ?',parinfo[ipar].limited(0),parinfo[ipar].limited(1)
     print,'What is limit ?',parinfo[ipar].limits(0),parinfo[ipar].limits(1)
     print,'Is it fixed?',parinfo[ipar].fixed
     endfor
 print,'........................................'
 results = MPFIT2DFUN('minimize_me_2', X, Y, Z, ERR, PARINFO=parinfo,perror=sigs,STATUS=hej)
 return
 end

FUNCTION minimize_me_2,X,Y,pars
 common stuff,FFTideal,observed,ideal,maxerr,n,llim,rrlim,dlim,ulim,tstr,x0,y0,radius,mask,r,header
 ; unpack the parameter guesses
 p=pars(0)
 pars(1)=min([pars(1),3.])
 w=pars(1)
 pedestal=pars(2)
 get_kernel,kernel,p,w
 ;calculate the SSE to be returned as the target tominimize
 ; convolve ideal image with current kernel model
 paddedfft,kernel,arrayout
 modelofobservation=arrayout+pedestal
 scattered=modelofobservation-ideal
 diff=mask*(observed-modelofobservation)	; just the Sky
 !P.MULTI=[0,1,2]
 err=total(diff^2)	
 thing=err
 thing=mask*modelofobservation
 if (err lt maxerr) then begin
     ; write out the results
     writefits,strcompress('modelofobservation.fit',/remove_all),modelofobservation,header
     writefits,strcompress('scattered.fit',/remove_all),scattered,header
     writefits,strcompress('cleaned.fit',/remove_all),observed-scattered,header
     maxerr=err
     print,'Best so far: parameters =',pars,'SSE =',err
     surface,congrid(diff,100,100),title='Residuals',charsize=2
     histo,diff,-100,100,1
     endif
 return,thing
 end

 PRO get_kernel,kernel,peakval,widthfactor
 common stuff,FFTideal,observed,ideal,maxerr,n,llim,rrlim,dlim,ulim,tstr,x0,y0,radius,mask,r,header
 common flags,iflag,iflag2
 data=get_data('TOMSTONE/nozeros_ROLO_765nm_Vega_psf.dat')
 x=reform(data(0,*))
 y=reform(data(1,*))
 kernel=dblarr(n,n)
 fillval=min(y(where(y gt 0)))
 kernel=INTERPOL(y,x,r*widthfactor)
 kdx=(where(kernel lt fillval))
 if (kdx(0) ne -1) then kernel(kdx)=fillval
 ;put a variable-height spike in the centre
 kernel(n/2.,n/2.)=kernel(n/2.,n/2.)*peakval
 ; and normalize
 kernel=kernel/total(kernel)*float(n*n)
 ;surface,kernel
 return
 end


PRO paddedFFT,kernel,arrayout
common stuff,FFTideal,observed,ideal,maxerr,n,llim,rrlim,dlim,ulim,tstr,x0,y0,radius,mask,r,header
common flags,iflag,iflag2
 fastfactor=128*2
 if (iflag ne 314) then begin
 	paddedideal=go_pad_image(ideal)
 	FFTideal=FFT(paddedideal,-1,/double)
 	;FFTideal=FFT(congrid(paddedideal,fastfactor,fastfactor),-1,/double)
 	iflag=314
 endif
 paddedkernel=go_pad_image(kernel)
 l=size(paddedkernel,/dimensions)
 m=l(0)
 ; shift to origin
 paddedkernel=shift(paddedkernel,m/2.,m/2.)
; renormalize to new size
 paddedkernel=paddedkernel/total(paddedkernel)*double(m)*double(m)
 ; convolve with FFT on padded arrays
 temp=double(ffT(FFTideal*FFT(paddedkernel,-1,/double),1,/double))
 ;temp=double(ffT(FFTideal*FFT(congrid(paddedkernel,fastfactor,fastfactor),-1,/double),1,/double))
 arrayout=go_unpad(congrid(temp,m,m))
 return
end



 CPU, TPOOL_MIN_ELTS=10000, TPOOL_NTHREADS=2
 common stuff,FFTideal,observed,ideal,maxerr,n,llim,rrlim,dlim,ulim,tstr,x0,y0,radius,mask,r,header
 common flags,iflag,iflag2
 if_scaledown=0 & ndown=256	;for speed-up, scale images to 2^n
 iflag=-911
 get_lun,uw
 openw,uw,'collected_results.dat'
 ; read in the image to be corrected
 ; get the observed file names
 path='OUTPUT/IDEAL/'
 observednames=file_search(path+'Observed_*.fit',count=n1)
 onames=strmid(observednames(*),strlen(observednames(2))-18,100)
 InSpacenames=file_search(path+'InSpace_*.fit',count=n2)
 inames=strmid(InSpacenames(*),strlen(InSpacenames(2))-17,100)
 if (n1 ne n2) then stop
 for ifile=0,n1-1,1 do begin
 observed=readfits(path+onames(ifile),header)
 phase=double(strmid(header(9),16,32-16))
 if (if_scaledown eq 1) then observed=congrid(observed,ndown,ndown)
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
 tstr='WholeSkyPOISSON'
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
; setup the sky mask
 mask=intarr(n,n)*0+1
 kdx=where(rr le radius)
 if (kdx(0) ne -1) then mask(kdx)=0
 ;if (phase lt 0) then mask(279:511,*)=0
 ;if (phase gt 0) then mask(0:278,*)=0
;
; read in the 'ideal image' as seen in spave without a distoring telescope
 ideal=readfits(path+inames(ifile))
 if (if_scaledown eq 1) then ideal=congrid(ideal,ndown,ndown)
 ;
 maxerr=1e33
 ;...................................................................
 ; set up the input to the solver
 start_parms=[100000.0d0 ,    1.07 , 0.00011521302] ; these are p,w,and pedestal starting guesses
;////////////////////////////////////////////
; stuff for MPFIT2DFUN
go_do_mpfitstuff,mask*observed,start_parms,n
;////////////////////////////////////////////
 print,'Solutions:'
 print,'p',start_parms(0)
 print,'w:',start_parms(1)
 print,'pedestal:',start_parms(2)
 get_lun,w
openw,w,strcompress(tstr+'results.dat',/remove_all)
 ;PRINTf,w,'Error in target : ',fmin
 printf,w,'Delta peak:',start_parms(0)
 printf,w,'PSF width par :',start_parms(1)
 printf,w,'Pedestal :',start_parms(2)
close,w
free_lun,w
 printf,uw,0.0,start_parms(0),start_parms(1),start_parms(2),0.0
; move the generated files
filenameending=strmid(onames(ifile),strlen(onames(ifile))-9,20)
 outname=strcompress(path+'ModelObserved_'+filenameending,/remove_all)
 file_move,'modelofobservation.fit',outname,/overwrite
 outname=strcompress(path+'Cleaned_'+filenameending,/remove_all)
 file_move,'cleaned.fit',outname,/overwrite
 outname=strcompress(path+'Scattered_'+filenameending,/remove_all)
 file_move,'scattered.fit',outname,/overwrite
 print,'Done! Now see results.dat'
 endfor	; ifile loop
 close,uw
 free_lun,uw
 end
 
