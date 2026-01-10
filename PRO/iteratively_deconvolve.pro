 ;--------------------------------------------------------------------------
 ; Aplies the iterative deconvolution of
 ; Saha and Venkatakrsihnan Bull Ast Soc Ind. 1997
 ; will result in two output FITS files - the estimets of the
 ; deconvolved image (f.fit) and the PSF (g.fit)
 ;--------------------------------------------------------------------------
 common sizes,l
 common imagedescrip,noise
 niter=1000
 old_err=1d33
 beta=0.7d0
 errlim=1.0d-11
 real_flag=1
 ;--------------------------------------------------------------------------
 ; get the image to be deconvolved
 getimage,c_image
 writefits,'thiswasinput.fit',c_image
 ;...........................
 capC=fft(c_image,-1,/double)
 window,0,title='convolved image',xsize=l(0),ysize=l(1) & tvscl,c_image
 ;...........................
 ; set up the noise frame, N(0,std)
 ;Nframe=randomn(seed,l(0),l(1))
 Nframe=randomn(seed,l(0),l(1))*noise*2.
 ;Nframe=Nframe*0.0+1.0
 capN=fft(Nframe,-1,/double)
 ;...........................
 ; set up the starting guess of PSF P 
 ; use various tricks ...
 n= l(0)
 x=indgen(N) # replicate(1,N)
 y=replicate(1,N) # indgen(N)
 r=sqrt((x-n/2)^2+(y-n/2) ^2)
 P=exp(-r^2/200.) & P=shift(P,n/2.,n/2.)
 ;P=randomn(seed,l(0),l(1))^2+1.0
 ;P=c_image^2
 capP=fft(P,-1,/double)
 ;...........................
 ; OK, main iterative loop starts
factor=2.0
 for iter=0,niter-1,1 do begin
     capO = capC*(conj(capP)/(capP*conj(capP)+capN*conj(capN)))
     littleo=fft(capO,1,/double)
     littleo=float(littleo)
     window,1,title='O',xsize=l(0),ysize=l(1) & tvscl,littleo
     redistribute2,littleo,errlim
     capO=fft(littleo,-1,/double)
     capP = capC*(conj(capO)/(capO*conj(capO)+capN*conj(capN)))
     P=fft(capP,1,/double)
     P=float(P)
     show_g,P
     redistribute2,P,errlim
     do_residuals,littleo,P,c_image,shouldbeoriginal,iter,l,old_err
 ;	Nframe=randomn(seed,l(0),l(1))*noise*factor
 ;	capN=fft(Nframe,-1,/double)
;	factor=factor*0.98
 endfor
 writefits,'folded.fit', shouldbeoriginal
 end
