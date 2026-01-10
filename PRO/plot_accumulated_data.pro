file='accumulated_data.txt'
data=get_data(file)
jd=reform(data(0,*))
alt_moon=reform(data(1,*))
alt_sun=reform(data(2,*))
dist=reform(data(3,*))
fraction=reform(data(4,*))
phase_angle=reform(data(5,*))
;
!P.MULTI=[0,1,1]
histo, fraction,0,1,0.0125,xtitle='Illuminated fraction',ytitle='Fraction of observations (Cumulative)',title='Observability ideally',/cumul
idx=where(dist gt 30 and alt_moon gt 30)
histo, fraction(idx),0,1,0.0125,/cumul,/overplot
;
!P.MULTI=[0,1,2]
histo, fraction,0,1,0.0125,xtitle='Illuminated fraction',ytitle='Fraction of observations',title='Observability ideally'
N=n_elements(fraction)
print,'Ideal case:',N
histo, fraction(idx),0,1,0.0125,xtitle='Illuminated fraction',ytitle='Fraction of observations',title='Moon observability when Moon-Sun gt 30 deg, Moon above 30 deg, Sun below 0'
;
!P.MULTI=[0,1,1]
histo,phase_angle,-180,180,5,xtitle='Lunar phase',ytitle='Fraction of observations (Cumulative)',title='Moon observability',/cumul
histo, phase_angle(idx),-180,180,5,/cumul,/overplot
;
!P.MULTI=[0,1,4]
histo, phase_angle,-180,180,15,xtitle='Phase angle',ytitle='Fraction of observations',title='Observability ideally'

idx=where(dist gt 30 )
n30=float(n_elements(idx))
print,'% dist gt 30:',n30/N*100.0
histo,phase_angle(idx), -180,180,15,xtitle='Phase angle',ytitle='Fraction of observations',title='Moon observability when Moon-Sun gt 30 deg'

idx=where(dist gt 30 and alt_moon gt 45 )
n3045=float(n_elements(idx))
print,'% dist gt 30 and above 45:',n3045/N*100.0
histo,phase_angle(idx), -180,180,15,xtitle='Phase angle',ytitle='Fraction of observations',title='Moon observability when Moon-Sun gt 30 deg, Moon above 45 deg'

idx=where(dist gt 30 and alt_moon gt 45 and alt_sun lt 5)
n30455=float(n_elements(idx))
print,'% dist gt 30 and above 45 and sun set:',n30455/N*100.0
histo,phase_angle(idx), -180,180,15,xtitle='Phase angle',ytitle='Fraction of observations',title='Moon observability when Moon-Sun gt 30 deg, Moon above 45 deg, Sun below 5 deg'
end
