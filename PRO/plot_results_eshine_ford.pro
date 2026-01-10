file='results.Earth0.3Lambert'
data=get_data(file)
JD=reform(data(0,*))
Isun=reform(data(1,*))
Iearth=reform(data(2,*))
ph_M=reform(data(3,*))
ph_E=reform(data(4,*))
plot,abs(ph_E),Iearth,xtitle='Pahse angle!dE!n',ytitle='Intensity',charsize=2,title='eshine_16.pro vs. EarthRef.f90 as Lambert/0.3',yrange=[0.001,0.1]; ,/ylog
;---------- get EartRef output
file='/home/pth/SCIENCEPROJECTS/EARTHSHINE/FORDCOD/Progs/EarthRef/EarthRef_Lambert0.3.out'
data=get_data(file)
p_E2=reform(data(0,*))
Iearth2=reform(data(1,*))
oplot,p_E2,Iearth2/1000.0,psym=7

end
