data=get_data('new_newer_newest.collected_Lap_signature_results.txt')
jd1=reform(data(0,*))
albedo1=reform(data(1,*))
jd2=reform(data(2,*))
albedo2=reform(data(3,*))
jd3=reform(data(4,*))
albedo3=reform(data(5,*))
;
a1minus2=albedo1-albedo2
a1minus3=albedo1-albedo3
a2minus3=albedo2-albedo3
;
!P.charsize=1.9
histo,/abs,xtitle='DIfference in albedo',a1minus2,min(a1minus2),max(a1minus2),(max(a1minus2)-min(a1minus2))/77.
print,'       SD: ',stddev(a1minus2)
help,where(abs(a1minus2) gt 3.*stddev(a1minus2))
print,'robust SD: ',robust_sigma(a1minus2)
help,where(abs(a1minus2) gt 3.*robust_sigma(a1minus2))
idx=where(abs(a1minus2) lt 3.*robust_sigma(a1minus2))
!P.color=fsc_color('red')
histo,/overplot,/abs,a1minus3(idx),min(a1minus2),max(a1minus2),(max(a1minus2)-min(a1minus2))/77.
end
