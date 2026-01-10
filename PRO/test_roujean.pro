FUNCTION f1,i,o,phase
; Roujean f1 kernel
value=1./2./!dpi*[(!dpi-phase)*cos(phase)+sin(phase)]*tan(i)*tan(o)$
     -1./!dpi*(tan(i)+tan(o)+sqrt(tan(i)^2+tan(o)^2-2.*tan(o)*tan(i)*cos(phase)))
return,value
end

FUNCTION f2,i,o,phase
; Roujean f2 kernel
coseta=cos(i)*cos(o)+sin(i)*sin(o)*cos(phase)
eta=acos(coseta)
value=4./(3.*!dpi*(cos(i)+cos(o)))*((!dpi/2.-eta)*coseta+sin(eta))-1./3.
return,value
end

FUNCTION reflectance,k0,k1,k2,i,o,phase
; equation 7 in Wu, li and Cihlar, 1995, JGR
reflectance=k0+k1*f1(i,o,phase)+k2*f2(i,o,phase)
return,reflectance
end

FUNCTION omega,k0,k1,k2,i,o,phase
; equation 11 in  Wu, li and Cihlar, 1995, JGR
a11=k1/k0
a21=k2/k0
value=1.+a11*f1(i,o,phase)+a21*f2(i,o,phase)
return,value
end

FUNCTION albedo,k0,k1,k2,i,phase
; equation 13 in Wu, li and Cihlar, 1995, JGR
Integral=0.0
for ph=0.0,2.*!dpi,2.*!dpi/360. do begin
for angle_o=0.0,!dpi/2.,!dpi/2./90. do begin
Integral=Integral+cos(angle_o)*cos(angle_o)*omega(k0,k1,k2,i,angle_o,ph)
endfor
endfor
value=reflectance(k0,k1,k2,i,angle_o,phase)/omega(k0,k1,k2,i,angle_o,phase)*Integral
return,value
end

phase=45.*!dtor
openw,33,'p'
a11=0.210
a21=1.629
k0=1.0
k1=a11*k0
k2=a21*k0
for i=0.0,!pi/2.,0.01 do begin
phase=i
printf,33,format='(2(1x,g14.5))',i/!dtor,albedo(k0,k1,k2,i,phase)
print,format='(2(1x,g14.5))',i/!dtor,albedo(k0,k1,k2,i,phase)
endfor
close,33
data=get_data('p')
plot,data(0,*),data(1,*)
end
