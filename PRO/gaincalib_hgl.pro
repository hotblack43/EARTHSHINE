 
 ;===============================================================================
 ;
 ; FUNCTION  gaincalib_hgl
 ;
 ; PURPOSE:
 ;       Produce a gain table from a set of images with relative offsets
 ;
 ; CALLING SEQUENCE:
 ;       flat = gaincalib_hgl(logimages, trueflat, x, y, mask=mask, object=object, C=C, $
 ;                        maxiter=maxiter, shiftmode=shiftmode, silent=silent)
 ;
 ; INPUT:
 ;       logimages   an array containing the logarithm of the observed images
 ;       trueflat    an array containing the true flat field
 ;       x           an array of x shifts (input, output, or both)
 ;       y           an array of y shifts (input, output, or both)
 ;
 ; OUTPUT:
 ;       Result      the gain table if the keyword ADDITIVE is not set
 ;                   or the offset table if the keyword is set.
 ; INPUT KEYWORDS:
 ;       maxiter     maximum no of iterations (default=10)
 ;       shiftmode   keyword parameter defining how to handle the shifts
 ;                   0,  x and y are treated as outputs (default)
 ;                         (this routine determines their initial guesses
 ;                          and iterates the values)
 ;                   1,  x and y are treated as both inputs and outputs
 ;                         (inputs are intial guesses and outputs are
 ;                          final values to be determined from iteration)
 ;                   2,  x and y are treated as inputs.
 ;                         (this program does not affect the values)
 ;       mask        binary array of the same format as the logimages which
 ;                   specifies the pixels to be used (1: use, 0:do not use,
 ;                   default is to use all the pixels).
 ;
 ;
 ; OUTPUT KEYWORD:
 ;        object      flat-field corrected object
 ;
 ; History:
 ;    1999 May,  Jongchul Chae
 ;    2003 November, Jongchul Chae
 ;    2004 July, Jongchul Chae. Added keyword: mask
 ;    2004 August. Generalized the keyword input array to be a 3-D one
 ;
 ; Version 2007-09-20
 ; Version June 2010
 ;===============================================================================
 
 FUNCTION  gaincalib_hgl, logimages, trueflat, x, y, object=object,  maxiter=maxiter, $
 silent=silent, c=c, RMSEflat=RMSEflat, shiftmode=shiftmode, mask=mask
 if (n_elements(maxiter) eq 0) then maxiter = 10
 s = size(logimages)
 Nx = s(1)
 Ny = s(2)
 Nf = s(3)
 
 ; set mask to default (=1)
 if (n_elements(mask) NE Nx*Ny*Nf) then begin
     mask = replicate(1B,Nx,Ny,Nf)
     endif
 
 ; set shiftmode to default
 if (n_elements(shiftmode) eq 0) then begin
     shiftmode = 0
     endif
 i = indgen(Nx) # replicate(1,Ny)
 j = replicate(1,Nx)#indgen(Ny)
 
 RMSEflat = dblarr(maxiter)
 
 ; initial estimate of the offsets
 ; this requires some initial guesses of the flat and the constant C
 if (shiftmode EQ 0) then begin
     
     x = dblarr(Nf)
     y = dblarr(Nf)
     flat = replicate(0.0,Nx,Ny)
     C    = replicate(0.0,Nf)
     
     ; for k=0,Nf-1 do begin
     ;   C[k] = median((logimages[*,*,k])[where(mask[*,*,k])])
     ; endfor
     
     ; for ix=0,Nx-1 do begin
     ;   for iy=0,Ny-1 do begin
     ;     flat[ix,iy] = total((logimages[ix,iy,*] - C)*mask[ix,iy,*])/(total(mask[ix,iy,*])>1.0)
     ;   endfor
     ; endfor
     ; flat = median(flat,5)
     
     ss = Nf/2 - 1
     ; reference = (logimages[*,*,ss] - median(logimages[*,*,ss]) - flat) * mask[*,*,ss]
     reference = (logimages[*,*,ss] - C[ss] - flat) * mask[*,*,ss]
     
     tmp = 0.0
     for k=0,Nf-1 do begin
         ; tmp = (logimages[*,*,k] - median(logimages[*,*,k]) - flat) * mask[*,*,k]
         tmp = (logimages[*,*,k] - C[k] - flat) * mask[*,*,k]
         sh  = alignoffset(tmp,reference)
         x(k) = sh(0)
         y(k) = sh(1)
         if (NOT keyword_set(silent)) then begin
             print, sh
             tvscl, shift_sub(tmp, -sh(0), -sh(1))
             endif
         endfor
     
     endif
 
 ; shift the reference position to the mean (nearest integer) position of all the observed images
 x = x - fix(round(total(x,/double)/Nf))
 y = y - fix(round(total(y,/double)/Nf))
 
 
 ; initial guesses of the flat field, the object, and the factor C
 flat = 0.0
 ; object = 0.0
 ; for k=0,Nf-1 do begin
 ;   object = object + logimages[*,*,k]
 ; endfor
 object = total(logimages,3,/double)/Nf
 C = dblarr(Nf)
 for k=0,Nf-1 do begin
     C(k) = total(logimages[*,*,k],/double)/(Nx*Ny) - total(object,/double)/(Nx*Ny)
     endfor
 C = C - total(C,/double)/Nf
 
 ; main iteration
 for iter=1,maxiter do begin
     
     aa=0.0 & bb=0.0
     for k=0, nf-1 do begin
         weight = (i+x(k) ge 0) and (i+x(k) le Nx-1) and (j+y(k) ge 0) and (j+y(k) le Ny-1)
         weight = weight*(shift_sub(mask[*,*,k],-x(k),-y(k)) ge 0.9)
         aa = aa + weight*( C(k) + object - shift_sub(logimages[*,*,k]-flat,-x(k),-y(k)) )
         bb = bb + weight
         endfor
     DelObject = -aa/(bb>1.0)
     Object = Object + DelObject
     aa  = 0.0 & bb=0.0
     avc = total(C,/double)/Nf
     avf = total(Flat,/double)/Nx/Ny
     avl = total(x,/double)/Nf
     avm = total(y,/double)/Nf
     
     for k=0,Nf-1 do begin
         
         weight = (i-x[k] GE 0 ) AND (i-x[k] LE Nx-1) AND (j-y[k] GE 0) AND (j-y[k] LE Ny-1)
         weight = weight*mask[*,*,k]
         object1 = shift_sub(Object, x[k], y[k])
         ob = (C(k) + object1 + Flat - logimages[*,*,k])*weight
         ; C[k] = C[k] -(total(ob,/double)+0.0*avc/Nf)/(total(weight,/double)+0.0/Nf/Nf)
         C[k] = 0.0
         
         if (shiftmode LE 1) then begin
             Oi = convol(Object1, [-1,8,0,-8,1]/12.0)
             Oj = convol(Object1, transpose([-1,8,0,-8,1]/12.0))
             x[k] = x[k] - total(ob*oi,/double)/total(weight*oi^2,/double)
             y[k] = y[k] - total(ob*oj,/double)/total(weight*oj^2,/double)
             endif
         
         aa = aa + ob
         bb = bb + weight
         
         endfor
     
     DelFlat = -(aa+0.0*avf/Nx*Ny)/(bb>1.0+0.0/(Nx*Ny)/(Nx*Ny) )
     Flat = Flat + DelFlat
     
     ; RMS error over the valid part of the flat
     indx = where(finite(trueflat),count)
     mn=moment(trueflat[indx],/NaN,/double)
     mtrueflat = mn(0)
     mn     = moment(10^(flat[indx]),/NaN,/double)
     ;mn     = moment(exp(flat[indx]),/NaN,/double)
     mflat     = mn(0)
     cf = mtrueflat/mflat
     mn=moment((cf*10^(flat) - trueflat)^2,/NaN,/double)
     ;mn=moment((cf*exp(flat) - trueflat)^2,/NaN,/double)
     RMSEflat[iter-1] = sqrt(mn(0))
     
     ; maximum increment for any pixel
     error = max(abs(Delflat))
     
;    wait, 0.1
     
     if not keyword_set(silent) then begin
         print, 'iteration #  =', iter , '  max(abs(dellogflat)))=', error
         endif
     if (error le 1.0e-7) then goto,final
     
     endfor
 
 final:
 mf = total(Flat,/double)/Nx/Ny
 mc = total(C,/double)/Nf
 object = object + mf + mc
 flat   = flat - mf
 c      = c - mc
 
 
 
 
 return, flat
 
 
 END
 
