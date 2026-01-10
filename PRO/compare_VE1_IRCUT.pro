FUNCTION mhm,x_in,value
x=x_in
x=x(sort(x))
n=n_elements(x)
x=x(n*0.25:n*0.75)
value=mean(x,/double)
return,value
end

methodnames=['RAW','EFM','BBSOlin','BBSOlog']
for imethod=0,3,1 do begin
!P.MULTI=[0,1,2]
!P.COLOR=fsc_color('black')
str=methodnames(imethod)
data1=get_data('p__VE1_'+str+'.dat')
data2=get_data('p__IRCUT_'+str+'.dat')
jd1=reform(data1(0,*))
ph1=reform(data1(1,*))
albedo1=reform(data1(2,*))
jd2=reform(data2(0,*))
ph2=reform(data2(1,*))
albedo2=reform(data2(2,*))
; find overlapping times
start=max([min(jd1),min(jd2)])
stop=min([max(jd1),max(jd2)])
print,'Overlapping data from ',start,' to ',stop
; set time interval
delta=1./24.	; one hour
openw,14,strcompress('comparative_ve1_ircut'+str+'.dat',/remove_all)
for jd=start,stop-delta,delta do begin
idx=where(jd1 gt jd and jd1 le jd+delta)
jdx=where(jd2 gt jd and jd2 le jd+delta)
if (n_elements(idx) gt 1 and n_elements(jdx) gt 1) then begin
print,jd+delta/2.,mean(ph1(idx)),n_elements(idx),n_elements(jdx),mean(albedo1(idx)),stddev(albedo1(idx))/sqrt(n_elements(idx)-1),mean(albedo2(jdx)),stddev(albedo2(jdx))/sqrt(n_elements(jdx)-1),mean(ph1(idx))
printf,14,mean(albedo1(idx)),stddev(albedo1(idx))/sqrt(n_elements(idx)-1),mean(albedo2(jdx)),stddev(albedo2(jdx))/sqrt(n_elements(jdx)-1),mean(ph1(idx))
endif
endfor
close,14
data=get_data(strcompress('comparative_ve1_ircut'+str+'.dat',/remove_all))
albve1=reform(data(0,*))
err_albve1=reform(data(1,*))
albIRCUT=reform(data(2,*))
err_albIRCUT=reform(data(3,*))
ph=reform(data(4,*))
print,'Avrg robust error on VE1: ',mhm(err_albve1)
print,'Avrg robust error on IRCUT: ',mhm(err_albIRCUT)
print,'VE1 - roberr as % of albedo: ',mhm(err_albve1/albve1)*100.
print,'IRCUT - roberr as % of albedo: ',mhm(err_albIRCUT/albIRCUT)*100.
!P.CHARSIZE=2
!P.THICK=2
!x.THICK=2
!y.THICK=2
plot,title=str,xstyle=3,ystyle=3,/isotropic,albve1,albIRCUT,psym=3,xtitle='A*!dVE1!n',ytitle='A*!dIRCUT!n'
; plot error bars
for k=0,n_elements(albve1)-1,1 do begin
oplot,[albve1(k),albve1(k)],[albIRCUT(k)-err_albIRCUT(k),albIRCUT(k)+err_albIRCUT(k)]
oplot,[albve1(k)-err_albve1(k),albve1(k)+err_albve1(k)],[albIRCUT(k),albIRCUT(k)]
endfor
z0=max([!X.crange(0),!y.crange(0)])
z1=min([!X.crange(1),!y.crange(1)])
plots,[z0,z1],[z0,z1]
; plot against pahse
kdx=where(abs(err_albve1/albve1) lt 0.15)
!X.title='Lunar phase'
!y.title='A* - VE1 and IRCUT'
;!P.COLOR=fsc_color('white')
!P.COLOR=fsc_color('black')
;!P.MULTI=[0,1,2]
plot,ph(kdx),albve1(kdx),/nodata,yrange=[0.21,0.5]
!P.COLOR=fsc_color('red')
oploterr,ph(kdx),albve1(kdx),err_albve1(kdx)
!P.COLOR=fsc_color('blue')
oploterr,ph(kdx),albIRCUT(kdx),err_albIRCUT(kdx)
endfor
end
