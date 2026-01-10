; Image deformation
im=readfits('dog1.fits')
l=size(im,/dimensions)
     Nx=l(0)
     Ny=l(1)
deformation_X=im*0.0
deformation_Y=im*0.0
newim=im*0.0
     XR = indgen(Nx)
     YC = indgen(Ny)
     X = double(XR # (YC*0 + 1))        ;     eqn. 1
     Y = double((XR*0 + 1) # YC)        ;     eqn. 2
n=5
factor=512.^n*100.
coeffs_X=randomn(seed,n,n)/factor
coeffs_Y=randomn(seed,n,n)/factor
for ip=0,n-1,1 do begin
for jp=0,n-1,1 do begin
deformation_X=deformation_X+coeffs_X(ip,jp)*x^ip*y^jp
deformation_Y=deformation_Y+coeffs_Y(ip,jp)*x^ip*y^jp
endfor
endfor
for i=0,l(0)-1,1 do begin
for j=0,l(1)-1,1 do begin
ii=i+deformation_X(i,j)
jj=j+deformation_Y(i,j)
if (ii lt 0) then ii=0
if (ii gt l(0)-1) then ii=l(0)-1
if (jj lt 0) then jj=0
if (jj gt l(1)-1) then jj=l(1)-1
newim(ii,jj)=im(i,j)
endfor
endfor
tvscl,[im,newim]
end

