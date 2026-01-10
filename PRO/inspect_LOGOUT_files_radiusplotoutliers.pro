PRO getnumbersandnames,name,data,names
openr,89,name
ic=0
while not eof(89) do begin
x=fltarr(7)
str=''
readf,89,x,str
if (ic eq 0) then data=x
if (ic gt 0) then data=[[data],[x]]
if (ic eq 0) then names=str
if (ic gt 0) then names=[names,str]
ic=ic+1
endwhile
close,89
return
end

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
period=27.322
!P.MULTI=[0,4,3]
filters=['B','VE1','V','VE2','IRCUT']
for ifilter=0,4,1 do begin
filter=filters(ifilter)
print,'Filter: ',filter
name=strcompress('logOUT_'+filter+'.dat',/remove_all)
getnumbersandnames,name,data,names
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
A=[140.,8.,p,0.0]
fita=[1,1,1,1]
weights=radius*0+1.0
yfit = CURVEFIT(jd, radius, fita=fita,weights, A, SIGMA, FUNCTION_NAME='gfunct')
residuals=radius-yfit
idx=where(abs(residuals) gt 3)
kdx=where(abs(residuals) le 3)
print,a
print,sigma
plot,yrange=[125,155],ystyle=3,psym=7,title='Raw data'+filter,jd mod p,radius,xtitle='JD',ytitle='Disc radius'
oplot,jd mod p,yfit,psym=4,color=fsc_color('red')
; get rid of outliers
data=data(*,kdx)
names=names(kdx)
openw,55,strcompress('Outliers_'+filter+'.dat',/remove_all)
printf,55,names(idx)
close,55
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
yfit = CURVEFIT(jd, radius, fita=fita,weights, A, SIGMA, FUNCTION_NAME='gfunct')
residuals=radius-yfit
idx=where(abs(residuals) gt 5)
kdx=where(abs(residuals) le 5)
print,a,format='(4(1x,f10.5),1x,a)',' outliers removed'
print,sigma,format='(4(1x,f10.5),1x,a)',' outliers removed'
plot,yrange=!y.crange,title='Outliers removed'+filter,ystyle=3,psym=7,jd mod p,radius,xtitle='JD',ytitle='Disc radius'
oplot,jd mod p,yfit,psym=4,color=fsc_color('red')
endfor
end
