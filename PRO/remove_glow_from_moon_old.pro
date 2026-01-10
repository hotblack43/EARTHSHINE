
PRO make_im_odd_dimensioned,im
; will make the number of rows and columns odd if they are not already
l=size(im,/dimensions)
if (fix(l(0)/2.) eq l(0)/2.) then begin
; the number of columns is even
im=im(0:l(0)-1-1,*)
endif
if (fix(l(1)/2.) eq l(1)/2.) then begin
; the number of rows is even
im=im(*,0:l(1)-1-1)
endif
return
end

PRO make_psf,im,psf,params
a1=params(0)
a2=params(1)
a3=params(2)
psf=im*0.0
l=size(im,/dimensions)
middle_col=fix(l(0)/2.)
middle_row=fix(l(1)/2.)
for i=0,l(0)-1,1 do begin
for j=0,l(1)-1,1 do begin
dist2=a3^2 *(float(i-middle_col)^2 + float(j-middle_row)^2)
psf(i,j)=a1*exp(-a2*dist2/2.)
;print,i,j,dist2,psf(i,j),(i-middle_col),(j-middle_row),middle_col,middle_row
;a=get_kbrd()
endfor
endfor
; shift the middle to the corner
psf=shift(psf,middle_col,middle_row)
; normalise the psf
psf=psf/total(psf)
;!P.MULTI=[0,1,1]
;surface,psf,charsize=3
;stop
return
end

!P.MULTI=[0,2,2]
window=0
file='stacked_new_349_float.FIT'
im=readfits(file)
; first make sure im has odd numbers of rows and columns
make_im_odd_dimensioned,im
im=float(im)/total(float(im))
l=size(im,/dimensions)
; then construct the PSF
params=[1.0d0,4d-4,1.0d0]
make_psf,im,psf,params
surface,psf
; convolve IM with PSF
res=float(fft(fft(im,-1,/double)*fft(psf,-1,/double),1,/double))*l(0)*l(1)
print,'CON area=',total(res)
scattered=res-im
surface,scattered,charsize=3
plot,scattered(*,250)
plot,scattered(*,250)
tvscl,scattered
end
