PRO gethedata,file,alfa,a,BS,tot2,ds1,ds2,offset,cutoff,ds_BS
data=get_data(file)
alfa=reform(data(0,*))
a=reform(data(1,*))
BS=reform(data(2,*))
tot2=reform(data(3,*))
ds1=reform(data(4,*))
ds2=reform(data(5,*))
offset=reform(data(9,*))
cutoff=reform(data(10,*))
ds_BS=ds2/tot2
return
end

!P.CHARSIZE=2
file='collected_output_EFM_v5.txt'
gethedata,file,alfa,a,BS,tot2,ds1,ds2,offset,cutoff,ds_BS
file='collected_output_EFM_v5_ideal.txt'
gethedata,file,alfa_ideal,a_ideal,BS_ideal,tot2_ideal,ds1_ideal,ds2_ideal,offset_ideal,cutoff_ideal,ds_BS_ideal
idx=where(ds_BS gt 1e-8); and offset gt 30)
!P.MULTI=[0,1,2]
plot,offset(idx),ds_BS(idx),xtitle='Imposed offset',ytitle='DS/BS',psym=7,ystyle=3,xstyle=3
plot,cutoff(idx),ds_BS(idx),xtitle='Imposed cutoff',ytitle='DS/BS',psym=7,ystyle=3,xstyle=3
;
print,'alfa:',mean(alfa(idx)),' +/- ',stddev(alfa(idx)),' or ',stddev(alfa(idx))/mean(alfa(idx))*100.0,' %.'
print,'DS/BS:',mean(ds_BS(idx)),' +/- ',stddev(ds_BS(idx)),' or ',stddev(ds_bs(idx))/mean(ds_bs(idx))*100.0,' %.'
print,'DS/BS ideal:',mean(ds_BS_ideal)
print,'DS/BS bias:',(mean(ds_BS(idx))-mean(ds_BS_ideal))/mean(ds_BS_ideal)*100.,' %.'
end
