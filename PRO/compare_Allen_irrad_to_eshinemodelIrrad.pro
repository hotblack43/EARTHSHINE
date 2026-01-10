 PRO getheJD,header,JD
 idx=where(strpos(header, 'JULIAN') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 JD=double(strmid(str,13,18))
 return
 end

 PRO gethephase,header,monphase
 idx=where(strpos(header, 'MPHASE') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 monphase=float(strmid(str,13,13))
 return
 end

numsym=1
ifcalcmodels=0
if (ifcalcmodels eq 1) then begin
;Get total flux froma ll available ideal images
openw,33,'model_phases.dat'
files=file_search('OUTPUT/IDEAL/ideal_LunarImg_SCA_0p3*',count=n)
for i=0,n-1,1 do begin
im=readfits(files(i),h,/sil)
gethephase,h,phase
getheJD,h,JD
printf,format='(f8.3,1x,f20.10,1x,f15.7)',33,phase,total(im,/double),JD
endfor
close,33
endif
data=get_data('model_phases.dat')
plot_io,data(0,*),data(1,*),xrange=[0,160],xstyle=3,psym=numsym,/nodata,ytitle='Flux [W/m^2]',xtitle='Phase angle [0 = FM]',yrange=[1e-5,1e-2]
oplot,data(0,*),data(1,*),psym=numsym,color=fsc_color('red')
; Calculates the lunar flux at Earth using formulae in Allen Astrophysical Quantities.
;
V10=+0.23	
rdelta=0.0026
openw,44,'lunar_irradiance_Allen.dat'
for phase_angle=-180,180,2 do begin
phase=abs(phase_angle)
phaselaw=0.026*phase+4.0e-9*phase^4
V=5.0*alog10(rdelta)+V10+phaselaw
printf,44,phase_angle,10^(-V/2.5)
endfor
close,44
data2=get_data('lunar_irradiance_Allen.dat')
ph=reform(data2(0,*))
fl=reform(data2(1,*))
oplot,ph,fl*3.7e-8,psym=numsym
oplot,data(0,*),data(1,*),psym=numsym,color=fsc_color('red')
; and overplot the Kieffer & STone irradiance (formula 10)
ks=get_data('TOMSTONE/ROLOIRRADMODEL/544_irradiance.dat')
ph=reform(ks(0,*))
ksirr=reform(ks(1,*))
oplot,ph,ksirr*4.3e-2,psym=numsym,color=fsc_color('green')
oplot,data(0,*),data(1,*),psym=numsym,color=fsc_color('red')
;
xyouts,/normal,0.4,0.85,'Black + : Allen formula'
xyouts,/normal,0.4,0.82,'Red +: Hapke 196x models'
xyouts,/normal,0.4,0.79,'Green +: Kieffer & Stone'
xyouts,/normal,0.4,0.76,'Black x: Empirical, linear fit our data'
;
; plot ourown empirical phase law
ph=findgen(37*2)*5.-180
idx=where(abs(ph) gt 70 and abs(ph) lt 150)
ph=ph(idx)
Vobs=ph*0.0
idx=where(ph le 0)
Vobs(idx)=-0.052276320*ph(idx)
idx=where(ph gt 0)
Vobs(idx)=0.052276320*ph(idx)
Vflux_obs=8e7*10^((Vobs+23)/(-2.5))
oplot,ph,Vflux_obs,psym=7
end
