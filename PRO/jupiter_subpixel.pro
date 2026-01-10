function shift_sub, image, x0, y0, cubic=cubic
;+
; NAME: SHIFT_SUB
; PURPOSE:
;     Shift an image with subpixel accuracies
; CALLING SEQUENCE:
;      Result = shift_sub(image, x0, y0)
; HISTORY
;      2004 August, J. Chae, Added the keyword:cubic  for cubic spline interpolation option
;-


if fix(x0)-x0 eq 0. and fix(y0)-y0 eq 0. then return, shift(image, x0, y0)

s =size(image)
x=findgen(s(1))#replicate(1., s(2))
y=replicate(1., s(1))#findgen(s(2))
x1= (x-x0)>0<(s(1)-1.)
y1= (y-y0)>0<(s(2)-1.)
return, interpolate(image, x1, y1)
end

;---------------------------------------------------------------
nsub=2
ref=readfits('jupiter_ref.fits')
l=size(ref,/dimensions)
bias=readfits('DAVE_BIAS.fits')
ref=ref-bias
ref=rebin(ref,l(0)*nsub,l(1)*nsub)
files=file_search('/media/SAMSUNG/MOONDROPBOX/JD2455769/*JUPITER*.fits',count=n)
for i=0,n-1,1 do begin
print,i,' of ',n
im=double(readfits(files(i)))-bias
im=rebin(im,l(0)*nsub,l(1)*nsub)
if (i eq 0 and mean(im) gt 2) then stack=rebin(im,l(0),l(1))

shifts=alignoffset(im,double(ref),Cor)
imtoadd=rebin(shift_sub(im,-shifts(0),-shifts(1)),l(0),l(1))
print,moment(imtoadd)
if (i gt 0 and mean(imtoadd) gt 2) then stack=[[[stack]],[[imtoadd]]]
help,stack
endfor
im=avg(stack,2)
writefits,'jupiter_aligned_subpixels.fits',float(im+bias)
writefits,'jupiter_diff.fits',float(im+bias)-float(rebin(ref,l(0),l(1)))
end
