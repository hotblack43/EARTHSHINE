FUNCTION lamda_effective,Sun,Filter,QEtab
QE=interpol(QEtab(1,*),QEtab(0,*),filter(0,*))

flux=interpol(Sun(1,*),Sun(0,*),filter(0,*))
l_eff=int_tabulated(filter(0,*),filter(0,*)*filter(1,*)*flux*QE)/int_tabulated(filter(0,*),filter(1,*)*flux*QE)
return,l_eff
end

; get CCD quantum efficiency
QE=get_data('QE_Andor_897.txt')
;B
B=get_data('./STAMmodels/DATA/B_transmission.dat')
V=get_data('./STAMmodels/DATA/V_transmission.dat')
VE1=get_data('./STAMmodels/DATA/VE1_transmission.dat')
VE2=get_data('./STAMmodels/DATA/VE2_transmission.dat')
IRCUT=get_data('./STAMmodels/DATA/IRCUT_transmission.dat')
; get spectgrum of SUn
Sun=get_data('wehrli85.txt')
; B
print,'B effective wavelength : ',lamda_effective(Sun,B,QE)
print,'V effective wavelength : ',lamda_effective(Sun,V,QE)
print,'VE1 effective wavelength : ',lamda_effective(Sun,VE1,QE)
print,'VE2 effective wavelength : ',lamda_effective(Sun,VE2,QE)
print,'IRCUT effective wavelength : ',lamda_effective(Sun,IRCUT,QE)
end
