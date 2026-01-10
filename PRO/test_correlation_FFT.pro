!P.multi=[0,4,4]
im=readfits('2709_ROLO_rotatedm90.fit')
im=reform(im(*,100))
for ish=5,150.,10. do begin
im2=shift(im,ish)
corr=c_correlate(im,im2,findgen(n_elements(im)))
x=fft(corr,-1,/double)
xx=x*conj(x)
xx=float(xx)
f=findgen(10)+5
plot_oo,f,xx/(2.*!pi*f),title=string(ish),xstyle=1,ystyle=1
endfor
end
