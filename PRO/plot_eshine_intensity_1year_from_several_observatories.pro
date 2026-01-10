PRO getjustheobservablemoments,jd,eshine,jduse,eshineuse,obsname
ic=0
for i=0,n_elements(jd)-1,1 do begin
xJD=jd(i)
MOONPOS, xJD, ramoon, decmoon
eq2hor, ramoon, decmoon, xJD, altmoon, azmoon,  OBSNAME=obsname
SUNPOS, xJD, rasun, decsun
eq2hor, rasun, decsun, xJD, altsun, azsun,  OBSNAME=obsname
if (altmoon gt 0 and altsun lt 0) then begin
; Moon is observable
if (ic eq 0) then begin
	jduse=xJD
	eshineuse=eshine(i)
endif else begin
	jduse=[jduse,xJD]
	eshineuse=[eshineuse,eshine(i)]
endelse
ic=ic+1
endif
endfor
return
end

OBSNAMES=['mlo','mso','lapalma','lco','saao']
colname=['red','blue','orange','yellow','green']
for iobs=0,n_elements(obsnames)-1,1 do begin
data=get_data('earthshine_intensity_1year.dat')
kdx=indgen(3000)+400
jd=reform(data(0,kdx))
Sshine=reform(data(1,kdx))
eshine=reform(data(2,kdx))
ph_M=reform(data(3,kdx))
ph_E=reform(data(4,kdx))
!P.CHARSIZE=1.6
!P.thick=2
!x.thick=2
!y.thick=2
!P.MULTI=[0,1,1]
getjustheobservablemoments,jd,eshine,jduse,eshineuse,obsnames(iobs)
if (iobs eq 0) then plot,xstyle=3,jd-min(jd),eshine,xtitle='days',ytitle='earthshine intensity [W/m!u2!n]'
offset=0.000
oplot,jduse-min(jd),eshineuse+iobs*offset,color=fsc_color(colname(iobs)),psym=7
xyouts,10,0.08-iobs*0.01,obsnames(iobs)+' : '+colname(iobs)
delta=jduse-shift(jduse,1)
delta=delta(1:n_elements(delta)-1)
idx=where(delta gt 0.34)
print,format='(a,a,1x,f5.2,a)','Unobserved at ',obsnames(iobs),total(delta(idx))/(max(jd)-min(jd))*100.,' % of the time'
endfor
end
