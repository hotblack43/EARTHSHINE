











;     2455858.0878125   1.7031944168   9.8668270571        14546.01833     76195284.68315     76195274.81632            6.90861            5.92431 B
 

file='collected_output_EFM_realimages_2455917_fixed.txt'
file='collected_output_EFM_realimages_2455858_fixed.txt'
filtername=['_B_','_V_','_VE1_','_VE2_','_IRCUT_']
!P.CHARSIZE=1
!P.MULTI=[0,7,5]
for ifilter=0,4,1 do begin
spawnstr='grep '+filtername(ifilter)+' '+file+" | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14}' > datablock.dat"
spawn,spawnstr
;print,spawnstr
info=file_info('datablock.dat')
if (info.size ne 0) then begin	
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
; select good data
kdx=where(measuredTexp gt 0.001)
data=data(*,kdx)
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
; convert to fluxes
tnorm=requestedTexp
tnorm=measuredTexp
;
tot1=tot1/tnorm
tot2=tot2/tnorm
DS1=DS1/tnorm
DS2=DS2/tnorm
BS=BS/tnorm
;
DS_BS=DS1/tot1
;
xrange=[min(JD-long(JD)),max(JD-long(JD))]
plot,psym=7,JD-long(JD),DS_BS,xtitle='Fractional day',ytitle='DS/BS',title=filtername(ifilter),ystyle=3,xrange=xrange
plot,psym=7,JD-long(JD),DS2,xtitle='Fractional day',ytitle='DS [cts/s]',title=filtername(ifilter),ystyle=3,xrange=xrange
plot,psym=7,JD-long(JD),BS,xtitle='Fractional day',ytitle='BS [cts/s]',title=filtername(ifilter),ystyle=3,xrange=xrange
plot,jd-long(jd),alfa,ystyle=3,psym=7,xtitle='Fractional day',ytitle='!7a!3',title=filtername(ifilter),xrange=xrange
plot,jd-long(jd),offset,ystyle=3,psym=7,xtitle='Fractional day',ytitle='Offset',title=filtername(ifilter),xrange=xrange
plot,jd-long(jd),measuredTexp,ystyle=3,psym=7,xtitle='Fractional day',ytitle='Exp time',title=filtername(ifilter),yrange=[0,max([measuredTexp,requestedTexp])],xrange=xrange
oplot,jd-long(jd),requestedTexp,psym=2,color=fsc_color('red')
plot,jd-long(jd),am,ystyle=3,psym=7,xtitle='Fractional day',ytitle='Airmass',title=filtername(ifilter),yrange=[1,max(am)],xrange=xrange
;
idx=where(jd-long(jd) gt .12)
;print,filtername(ifilter),mean(ds_bs),stddev(ds_bs),stddev(ds_bs)/sqrt(n_elements(ds_bs)),stddev(ds_bs)/sqrt(n_elements(ds_bs))/mean(ds_bs)*100.,' %'
print,format='(a,a,i3,a,f8.5,a,f4.1,a,f4.1,a)',filtername(ifilter),' & ',nims,' & ',mean(ds_bs(idx)),' & ',stddev(ds_bs(idx))/mean(ds_bs(idx))*100.,' & ',stddev(ds_bs(idx))/sqrt(n_elements(ds_bs(idx)))/mean(ds_bs(idx))*100.,'\\'
endif
endfor
end
