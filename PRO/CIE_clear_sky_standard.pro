FUNCTION CIE_clear_sky_standard,chi,Z,Zs,a,b,c,d,e
 ; calculates the CIE Clear SKy Standard Luminance
 ;
 CIE_clear_sky_standard=f(chi,c,d,e)*psi(Z,a,b)/f(Zs,c,d,e)/psi(0.0,a,b)
 return, CIE_clear_sky_standard
 end
