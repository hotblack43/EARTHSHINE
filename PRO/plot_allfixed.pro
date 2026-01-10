; Plots output from EFM_v3b.pro
;
file='allfixed.dat'
filtername=['_B_','_V_','_VE1_','_VE2_','_IRCUT_']
!P.CHARSIZE=2
!P.MULTI=[0,2,3]
for ifilter=0,4,1 do begin
spawnstr='grep '+filtername(ifilter)+' '+file+" | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14}' > datablock.dat"
spawn,spawnstr
;print,spawnstr
info=file_info('datablock.dat')
if (info.size ne 0) then begin	
data=get_data('datablock.dat')
jd=reform(data(0,*))
phase=sunearthmoon_angle(jd)
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
tnorm=measuredTexp
tnorm=requestedTexp
;
tot1=tot1/tnorm
tot2=tot2/tnorm
DS1=DS1/tnorm
DS2=DS2/tnorm
BS=BS/tnorm
;
DS_BS=DS1/tot2
;DS_BS=DS1/tot2
;DS_BS=DS1/BS
openw,66,strcompress('fluxes'+filtername(ifilter)+'.dat',/remove_all)
for i=0,n_elements(DS_BS)-1,1 do begin
printf,66,jd(i)-min(JD(i)),DS1(i),tot1(i)
endfor
close,66
endif
endfor
;
end
