FUNCTION S,phase
; phase in degrees
; scattering law
t=0.1
part1=(sin(abs(phase*!dtor))+(!pi-abs(phase*!dtor))*cos(abs(phase*!dtor)))/!pi
part2=t*(1.-0.5*cos(abs(phase*!dtor)))^2
S=part1+part2
return,S
end

FUNCTION B,phase,g
; retrodirective function
; phase in degrees
if (phase*!dtor lt !pi/2.) then begin
    expfactor=exp(-g/tan(phase*!dtor))
	B=2.-tan(phase*!dtor)/2./g*(1.-expfactor)*(3.-expfactor)
endif
if (phase*!dtor ge !pi/2.) then begin
	B=1.0
endif
return,B
end

FUNCTION BRDF,theta_i,theta_r,phase
; theta_i,theta_r,phase	: angles in degrees
;
g=0.6
BRDF=2./3./!pi*B(phase,g)*s(phase)*1./(1.+cos(theta_r*!dtor)/cos(theta_i*!dtor))
return,BRDF
end

FUNCTION cotan,angle
; angle in degrees
cotan=cos(angle*!dtor)/sin(angle*!dtor)
return,cotan
end

FUNCTION Eem,phase
; phase in degrees
part1=sin((!pi-phase*!dtor)/2.)
part2=tan((!pi-phase*!dtor)/2.)
part3=alog(cotan((!pi-phase*!dtor)/4.))
Eem=0.19*0.5*(1.-part1*part2*part3)
return,Eem
end

;=========== PLOT BRDF =======================
!P.MULTI=[0,1,2]
phase=180.	; lunar phase (angle between incident and reflected light)
theta_i=45.	; angle between incident light and surface normal
x=fltarr(1000)*0+999
y=fltarr(1000)*0+999

i=0
for theta_r=-90,90,1 do begin
    x(i)=theta_r
    y(i)=BRDF(theta_i,theta_r,phase)
    i=i+1
endfor
x=x(where(x ne 999))
y=y(where(y ne 999))
plot,x,y,xtitle='Angle reflected vs. surf. normal',ytitle='BRDF',charsize=1.6,xstyle=1,title=strcompress('Phase='+string(phase))
;
x=fltarr(1000)*0+999
y=fltarr(1000)*0+999
i=0
for phase=0,180,1 do begin
	x(i)=phase
	y(i)=Eem(phase)
	i=i+1
endfor
x=x(where(x ne 999))
y=y(where(y ne 999))
plot,x,y,xtitle='Lunar phase',ytitle='Eem',charsize=1.6,xstyle=1,yrange=[-6,1]
end


