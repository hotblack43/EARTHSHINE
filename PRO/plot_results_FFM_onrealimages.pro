; Plots output from EFM_v3b.pro
night='2455864'
night='2455924'
night='2455923'
night='2455917'
night='2455858'
file=strcompress('results_FFM_onrealimages.dat',/remove_all)
filtername=['_B_','_V_','_VE1_','_VE2_','_IRCUT_']
!P.CHARSIZE=1
!P.MULTI=[0,8,5]
for ifilter=0,4,1 do begin
spawnstr='grep '+filtername(ifilter)+' '+file+" | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12}' > datablock.dat"
spawn,spawnstr
info=file_info('datablock.dat')
if (info.size ne 0) then begin	
data=get_data('datablock.dat')
;jd,alfa,a,albedo,BS,total(observed-a),DS,x0,y0,radius,cg_x,cg_y,filtername
jd=reform(data(0,*))
mlo_airmass,jd,am
nims=n_elements(jd)
alfa=reform(data(1,*))
offset=reform(data(2,*))
albedo=reform(data(3,*))
BS=reform(data(4,*))
tot=reform(data(5,*))/512.d0/512.d0
DS=reform(data(6,*))
x0=reform(data(7,*))
y0=reform(data(8,*))
radius=reform(data(9,*))
cgx=reform(data(10,*))
cgy=reform(data(11,*))
;
DS_BS=DS/tot
DS_BS=DS/BS
openw,66,strcompress('fluxes_FFM_'+filtername(ifilter)+'.dat',/remove_all)
for i=0,n_elements(DS_BS)-1,1 do begin
printf,66,jd(i)-long(JD(i)),DS(i),tot(i)
endfor
close,66
;
xrange=[min(JD-long(JD)),max(JD-long(JD))]
plot,psym=7,JD-long(JD),albedo,xtitle='Fractional day',ytitle='Albedo',title=night+' '+filtername(ifilter),ystyle=3,xrange=xrange
plot,psym=7,JD-long(JD),DS_BS,xtitle='Fractional day',ytitle='DS/BS',title=night+' '+filtername(ifilter),ystyle=3,xrange=xrange
plot,psym=7,JD-long(JD),BS,xtitle='Fractional day',ytitle='BS [cts]',title=night+' '+filtername(ifilter),ystyle=3,xrange=xrange
plot,psym=7,JD-long(JD),DS,xtitle='Fractional day',ytitle='DS [cts]',title=night+' '+filtername(ifilter),ystyle=3,xrange=xrange
plot,psym=7,JD-long(JD),tot,xtitle='Fractional day',ytitle='Total [cts]',title=night+' '+filtername(ifilter),ystyle=3,xrange=xrange
plot,jd-long(jd),alfa,ystyle=3,psym=7,xtitle='Fractional day',ytitle='!7a!3',title=night+' '+filtername(ifilter),xrange=xrange
plot,jd-long(jd),offset,ystyle=3,psym=7,xtitle='Fractional day',ytitle='Offset',title=night+' '+filtername(ifilter),xrange=xrange
plot,jd-long(jd),am,ystyle=3,psym=7,xtitle='Fractional day',ytitle='Airmass',title=night+' '+filtername(ifilter),yrange=[1,max(am)],xrange=xrange
;
idx=where(jd-long(jd) gt .0)
print,format='(a,a,i3,a,f8.5,a,f4.1,a,f4.1,a)',filtername(ifilter),' & ',nims,' & ',mean(ds_bs(idx)),' & ',stddev(ds_bs(idx))/mean(ds_bs(idx))*100.,' & ',stddev(ds_bs(idx))/sqrt(n_elements(ds_bs(idx)))/mean(ds_bs(idx))*100.,'\\'
;
print,'R(albedo,alfa): ',correlate(albedo,alfa)
print,'R(albedo,offset): ',correlate(albedo,offset)
print,'R(albedo,DS): ',correlate(albedo,DS)
print,'R(albedo,BS): ',correlate(albedo,BS)
print,'R(albedo,tot): ',correlate(albedo,tot)
print,'R(albedo,am): ',correlate(albedo,am)
print,'R(albedo,DS_BS): ',correlate(albedo,DS_BS)
print,'R(alfa,offset): ',correlate(alfa,offset)
print,'R(albedo,x0): ',correlate(albedo,x0)
endif
endfor
end
