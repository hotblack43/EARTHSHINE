PRO gfunct, X, pars, F, pder
  a = pars(0)
  b = pars(1)
  p = pars[2]
  c = pars(3)
;print,a,b,p,c
  F = a  + b* sin(2.*!pi*x/p+c)
 

; calculate the partial derivatives.

pder = [[replicate(1.0, N_ELEMENTS(X))],[sin(2.*!pi*x/p+c)],[-2.*b*!pi*x*cos(2.*!pi*x/p)/p^2],[b*cos(2.*!pi*x/p+c)]]
END

;--------------------------------------
file='good_linear_scattered_light_remover_v9.log'
period=27.1
!P.MULTI=[0,2,3]
filters=['B','VE1','V','VE2','IRCUT']
for ifilter=0,4,1 do begin
filter=filters(ifilter)
print,'Filter: ',filter
spawn,'grep 
name=strcompress('logOUT_'+filter+'.dat',/remove_all)
data=get_data(name)
jd=reform(data(0,*))
jd=jd-min(jd)
az=reform(data(1,*))
ph=reform(data(2,*))
am=reform(data(3,*))
counts=2.5*alog10(reform(data(4,*)))
exptime=reform(data(5,*))
totflux=counts/(exptime+2.5e-4)
magnitudes=13.-2.5*alog10(totflux)
radius=reform(data(6,*))
; jd,az,moonphase,airmass,totflux,radius
print,'Period:',period
p=period
A=[140.,20.,p,0.0]
fita=[1.,1.,1.,1.]
weights=radius*0+1.0
yfit = CURVEFIT(jd, radius, fita=fita,weights, A, SIGMA, FUNCTION_NAME='gfunct')
print,a
print,sigma
plot,ystyle=3,psym=7,jd mod p,radius,xtitle='JD',ytitle='Disc radius'
oplot,jd mod p,yfit,psym=4,color=fsc_color('red')
endfor
end
