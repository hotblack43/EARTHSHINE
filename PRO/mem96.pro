
pro mem96, y, x, psf = psf, otf = otf,  scale=a, bg=b,  reg=reg,  error = error, $
                maxit=maxit, minit=minit, quiet=quiet
;+
;
; NAME:
;     mem96
; PURPOSE:
;     Deconvolve an image whose point spread function or 
;     optical transfer function  is known by use of maximum
;     entropy algorithm.
; CALLING SEQUENCE:
;     mem96, y, x, psf = psf, otf = otf, scale=scale, bg=bg,  $ 
;          reg=reg,  error = error, maxit=maxit, minit=minit
; INPUT:
;     y      input image to be deconvolved (!-D or 2-D)
;
; KEWORD INPUT:
;     psf     point spread function
;     otf     optical transfer function or  Fourier transform 
;              of point spread function. 
;               Either psf or otf should be given as input. 
;               Note that  both psf and otf  have their orgin of 
;               coordinate at lower left corner.
;     scale   scale coefficient a in Eq 3.17 
;                of Chae's thesis (Default = 1.)
;     bg      background coefficient b in Eq 3.17
;                of Chae's thesis (Default = 0.)
;     reg     dimentionless regularizing parameter given 
;                by Eq 3.36 (Default=1.E-2)
;     error   error criterion for stopping iteration (Default=1.E-4)
;     maxit   maximum iteration number (Default=50)
;     minit   minimum iteration number (Default=5)
;     quiet   if set, no display of intermediate results
;                 
;  OUTPUT:
;     x          deconvolved image
;  REQUIRED ROUTINES:  NONE                     
;  REFERENCE : Chae's Ph.D. Thesis
;  History:
;     witten by Jong Chul Chae, March 1996  
;
;-
;=--------------------- KEYWORD PARAMETERS SETTING ------------------
if not keyword_set(maxit)   then    maxit=50
if not keyword_set(minit)   then     minit=5
if not keyword_set( error)   then     error=1.0e-3
if not keyword_set(reg)      then      reg=1.0e-2
if not keyword_set(a)       then            a = 1. 
if not keyword_set(b)      then         b = 0.
if not keyword_set(quiet)  then  show=1 else show=0
if keyword_set(otf) then ftpsf=otf
if keyword_set(psf) then ftpsf=fft(psf, 1)

if show then begin
print, '  '
print, ' =============================================================='
print, '          Welcome to Maximum Entropy Method Program for Deconvolution       '
print, ' =============================================================='
endif

;=--------------------- INITIALIZATION ---------------------------------

s=size(y)

s1=s(1)
s2=s(2)
if show then begin
window,0, xs=s1, ys=s2
window, 1, xs=s1, ys=s2
endif
npixels = s1*s2
fty=fft(y, 1) 

tau2  = abs(ftpsf)^2
cftpsf =(temporary(ftpsf))
ftypsf = fty*temporary(cftpsf)




m=a*y+b
maxm=max(m)
m=m>(maxm*0.01)
x=(m-b)/a
lambda00=total(1./m)/n_elements(m)                        ; Eq 3.34
reg2=reg/lambda00

;-------------------------------------------------------------------

if show then begin
items = "    ITER #      BETA      1/LAMBDA     REG1         ERROR          "    
print, ' '
print, '    Now MEM iteration begins.'
print, '  '
endif 

fx=fft(x, 1)
iter=0
lambda=lambda00

; ===================== ITERATION BLOCK  BEGINNING==========================

repeat begin

lambda0=lambda
reg1 = reg2*lambda 

q = fft(a*alog((a*x+b)/m), 1)                                           ;  Eq 3.23 and 3.27

dfx = -((fx*tau2-ftypsf)+reg2*q)/(tau2+reg1)                 ;  Eq 3.27 and 3.33
dx = float(fft(dfx, -1)) 
  
beta1 = min((a*x+b)/((-a*dx)>0.00001*maxm))
beta = beta1*0.9 < 1.
x0=x+dx*beta 

fx=temporary(fx)+dfx*beta 


dx=x0-x
if iter le 100 then  $
      lambda= 0.5*(total((a*dx)^2/(a*x+b))/total(dx^2)+lambda0)  ;  Eq 3.31
x=temporary(x0) 
iter=iter+1


;---------------------------------------------------------------------
error1=max((dx)/maxm, min=mm) 
if error1 lt abs(mm) then error1=mm
converge = (abs(error1) le error)
converge = converge and (beta ge 0.8)
exceed = iter ge maxit

;  --------------------------------------------------------------------

if show then begin

 wset, 1
 tv, bytscl(dx, min=-0.005*maxm,max=0.005*maxm)
 wset, 0
 tvscl, x

  if iter mod 5 eq 0 then begin 
  print, '' 
  print, items 
  print, '' 
 endif

 print, ''
 check = string(iter,format='("   ", i3)') +string(beta, format='(" ",g10.3)') $
      +string(1./lambda, format='(" ",g10.3)')+string(reg1, format='(" ",e10.3)') $
     +string(error1, format='(" " ,g10.3)')
print, check

 if converge then print, ' Iteration has converged.'
 if exceed then print, '  Iteration # has excceeded maximum.'

endif

endrep until  (iter gt minit)  and (converge or exceed)

;========================== ITERATION BLOCK END ========================

if show then begin
tvscl, x
wait, 3
print, ''
print,  ' ============================================================ '
print,  '      End  of Maximum Entropy Method for Deconvolution                       '
print,  ' ============================================================ '  
endif
return
end 

