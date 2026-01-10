PRO get_FFT_shift,im_in,shifted_in,shiftx,shifty
im=im_in
shifted=shifted_in
;
shifted=reverse(shifted,1)
shifted=reverse(shifted,2)
z1=fft(im,-1)
z2=fft(shifted,-1)
corr=fft(z1*z2,1)
c=corr*conj(corr)
l=size(c,/dimensions)
big=-1e9
for i=0,l(0)-1,1 do begin
for j=0,l(1)-1,1 do begin
if (c(i,j) gt big) then begin
	big=c(i,j)
	big_i=i
	big_j=j
endif
endfor
endfor
shiftx=l(0)-1-big_i
shifty=l(1)-1-big_j
if (shiftx lt 0) then shiftx=l(0)+shiftx
if (shifty lt 0) then shifty=l(1)+shifty
return
end
