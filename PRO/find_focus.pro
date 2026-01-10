PRO fit_2d_gauss,im_in,b
        im=im_in
        weights=1.0d0/im
        kdx=where(im le 0)
        if (kdx(0) ne -1) then weights(kdx)=0.0
if (file_exist('bs') eq 1) then begin
b=reform(get_data('bs'))
endif
        yfit = mpfit2dpeak(im, B,/MOFFAT,weights=weights)
openw,1,'bs'
printf,1,format='(10(1x,f20.8))',b
close,1
 residuals=im-yfit
        print,'total reisudal:',sqrt(total(residuals^2))
print,'Offset :',b(0)
print,'Scale  :',b(1)
b(1)=b(1)/mean(im)
print,'Scale after normalizing flux  :',b(1)
print,'sigmas :',b(2),b(3)
print,'X0,Y0  :',b(4),b(5)
print,'tilt   :',b(6)
print,'power  :',b(7)
return
end


bias=readfits('superbias.fits')
openw,44,'B_moffat_fitted.dat'
files=file_search('~/245*B_FOCU*.fits',count=n)
print,'Found ',n,' files.'
for j=0,n-1,1 do begin
im=readfits(files(j))
print,files(j)
l=size(im,/dimensions)
for i=0,l(2)-1,1 do begin
subim=reform(im(*,*,i))-bias
if max(subim gt 410) then begin
idx=where(subim eq max(subim))
coords=array_indices(subim,idx)
print,coords
fit_2d_gauss,subim,b
relvar=stddev(subim,/double)/mean(subim,/double)
print,format='(9(1x,f12.5),1x,a)',b,relvar,files(j)
printf,44,format='(9(1x,f12.5),1x,a)',b,relvar,files(j)
endif
endfor
endfor
close,44
end
