PRO get_thetas,lamda,f,r,d,theta_i,theta_r
; all angles in degrees
c=sqrt(d*d+r*r-2.0d0*d*r*cos(lamda*!dtor))
delta=asin(d/c*sin(lamda*!dtor))/!dtor
theta_i=180.+lamda-f
theta_r=180.-delta
return
end


function Wann_f,g,t,f,theta_r,theta_i
; f and the thetas  is in degrees
b=2.d0-tan(f*!dtor)/2.d0/g*(1.d0-exp(-g/tan(f*!dtor)))*(3.d0-exp(-g/tan(f*!dtor)));
s=(sin(abs(f*!dtor))+(!pi-abs(f*!dtor))*cos(abs(f*!dtor)))/!pi + t*(1.d0-cos(abs(f*!dtor))/2.d0)^2;
fun=(2.d0/3.d0/!pi)*b*s/(1.d0+cos(theta_r*!dtor)/cos(theta_i*!dtor));
return,fun
end

g=0.6
t=0.1
r=3476./2.0
d=384000.0
n=1000
lamda=findgen(n)/float(n)*10.+80.
for phase=0.0,10.0,2 do begin
get_thetas,lamda,phase,r,d,theta_i,theta_r
if (phase eq 0) then plot_io,xstyle=3,xrange=[78,90],lamda,Wann_f(g,t,phase,theta_r,theta_i),psym=7
if (phase eq 0) then oplot,lamda,Wann_f(g,t,phase,theta_r,theta_i),color=fsc_color('red')
if (phase gt 0) then oplot,lamda,Wann_f(g,t,phase,theta_r,theta_i),color=fsc_color('green')
endfor
end
