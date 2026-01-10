PRO findfittedGaussian,rr_in,a,x00,y00
l=size(rr_in,/dimensions)
w=l(0)/2
rr=shift(rr_in,w,w)
res=gauss2dfit(rr,a,/TILT)
x00=a(4)-w
y00=a(5)-w
return
end

PRO smart_align_iter,im1_oin,im2_oin,shifts
l=size(im1_oin,/dimensions)
if (l(0) ne l(1)) then stop
w=l(0)
; Window
im1_in=im1_oin
im2_in=im2_oin
xs=0.0
ys=0.0
for iter=0,0,1 do begin
print,'-----------------------------------------------'
im1=im1_in
im2=shift_sub(im2_in,xs,ys)
contour,im1-im2,/cell_fill,/isotropic,xstyle=3,ystyle=3
im1=im1*hanning(w,w,/double)
im2=im2*hanning(w,w,/double)
;
if (iter eq 0) then F1=fft(im1,-1,/double)
F2=fft(im2,-1,/double)
;
R=f1*conj(f2)/(abs(F1)*abs(F2))
RR=double(FFT(R,1,/double))
idx=where(rr^2 eq max(rr^2))
; just find the integer pixel shift
coords1=array_indices(rr,idx)
;simonize,w,coords1
; Fitting a Gaussian
surface,abs(rr)
findfittedGaussian,rr,a,x00,y00
coords2=[x00,y00]
;simonize,w,coords2
; use the alignoffset method
coords3=alignoffset(im1,im2)
;simonize,w,coords3
;print,'shifts: ',coords1,coords2,coords3
print,'Errors: ',total((im1-shift_sub(im2,coords1(0),coords1(1)))^2),total((im1-shift_sub(im2,coords2(0),coords2(1)))^2),total((im1-shift_sub(im2,coords3(0),coords3(1)))^2)
printf,5,total((im1-shift_sub(im2,coords1(0),coords1(1)))^2),total((im1-shift_sub(im2,coords2(0),coords2(1)))^2),total((im1-shift_sub(im2,coords3(0),coords3(1)))^2)
xs=xs+coords3(0)
ys=ys+coords3(1)
;print,'xs,ys: ',xs,ys
endfor
print,'-----------------------------------------------'
return
end

PRO smart_align,im1_in,im2_in,shifts
l=size(im1_in,/dimensions)
if (l(0) ne l(1)) then stop
w=l(0)
; Window
im1=im1_in^2
im2=im2_in^2
im1=im1*hanning(w,w,/double)
im2=im2*hanning(w,w,/double)
;
F1=fft(im1,-1,/double)
F2=fft(im2,-1,/double)
;
R=f1*conj(f2)/(abs(F1)*abs(F2))
RR=FFT(R,1,/double)
idx=where(rr^2 eq max(rr^2))
; just find the integer pixel shift
coords1=array_indices(rr,idx)
simonize,w,coords1
; Fitting a Gaussian
res=gauss2dfit(double(rr),a,/TILT)
x00=a(4)
y00=a(5)
coords2=[x00,y00]
simonize,w,coords2
; use the alignoffset method
coords3=alignoffset(im1_in,im2_in)
simonize,w,coords3
print,coords1,coords2,coords3
print,total((im1-shift_sub(im2,coords1(0),coords1(1)))^2),total((im1-shift_sub(im2,coords2(0),coords2(1)))^2),total((im1-shift_sub(im2,coords3(0),coords3(1)))^2)
return
end

PRO simonize,w,coords
;print,'OLD:',coords
; will make sense of offset so they are not n-x but -x
if (coords(0) gt w/2) then coords(0)=coords(0)-w
if (coords(1) gt w/2) then coords(1)=coords(1)-w
;print,'NEW:',coords
return
end

; image alignment after Xie, Hicks etc.
openw,5,'shifts.dat'
files=file_search('~/Desktop/ASTRO/ANDREW/DATA/moon*',count=n)
for i=0,n-1,1 do begin
im=readfits(files(i),/SILENT)
l=size(im,/dimensions)
w=min(l)
im=im(0:w-1,0:w-1)
l=size(im,/dimensions)
if (l(0) ne l(1)) then stop
if (i eq 0) then imref=im
im1=im
im2=imref
if (i ne 0) then smart_align_iter,im1,im2,coords1
endfor
close,5
data=get_data('shifts.dat')
end
