 FUNCTION petersfunc2,pars
 common ims,power,x0,y0,apex_out
 ; evaluates the object function 
 ;.................................................
 alfa=pars(0)
 beta=pars(1)
 factor=pars(2)
 ;if (alfa le 0) then alfa=0.1
 ;if (beta le 0 or beta ge 1) then beta=randomu(seed)
 
 print,'Guess:',alfa,beta
 l=size(power,/dimensions)
 ncol=l(0)
 nrow=l(1)
 apex=findgen(ncol,nrow)
 for i=0,ncol-1,1 do begin
 for j=0,nrow-1,1 do begin
 apex(i,j)=exp(-alfa*((i-x0)^2+(j-y0)^2)^beta)
 endfor
 endfor
 deviates=power-apex*factor
 ; as per instructions, must collapse 2d objective functions to 1D:
 dims=avg(deviates,1,/NaN)
 ldx=where(finite(dims))
 if (ldx(0) eq -1) then returnable =reform(dims)
 if (ldx(0) ne -1) then returnable=reform(dims(ldx))
 plot,returnable
	apex_out=apex
 ;-------------------------------------------------------------
 return,returnable
 end
 


 common ims,power,x0,y0,apex
im=readfits('TTAURI/TEMP/AVG_tau_TAURI0072.fits') 
l=size(im,/dimensions)
nrow=l(1)
ncol=l(0)
f=findgen(ncol,nrow)*0.0
for i=0,ncol-1,1 do begin
for j=0,nrow-1,1 do begin
f(i,j)=(-1)^(i+j)
endfor
endfor
out=im*f
;
z=ffT(im,-1) & zz=float(z*conj(z))
w=ffT(out,-1) & ww=float(w*conj(w))
tvscl,[zz,ww]
end
