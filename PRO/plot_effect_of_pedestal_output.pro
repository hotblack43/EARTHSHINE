; Plots output from EFM_v3b.pro
;
!P.CHARSIZE=1
!P.MULTI=[0,2,4]
for iplot=1,2,1 do begin
if (iplot eq 1) then file=strcompress('effect_of_pedestal_cutoff_120.output.dat',/remove_all)
if (iplot eq 2) then file=strcompress('effect_of_pedestal_cutoff_070.output.dat',/remove_all)
spawnstr='grep '+'_B_'+' '+file+" | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14}' > datablock.dat"
spawn,spawnstr
;print,spawnstr
info=file_info('datablock.dat')
data=get_data('datablock.dat')
jd=reform(data(0,*))
;mlo_airmass,jd,am
nims=n_elements(jd)
alfa=reform(data(1,*))
offset=reform(data(2,*))
BS=reform(data(3,*))
tot1=reform(data(4,*))/512.d0/512.d0
tot2=reform(data(5,*))/512.d0/512.d0
DS1=reform(data(6,*))
DS2=reform(data(7,*))
measuredTexp=reform(data(8,*))
requestedTexp=reform(data(9,*))
am=reform(data(10,*))
x0=reform(data(11,*))
y0=reform(data(12,*))
radius=reform(data(13,*))
;
ped=100-findgen(n_elements(ds1))*5
idx=where(ped gt 50)
plot,ped(idx),alfa(idx),psym=7,ytitle='alfa',ystyle=3
plot,ped(idx),offset(idx)-ped(idx),psym=7,ytitle='Delta offset',ystyle=3
plot,ped(idx),BS(idx),psym=7,ytitle='BS',ystyle=3
plot,ped(idx),tot1(idx),psym=7,ytitle='tot1',ystyle=3
plot,ped(idx),tot2(idx),psym=7,ytitle='tot2',ystyle=3
plot,ped(idx),ds1(idx),psym=7,ytitle='ds1',ystyle=3
plot,ped(idx),ds2(idx),psym=7,ytitle='ds2',ystyle=3
plot,ped(idx),ds2(idx)/tot2(idx),psym=7,ytitle='ds2/tot2',ystyle=3
endfor
end
