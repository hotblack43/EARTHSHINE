function gaincalib, logimages, x, y, object=object,  maxiter=maxiter, $
   silent=silent, c=c, shift_flag=shift_flag, mask=mask
;+
;  NAME:  GAINCALIB
;  PURPOSE:    Produce  a gain table  from a set of images with relative offsets
;  CALIING SEQUENCE:
;          logflat = gaincalib(logimages, x, y, object=object, )
; INPUT:
;          logimages  a three-dimensional array representing
;                    a sequence of logarithm of two-dimensional images
;                    images(*,*,k) ( k=0, 1,.., N-1).
;          x        an array of x-shift (input or output or both)
;          y        an array of y-shift  (input or output ot both)
;
; OUTPUT:
;        Result     the gain table if the keyword  ADDITIVE is not set
;                   or the offset table if the keyword is set.
; INPUT KEYWORDS:
;        maxiter   maximum # of iternation (default=5)
;        shift_flag   keyword parameter containing information on how to handle
;                     shift values.
;    If set equal to 0,  x and y are treated as outputs (default)
;                            (this routine determines their initial guesses
;                            and iterates the values)
;                    1,  x and y are treated as both inputs and outputs
;                           (inputs are intial guesses and outputs are
;                             final values to be determined from iteration)
;                    2,  x and y are treated as inputs.
;                            (this program does not affect the values)
;       mask      binary array of the same format as the logimages
;                 which specifies the pixels to be used (1: use, 0:do not use)
;                 default is to use all the pixels.

;
; OUTPUT KEYWORD:
;        object      flat-field corrected object
; History:
;    1999 May,  Jongchul Chae
;    2003 November, Jongchul Chae
;    2004 July, Jongchul Chae. Added keyword: mask
;    2004 August. Generalized the keyword input array to be a 3-D one
;-

if n_elements(maxiter) eq 0 then maxiter=10
s=size(logimages)
nx=s(1)
ny=s(2)
nf=s(3)

if n_elements(mask) ne nx*ny*nf then mask = replicate(1B, nx, ny, nf)


if n_elements(shift_flag) eq 0 then shift_flag=0
i = indgen(nx)#replicate(1, ny)
j = replicate(1, nx)#indgen(ny)

; Initial Estimate of l and m
if shift_flag eq 0 then begin
x=fltarr(nf)
y=fltarr(nf)
flat = replicate(0., nx, ny)
c = fltarr(nf)

for k=0, nf-1 do c(k)=median((logimages(*,*,k))[where(mask(*,*,k))])

tmp = 0.
for ix=0, nx-1 do for jy=0, ny-1 do  $
flat[ix,jy] =  total((logimages(ix,jy, *)-c)*mask(ix, jy,*))/(total(mask(ix, jy, *))>1.)


flat=median(flat, 5)

ss=nf/2-1
reference = (logimages(*,*,ss) -median(logimages(*,*,ss))- flat)*mask(*,*,ss)
for k=0, nf-1 do begin
tmp=(logimages(*,*,k) - median(logimages(*,*,k))-flat)*mask(*,*,k)

sh =  alignoffset(tmp, reference )
x(k) = sh(0)
y(k) = sh(1)
if not keyword_set(silent) then begin
 print, sh
 tvscl, shift_sub(tmp, -sh(0), -sh(1))

 endif

endfor
endif



x=x-total(x)/nf
y=y-total(y)/nf





 ; Initial Estimates of Flat, Object, C



 Flat=0.


 ;Object = 0.
 ;for k=0, nf-1 do Object = Object + logimages(*,*,k)

 Object = total(logimages, 3)/nf


 C = fltarr(nf)
 for k=0, nf-1 do $
   C(k)=total(logimages(*,*,k))/(nx*ny)-total(Object)/(nx*ny)

C=C-total(C)/nf

  ; Start Iteration
t1=systime(/secon)

 for iter=1, maxiter do begin


     aa=0.0 & bb=0.0
    for k=0, nf-1 do begin
    weight = (i+x(k) ge 0) and (i+x(k) le nx-1) $
               and (j+y(k) ge 0) and (j+y(k) le ny-1)

    weight=weight*(shift_sub(mask(*,*,k), -x(k), -y(k)) ge 0.9)
    aa = aa + (C(k) +Object $
      -shift_sub(Logimages(*,*,k)-Flat, -x(k), -y(k)) )*weight
    bb = bb+weight
    endfor
   DelObject = -  aa/(bb>1.)
   Object = Object + DelObject

    aa=0. & bb=0.0
    avc= total(C)/nf
    avf=total(Flat)/nx/ny
    avl = total(x)/nf
    avm = total(y)/nf

    for k=0, nf-1 do begin
    weight = (i-x(k) ge 0 ) and (i-x(k) le nx-1) $
               and (j-y(k) ge 0 )and (j-y(k) le ny-1)
    weight=weight*mask(*,*,k)
    object1 =shift_sub(Object,  x(k), y(k))
    ob = (C(k)+object1+Flat-  $
             Logimages(*,*,k))*weight
    C(k) = C(k) -(total(ob)+0.*avc/nf)/(total(weight)+0./nf/nf)

    if shift_flag le 1   then begin
    Oi = convol(Object1, [-1, 8, 0, -8, 1]/12.)
    Oj = convol(Object1, transpose([-1, 8, 0, -8, 1]/12.))
    x(k)=x(k)-total(ob*oi)/total(weight*oi^2)
    y(k)=y(k)-total(ob*oj)/total(weight*oj^2)
     endif
    aa = aa + ob
    bb = bb+weight
     endfor

DelFlat = -(aa+0.*avf/nx*ny)/(bb>1.+0./(nx*ny)/(nx*ny) )
Flat = Flat+DelFlat
error = max(abs(Delflat))
wait, 0.1
if not keyword_set(silent) then    print, 'iteration #  =', iter , '  max(abs(dellogflat)))=', error


if error le 1.0e-8 then goto,  final
endfor

final:

mf = total(Flat)/nx/ny
mc=total(C)/nf
object = object+mf+mc
flat = flat-mf
c = c-mc
t2=systime(/secon)

if not keyword_set(silent) then print, t2-t1, ' seconds elapsed in GAINCALIB iteration'
return, flat
end

