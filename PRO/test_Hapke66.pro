PRO get_k1_k2_j_and_k,alpha,gamma,g,k1,k2,j,k
 ; Table I of Hapke 66 paper.
 ;.................................................................
 if ((alpha ge -!pi/2. and alpha le !pi/2.) and (!pi/2.-alpha le g and g le !pi)) then begin
     ; Region 0
     k1=0.0
     k2=0.0
     j=!Values.F_NaN
     k=!Values.F_NaN
     print,'0'
     return
     endif
 ;.................................................................
 if ((alpha ge -!pi/2.+gamma and alpha le !pi/2.) and (!pi/2.-alpha-gamma le g and g le !pi/2.-alpha)) then begin
     ; Region 1
     k1=1.0
     k2=1.0
     j=1.0
     k=0.5
     print,'1'
     return
     endif
 ;.................................................................
 if ((alpha ge -!pi/2.+gamma and alpha le !pi/2.-gamma) and (0.0 le g and g le !pi/2.-alpha-gamma)) then begin
     ; Region 2
     k1=1.0
     k2=1.0
     j=0.5
     k=0.0
     print,'2'
     return
     endif
 ;.................................................................
 if ((alpha ge -!pi/2. and alpha le -!pi/2.+gamma) and (0.0 le g and g le !pi/2.-alpha-gamma)) then begin
     ; Region 3
     k1=1.0
     k2=1.0
     j=0.0
     k=0.5
     print,'3'
     return
     endif
 ;.................................................................
 if ((alpha ge -!pi/2. and alpha le -!pi/2.+gamma) and (!pi/2.-gamma-alpha le g and g le !pi-gamma)) then begin
     ; Region 4
     k1=1.0
     k2=1.0
     j=0.5
     k=1.0
     print,'4'
     return
     endif
 ;.................................................................
 if ((alpha ge -!pi/2. and alpha le -!pi/2.+gamma) and (!pi-gamma le g and g le !pi/2.-alpha)) then begin
     ; Region 5
     k1=1.0
     k2=0.0
     j=!Values.F_NaN
     k=!Values.F_NaN
     print,'5'
     return
     endif
 print,'Have to stop now. Found: alpha,gamma,g: ',alpha/!dtor,gamma/!dtor,g/!dtor
 stop
 end
 
 
 PRO hapke66_L,L,alpha,gamma,f,g
 ; Reference: Hapke, AJ vol 71, p.333-339, 1966.
 ; INPUTS:
 ;        alpha is the luminance longitude
 ;        gamma is an angle describing the bumps on the lunar surface
 ;            g is the phase angle
 ; Note - all arguments of cos and sin are of course in RADIANS
 get_k1_k2_j_and_k,alpha,gamma,g,k1,k2,j,k
 ; terms
 square_bracket_term1=cos(alpha+j*g)*sin(gamma+k*g)
 terminsideabs=(cos(alpha+j*g)+sin(gamma+k*g))/(cos(alpha+j*g)-sin(gamma+k*g))
 square_bracket_term2=-0.5*sin(0.5*g)*sin(0.5*g)*alog(abs(terminsideabs))
 ; NB : there MUST be a typo in Hapke formula 11 ! (brackets in wrong order)
 ;
 L=0.0
 if (k2 eq 0) then L=k1*(1.-f)/(1.+cos(alpha)/cos(alpha+g))
 if (k1 eq 0) then L=k2*f/(2.*cos(0.5*g)*cos(alpha)*sin(gamma))*(square_bracket_term1+square_bracket_term2)
 if (k1*k2 ne 0) then L=(k1*(1.-f)/(1.+cos(alpha)/cos(alpha+g))+k2*f/(2.*cos(0.5*g)*cos(alpha)*sin(gamma)))*(square_bracket_term1+square_bracket_term2)
 return
 end
 
 ;...................................................................
 gamma=44.0d0	; trial value
 f=0.90d0
 for alpha=-89.d0,89.d0,1.d0 do begin
     for g=1.d0,179.d0,1.d0 do begin
         hapke66_L,L,alpha*!dtor,gamma*!dtor,f,g*!dtor
         print,'L: ',L,' a: ',alpha,' gamma: ',gamma,' f: ',f,' g: ',g
         endfor
     endfor
 end
