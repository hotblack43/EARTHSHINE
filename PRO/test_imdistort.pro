FUNCTION minimize_me, X, Y, P
 common distortions,xi,yi,delta_x,delta_y
 common ims,im,warped
 n=n_elements(p)/2
 new_delta_x=p(0:n-1)
 new_delta_y=p(n:2*n-1)
 ; Run POLYWARP to obtain a Kx and Ky:
 Xo=xi+new_delta_x
 Yo=yi+new_delta_y
 POLYWARP, XI, YI, XO, YO, 3, KX, KY,/double,status=hej
	if (hej ne 0) then begin
	 print,'STATUS: ',hej
	 stop
	endif
 ; Create a warped image based on Kx and Ky with POLY_2D:
 new_warped = POLY_2D(warped, KX, KY,cubic=-0.5)
 tvscl,hist_equal((im-new_warped)/(im))
 residual=((im-new_warped)/(im))^2
 print,'RMSE: ',sqrt(total(residual,/double))
 return, new_warped
 END
 
 PRO gofinddistorion,m,delta_x_found,delta_y_found
 common ims,im,warped
 l=size(im,/dimensions)
 Nx=l(0)
 Ny=l(1)
 XR = indgen(Nx)
 YC = indgen(Ny)
 X = double(XR # (YC*0 + 1))        ;     eqn. 1
 Y = double((XR*0 + 1) # YC)        ;     eqn. 2
 start_parms=1.1d0*randomn(seed,m)
 weights=im*0.0+1.00d0
 z=im     ; target 
 ; set up the PARINFO array - indicate double-sided derivatives (best)
 parinfo = replicate({mpside:0, value:0.D, $
 fixed:0, limited:[0,0], limits:[0.D,0],step:1.0d-9}, m)
 parinfo[*].value = start_parms
 results = MPFIT2DFUN('minimize_me', X, Y, Z, weights=weights, $
 PARINFO=parinfo,perror=sigs,STATUS=hej,xtol=1d-11,yfit=yhat)
 ; Print the solution point:
 print,'STATUS=',hej
 delta_x_found=results(0:m/2-1)
 delta_y_found=results(m/2:m-1)
 return
 end
 
 
 PRO gomakedistorted,im,warped
 common distortions,xi,yi,delta_x,delta_y
 ; Get the dimensions of the image
 w=10	; distnace from edges
 cad=130	; step size across image
 ic=0
 for i=w,511-w,cad do begin
     for j=w,511-w,cad do begin
         if (ic eq 0) then begin
             xi=i
             yi=j
             endif else begin
             xi=[xi,i]
             yi=[yi,j]
             endelse
         ic=ic+1
         endfor
     endfor
 n=n_elements(xi)
 ampl=1.1d0
 x_offset=0
 y_offset=-0
 delta_x=ampl*randomn(seed,n)+x_offset
 delta_y=ampl*randomn(seed,n)+y_offset
 xo=xi+delta_x
 yo=yi+delta_y
 warped= WARP_TRI( Xo, Yo, Xi, Yi, Im,/QUINTIC)
 return
 end
 
 ;.................................................
 ; code to test the spatial distortion of an image
 common distortions,xi,yi,delta_x,delta_y
 common ims,im,warped
 ;im=readfits('./FITS/quitespecialMOONideal.fits')
 im=readfits('./BMINUSVWORKAREA/ideal_JD2455945.fits')
 im=double(im);
im=im+0.0005*max(im)
 ; Create the distorted image:
 gomakedistorted,im,warped
 writefits,'a.fits',im
 writefits,'b.fits',warped
 print,'RMSE im vs warped: ',sqrt(total((im-warped)^2))
 m=n_elements(delta_x)
 print,'There are ',m,' 2-D distortion points.'
tvscl,[hist_equal(im),hist_equal(warped),hist_equal(im-warped)]
a=get_kbrd()
 ; Now find the distortion by fitting
 gofinddistorion,2*m,delta_x_found,delta_y_found
!P.MULTI=[0,1,2]
plot,delta_x,delta_x_found,psym=7,/isotropic,xtitle='Actual X distortion',ytitle='Fitted X distortion'
oplot,[!X.crange],[0,0],linestyle=1
oplot,[0,0],[!Y.crange],linestyle=1
plot,delta_y,delta_y_found,psym=7,/isotropic,xtitle='Actual Y distortion',ytitle='Fitted Y distortion'
oplot,[!X.crange],[0,0],linestyle=1
oplot,[0,0],[!Y.crange],linestyle=1
print,'err x: ',total((delta_x-delta_x_found)^2)
print,'err y: ',total((delta_y-delta_y_found)^2)
print,'err x: ',total((delta_x+delta_x_found)^2)
print,'err y: ',total((delta_y+delta_y_found)^2)
 end
