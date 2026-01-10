PRO build_psf,a0,a,b,c,n,psf
 x=indgen(N) # replicate(1,N)
 y=replicate(1,N) # indgen(N)
 r=sqrt((x-n/2)^2+(y-n/2) ^2)
 psf=1./(a+b*r+c*r^2)
 idx=where(r eq min(r))
 psf(idx)=a0+max(psf)
 psf=psf/total(psf)
 psf=shift(psf,n/2,n/2.)
 return
end
