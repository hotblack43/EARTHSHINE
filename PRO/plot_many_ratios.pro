PRO printstat,jd,ratio,filter
n=n_elements(jd)
jds=long(jd)
jds=jds(uniq(jds))
print,'Filter= ',filter
printf,55,filter
for i=0,n_elements(jds)-1,1 do begin
idx=where(long(jd) eq jds(i))
print,jds(i),mean(ratio(idx)),stddev(ratio(idx))/sqrt(n_elements(idx)-1.)/mean(ratio(idx))*100,' %'
printf,55,format='(i8,a,f5.2,a)',jds(i),' & ',stddev(ratio(idx))/sqrt(n_elements(idx)-1.)/mean(ratio(idx))*100,' & '
endfor
return
end

!P.THICK=2
!x.THICK=2
!y.THICK=2
obsname='mlo'
!P.MULTI=[0,2,3]
openw,55,'table.tex'
for ic=0,4,1 do begin
if (ic eq 0) then filter='_B_'
if (ic eq 1) then filter='_V_'
if (ic eq 2) then filter='_VE1_'
if (ic eq 3) then filter='_VE2_'
if (ic eq 4) then filter='_IRCUT_'
spawn,'grep '+filter+" many_ratios.dat | awk '{print $1,$2}' > block.dat"
data=get_data('block.dat')
idx=sort(data(0,*))
data=data(idx,*)
jd=reform(data(0,*))
Mphase=fltarr(N_elements(jd))
Ephase=fltarr(N_elements(jd))
for kl=0,N_elements(jd)-1,1 do begin
moonphase_pth2,jd(kl),phase_angle_M,phase_angle_E,alt_moon,alt_sun,obsname
Mphase(kl)=phase_angle_M
Ephase(kl)=-phase_angle_E
print,jd(kl),180.-Mphase(kl)
endfor
ratio=reform(data(1,*))
!P.CHARSIZE=1.4
plot_io,xrange=[2456000L,2456008L],xstyle=3,jd,ratio,psym=7,xtitle='JD',ytitle='DS/BS',yrange=[0.0001,1.0],ystyle=3
printstat,jd,ratio,strmid(filter,1,strlen(filter)-2)
xyouts,/data,2456001.0,0.1,strmid(filter,1,strlen(filter)-2)
formula=schoenbergphaselaw(Ephase*!dtor)/schoenbergphaselaw(Mphase*!dtor)
formula2=lommelseeliger(Ephase*!dtor)/lommelseeliger(Mphase*!dtor)
factor=median(ratio/formula)
factor2=median(ratio/formula2)
oplot,jd,formula*factor,color=fsc_color('blue')
oplot,jd,formula2*factor2,color=fsc_color('red')
endfor
close,55
end
