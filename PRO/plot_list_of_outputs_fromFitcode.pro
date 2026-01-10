PRO get_sunmoonphase,jd,phase
; returns the phase between Sun and Moon as seen from Earth
phase=1
MOONPOS, jd, ra_moon, dec_moon, dis
obsname='MLO'
eq2hor, ra_moon, dec_moon, jd, alt_moon, az_moon, ha_moon,  OBSNAME=obsname
; Where is the Sun in the local sky?
        SUNPOS, jd, ra_sun, dec_sun
        eq2hor, ra_sun, dec_sun, jd, alt_sun, az, ha,  OBSNAME=obsname
; what is the angular distance between Moon and SUn?
u=0     ; radians
gcirc,u,ra_moon*!dtor, dec_moon*!dtor,ra_sun*!dtor, dec_sun*!dtor,dis
phase=abs(dis/!pi*180.)
if (ra_sun gt ra_moon) then phase=-phase
return
end

file='list_of_outputs_fromFitcode.txt'
str="awk '{print $1,$2,$3,$4,$5,$6,$7,$8}' "+file+" > aha.dat"
spawn,str
data=get_data('aha.dat')
JD=reform(data(0,*))
albedo=reform(data(1,*))
delta_albedo=reform(data(2,*))
rmse=reform(data(6,*))
phase=fltarr(n_elements(jd))
for i=0,n_elements(jd)-1,1 do begin
jdin=jd(i)
get_sunmoonphase,jdin,phout
phase(i)=phout
endfor

kdx=where((JD lt 2456025 or JD gt  2456038) and abs(phase) gt 30 and rmse lt 0.5 and abs(delta_albedo/albedo) lt 0.04)
data=data(*,kdx)

JD=reform(data(0,*))
albedo=reform(data(1,*))
delta_albedo=reform(data(2,*))
alfa=reform(data(3,*))
pedestal=reform(data(4,*))
xshift=reform(data(5,*))
rmse=reform(data(6,*))
tot=reform(data(7,*))

phase=fltarr(n_elements(jd))
for i=0,n_elements(jd)-1,1 do begin
jdin=jd(i)
get_sunmoonphase,jdin,phout
phase(i)=phout
endfor
!P.CHARSIZE=1.8
!P.THICK=2
!x.THICK=2
!y.THICK=2
!P.MULTI=[0,3,2]
xx=[transpose(albedo),transpose(delta_albedo),transpose(alfa),transpose(pedestal),transpose(xshift),transpose(rmse),transpose(phase)]
name=['Albedo','Alb err','!7a!3','Ped.','!7D!3','RMSE','Phase']
for i=0,6,1 do begin
for j=0,6,1 do begin
ok=0
if ((i eq 0 and j eq 1) or (i eq 0 and j eq 2) or (i eq 0 and j eq 3) or (i eq 6 and j eq 0) or (i eq 2 and j eq 3) or (i eq 2 and j eq 6)) then ok=1
if (ok eq 1) then begin
if (i ne j) then plot,xx(i,*),xx(j,*),xstyle=3,ystyle=3,xtitle=name(i),ytitle=name(j),psym=7
if (i eq 0) then oplot,[0.31,0.31],[!Y.crange],linestyle=1
if (j eq 0) then oplot,[!X.crange],[0.31,0.31],linestyle=1
if (i eq 2) then oplot,[1.71,1.71],[!Y.crange],linestyle=1
if (j eq 2) then oplot,[!X.crange],[1.71,1.71],linestyle=1
if (i eq 4) then oplot,[0.,0.],[!Y.crange],linestyle=1
if (j eq 4) then oplot,[!X.crange],[0.,0.],linestyle=1
if (i eq 0 and j eq 2) then begin
xxx=xx(i,*)
yyy=xx(j,*)
res=robust_linefit(xxx,yyy)
yhat=res(0)+res(1)*xxx
oplot,xxx,yhat,color=fsc_color('red')
print,'Slope of albedo vs. alfa line: ',res(1)
endif
if (i eq 2 and j eq 3) then begin
rdx=where(abs(alfa-1.71) lt .002)
xxx=xx(i,rdx)
yyy=xx(j,rdx)
res=robust_linefit(xxx,yyy)
xxxx=(findgen(21)/20.-0.5)/0.5*0.002+1.71
yhat=res(0)+res(1)*xxxx
oplot,xxxx,yhat,color=fsc_color('red')
print,'Slope of alfa vs. ped line: ',res(1)
endif
endif
endfor
endfor
delta=.01/4.
print,'delta on alfa: ',delta
kdx=where(abs(alfa-1.71) gt delta)
oplot,xx(5,kdx),xx(6,kdx),color=fsc_color('red'),psym=4
;
medalb=median(albedo)
sdalb=stddev(albedo)
sdMalb=sdalb/sqrt(n_elements(albedo)-1)
print,'Med. albedo: ',medalb,' S.D.m. ',sdMalb, ' or ',sdMalb/medalb*100.0,' % of the mean.'
xyouts,/normal,0.14,0.85,'a',charthick=3,charsize=3,color=fsc_color('red')
xyouts,/normal,0.47,0.85,'b',charthick=3,charsize=3,color=fsc_color('red')
xyouts,/normal,0.80,0.85,'c',charthick=3,charsize=3,color=fsc_color('red')
xyouts,/normal,0.14,0.35,'d',charthick=3,charsize=3,color=fsc_color('red')
xyouts,/normal,0.47,0.35,'e',charthick=3,charsize=3,color=fsc_color('red')
xyouts,/normal,0.80,0.35,'f',charthick=3,charsize=3,color=fsc_color('red')
end
