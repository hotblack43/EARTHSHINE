PRO support_g,capG,cut
; apply the Fourier domian support to capG
common mask,mask
common sizes,l
 n=l(0)
 x=indgen(N) # replicate(1,N)
 y=replicate(1,N) # indgen(N)
 r=sqrt((x-n/2.)^2+(y-n/2.) ^2)
 idx=where(r gt cut )
 jdx=where(r le cut )
	realpart=shift(double(capG),n/2.,n/2.)
	realpart(idx)=0.0
	realpart=shift(realpart,-n/2.,-n/2.)
	imagpart=shift(imaginary(capG),n/2.,n/2.)
	imagpart(idx)=0.0
	imagpart=shift(imagpart,-n/2.,-n/2.)
 	capG=complex(realpart,imagpart)
return
end
