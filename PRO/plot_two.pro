data=get_data('alfas_IRCUT_.dat')
jd1=reform(data(0,*))
IRC=reform(data(1,*))
data=get_data('alfas_B_.dat')
jd2=reform(data(0,*))
B=reform(data(1,*))
data=get_data('alfas_VE2_.dat')
jd3=reform(data(0,*))
VE2=reform(data(1,*))
data=get_data('alfas_VE1_.dat')
jd4=reform(data(0,*))
VE1=reform(data(1,*))
data=get_data('alfas_V_.dat')
jd5=reform(data(0,*))
V=reform(data(1,*))
;
!P.MULTI=[0,2,2]
Bint=interpol(B,jd2,jd1)
plot,xrange=[1,2],yrange=[1,2],IRC,Bint,psym=7,/isotropic,xtitle='IRCUT',ytitle='B'
VE2int=interpol(VE2,jd3,jd1)
plot,xrange=[1,2],yrange=[1,2],IRC,VE2int,psym=7,/isotropic,xtitle='IRCUT',ytitle='VE2'
VE1int=interpol(VE1,jd4,jd1)
plot,xrange=[1,2],yrange=[1,2],IRC,VE1int,psym=7,/isotropic,xtitle='IRCUT',ytitle='VE1'
Vint=interpol(V,jd5,jd1)
plot,xrange=[1,2],yrange=[1,2],IRC,Vint,psym=7,/isotropic,xtitle='IRCUT',ytitle='V'
print,'R(B,V): ',correlate(Bint,Vint)
print,'R(B,VE1): ',correlate(Bint,VE1int)
print,'R(B,VE2): ',correlate(Bint,VE2int)
print,'R(B,IRC): ',correlate(Bint,IRC)
print,'R(V,VE1): ',correlate(Vint,VE1int)
print,'R(V,VE2): ',correlate(Vint,VE2int)
print,'R(V,IRC): ',correlate(Vint,IRC)
print,'R(VE1,VE2): ',correlate(VE1int,VE2int)
print,'R(VE1,IRC): ',correlate(VE1int,IRC)
print,'R(VE2,IRC): ',correlate(VE2int,IRC)
;
!P.MULTI=[0,1,1]
nsmoo=3
plot,smooth(IRC,nsmoo),yrange=[1.4,2.9],xtitle='night #',ytitle='smoothed !7a!3'
oplot,smooth(Bint,nsmoo),color=fsc_color('blue')
oplot,smooth(VE2int,nsmoo),color=fsc_color('red')
oplot,smooth(VE1int,nsmoo),color=fsc_color('orange')
oplot,smooth(Vint,nsmoo),color=fsc_color('green')
!P.MULTI=[0,1,2]
plot,smooth(Bint,nsmoo)-smooth(Vint,nsmoo),ystyle=3,xtitle='night #',ytitle='!7a!3!dB!n - !7a!3!dV!n'
plot,smooth(Bint,nsmoo)-smooth(VE2int,nsmoo),ystyle=3,xtitle='night #',ytitle='!7a!3!dB!n - !7a!3!dVE2!n'
plot,smooth(Vint,nsmoo)-smooth(VE1int,nsmoo),ystyle=3,xtitle='night #',ytitle='!7a!3!dV!n - !7a!3!dVE1!n'
plot,smooth(Vint,nsmoo)-smooth(VE2int,nsmoo),ystyle=3,xtitle='night #',ytitle='!7a!3!dV!n - !7a!3!dVE2!n'
plot,smooth(VE1int,nsmoo)-smooth(VE2int,nsmoo),ystyle=3,xtitle='night #',ytitle='!7a!3!dVE1!n - !7a!3!dVE2!n'
end
