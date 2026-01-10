FUNCTION Tamplitude,qampl,cp,omega,kappa,lamda,l
; Equation 9 from Shaviv paper 2008 in JGR on calorimetry
ko2=omega*kappa/2.
formula=qampl/cp/sqrt((sqrt(ko2)+lamda/cp)^2+(omega*l+sqrt(ko2))^2)
return,formula
end

;-------------------------------------
qampl=0.07/100.*1370	; TSI amplitude (sort of)
cp=4.19e+6 	; J/m^3/K - NB: specific heat PER UNIT VOLUME, not mass
kappa=1e-4	; m^2/sec
lamda0=3.8	; W/m^2/K
;::::::::::::::::
overplot=1
period_in_years=1.
period_2_in_years=11.
period_in_years=11.
period_2_in_years=44.
;
period_in_seconds=period_in_years*365.25*24.*3600.
period_2_in_seconds=period_2_in_years*365.25*24.*3600.
omega=2.*!pi/period_in_seconds
omega_2=2.*!pi/period_2_in_seconds
;::::::::::::::::
if (overplot eq 1) then jcount=0
kappavalues=[2e-5,1e-4,3e-4]
colornames=['black','red','blue']
for ik=0,n_elements(kappavalues)-1,1 do begin
kappa=kappavalues(ik)
if (overplot ne 1) then jcount=0
lamdavalues=[0.1,1,2,4,8]
for ip=0,n_elements(lamdavalues)-1,1 do begin
lamda=lamdavalues(ip)
print,'lamda: ',lamda
l0=1.
ln=15000L
lstep=1.
count=0
for l=l0,ln,lstep  do begin	; depth of slap in meters
if (count eq 0) then begin
	x=l
	y=Tamplitude(qampl,cp,omega,kappa,lamda,l)/(qampl/cp)
	y2=Tamplitude(qampl,cp,omega_2,kappa,lamda,l)/(qampl/cp)
endif
if (count gt 0) then begin
	x=[x,l]
	y=[y,Tamplitude(qampl,cp,omega,kappa,lamda,l)/(qampl/cp)]
	y2=[y2,Tamplitude(qampl,cp,omega_2,kappa,lamda,l)/(qampl/cp)]
endif
count=count+1
endfor
!P.thick=2
!P.charsize=2
!P.charthick=2
!X.thick=2
!Y.thick=2
if (overplot ne 1) then !P.MULTI=[0,1,2]
if (overplot eq 1) then !P.MULTI=[0,1,1]
tstr=strcompress('Periodic '+strmid(string(period_in_years),0,8)+' yr forcing (solid) and '+strmid(string(period_2_in_years),0,8)+' yr')
a2=sqrt(cp*cp*kappa*omega_2+cp*sqrt(2.*kappa*omega_2)*lamda+lamda*lamda)
a1=sqrt(cp*cp*kappa*omega  +cp*sqrt(2.*kappa*omega  )*lamda+lamda*lamda)
level2=a2/a1
if (jcount eq 0) then  begin
	if (overplot ne 1) then begin
		plot,/xlog,/ylog,title=tstr,xtitle='Depth (m)',ytitle='T!damplitude!n/(q/Cp)',x,y,xstyle=1,yrange=[3e3,2e6],ystyle=1
		xyouts,/normal,0.3,0.2, $
		strcompress('Diffusivity: '+string(kappa))
		oplot,x,y2,linestyle=2
	endif
	plot,/xlog,/ylog,xtitle='Depth (m)',ytitle='Response ratio',x,y/y2,xstyle=1,color=FSC_color(colornames(ik))
	level1=omega_2/omega
	;plots,[100,20000],[level1,level1],linestyle=3
	;plots,[1,1000],[level2,level2],linestyle=3
endif
if (jcount gt 0) then  begin
	oplot,x,y/y2,color=FSC_color(colornames(ik))
endif
jcount=jcount+1
endfor	; end of lamda loop
endfor	; end of kappa loop
end



