im=readfits('flat.fits')
l=size(im,/dimensions)
im_o=im
n=l(0)
openw,44,'irreg.dat'
for i=0,n-1,1 do begin
for j=0,n-1,1 do begin
if (im(i,j) gt 0) then printf,44,i,j,im(i,j)
endfor
endfor
close,44
data=get_data('irreg.dat')
res=sfit(data,/irregular,1,kx=coeffs)
print,coeffs
contour,reform(data(2,*))-res,reform(data(0,*)),reform(data(1,*)),$
	/irregular,c_labels=findgen(10)*0+1,/isotropic,xstyle=3,$
	ystyle=3,nlevels=101,/downhill,charsize=2,/cell_fill
im=im*0.0
im(reform(data(0,*)),reform(data(1,*)))=reform(data(2,*))-res
idx=where(im_o eq 0)
zero=findgen(512,512)*0+1
zero(idx)=0
writefits,'out.fits',(im+1.0)*zero
end
