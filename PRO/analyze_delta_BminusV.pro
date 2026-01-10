data=get_data('delta_BminusV.dat')
JD=reform(data(0,*))
B1=reform(data(1,*))
V1=reform(data(2,*))
B2=reform(data(3,*))
V2=reform(data(4,*))
dB=b1-b2
dBV1=b1-v1
dv=v1-v2
dBV2=b2-v2
print,'-------------------------------------------------------'
print,'Mean B1-B2: ',mean(db),' SD: ',stddev(db),' SD_m :',stddev(db)/sqrt(n_elements(db)-1)
print,'Mean V1-V2: ',mean(dv),' SD: ',stddev(dv),' SD_m :',stddev(dv)/sqrt(n_elements(dv)-1)
print,'-------------------------------------------------------'
print,'Mean B1-V1: ',mean(dbv1),' SD: ',stddev(dbv1),' SD_m :',stddev(dbv1)/sqrt(n_elements(dbv1)-1)
print,'Mean B2-V2: ',mean(dbv2),' SD: ',stddev(dbv2),' SD_m :',stddev(dbv2)/sqrt(n_elements(dbv2)-1)
print,'-------------------------------------------------------'
end

