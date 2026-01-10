PRO findafittedlinearsurface,im,mask,thesurface
l=size(im,/dimensions)
     Nx=l(0)
     Ny=l(1)
     XR = indgen(Nx)
     YC = indgen(Ny)
     X = double(XR # (YC*0 + 1))        ;     eqn. 1
     Y = double((XR*0 + 1) # YC)        ;     eqn. 2
;----------------------------------------
offset=mean(im(0:10,0:10))
thesurface=findgen(512,512)*0.0
mim=mask*im
get_lun,wxy
openw,wxy,'masked.dat'
for i=0,511,1 do begin
for j=0,511,1 do begin
if (mim(i,j) ne 0.0) then begin
printf,wxy,i,j,mim(i,j)
endif
endfor
endfor
close,wxy
free_lun,wxy
data=get_data('masked.dat')
res=sfit(data,/IRREGULAR,1,kx=coeffs)
print,coeffs
thesurface=coeffs(0,0)+coeffs(1,0)*y+coeffs(0,1)*x+coeffs(1,1)*x*y
thesurface=thesurface+offset
return
end
