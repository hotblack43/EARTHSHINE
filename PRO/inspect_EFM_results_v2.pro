; Plots output from EFM_v3b.pro
;
night='2455864'
night='2455924'
night='2455923'
night='2455917'
night='2455858'
night='2456000'
night='2456002'
night='2456003'
night='2456005'
night='2456006'
night='2456007'
night='2456004'
get_lun,ww
openw,ww,'many_ratios.dat'
for ni=2456000L,2456007L,1 do begin
night=string(ni)
file=strcompress('collected_output_EFM_realimages_'+night+'.txt',/remove_all)
;file=strcompress('collected_output_EFM_realimages_'+night+' '+'_fixed.txt',/remove_all)
filtername=['_B_','_V_','_VE1_','_VE2_','_IRCUT_']
!P.CHARSIZE=1
!P.MULTI=[0,7,5]
for ifilter=0,4,1 do begin
spawnstr='grep '+filtername(ifilter)+' '+file+" | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14}' > datablock.dat"
spawn,spawnstr
info=file_info('datablock.dat')
if (info.size ne 0) then begin	
data=get_data('datablock.dat')
jd=reform(data(0,*))
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
tnorm=measuredTexp
tnorm=requestedTexp
;
tot1=tot1/tnorm
tot2=tot2/tnorm
DS1=DS1/tnorm
DS2=DS2/tnorm
BS=BS/tnorm
;
;DS_BS=DS1/tot2
;DS_BS=DS1/BS
DS_BS=DS2/tot2
;
xrange=[min(JD-long(JD)),max(JD-long(JD))]
plot,psym=7,JD-long(JD),DS_BS,xtitle='Fractional day',ytitle='DS!d2!n/BS',title=night+' '+filtername(ifilter),ystyle=3,xrange=xrange
plot,psym=7,JD-long(JD),DS2,xtitle='Fractional day',ytitle='DS!d2!n [cts/s]',title=night+' '+filtername(ifilter),ystyle=3,xrange=xrange
plot,psym=7,JD-long(JD),BS,xtitle='Fractional day',ytitle='BS [cts/s]',title=night+' '+filtername(ifilter),ystyle=3,xrange=xrange
plot,jd-long(jd),alfa,ystyle=3,psym=7,xtitle='Fractional day',ytitle='!7a!3',title=night+' '+filtername(ifilter),xrange=xrange
plot,jd-long(jd),offset,ystyle=3,psym=7,xtitle='Fractional day',ytitle='Offset',title=night+' '+filtername(ifilter),xrange=xrange
plot,jd-long(jd),measuredTexp,ystyle=3,psym=7,xtitle='Fractional day',ytitle='Exp time',title=night+' '+filtername(ifilter),yrange=[0,max([measuredTexp,requestedTexp])],xrange=xrange
oplot,jd-long(jd),requestedTexp,psym=2,color=fsc_color('red')
plot,jd-long(jd),am,ystyle=3,psym=7,xtitle='Fractional day',ytitle='Airmass',title=night+' '+filtername(ifilter),yrange=[1,max(am)],xrange=xrange
;
idx=where(jd-long(jd) gt .0)
print,format='(a,a,i3,a,f8.5,a,f5.1,a,f5.1,a)',filtername(ifilter),' & ',nims,' & ',mean(ds_bs(idx)),' & ',stddev(ds_bs(idx))/mean(ds_bs(idx))*100.,' & ',stddev(ds_bs(idx))/sqrt(n_elements(ds_bs(idx)))/mean(ds_bs(idx))*100.,'\\'
for klm=0,n_elements(jd)-1,1 do printf,ww,format='(f20.7,1x,f9.6,1x,a)',jd(klm),DS_BS(klm),filtername(ifilter)
endif
endfor
endfor	; loop over JDs
close,ww
free_lun,ww
end
