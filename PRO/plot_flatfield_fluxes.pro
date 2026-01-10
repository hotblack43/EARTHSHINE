PRO gofindslope,jd,flx,fo,tConst,yhat
; will fit fo*exp(-t/tConst) against data
lnflx=alog10(flx)
res=linfit(jd-long(jd(0)),lnflx,/double,yfit=yhat,sigma=sigs)
fo=exp(res(0))
print,'slope: ',res(1),' +/- ',sigs(1)
tConst=-1./res(1)
yhat=10^(yhat)
return
end


names=['B','V','VE1','VE2','IRCUT']
for i=0,4,1 do begin
data=get_data(strcompress(names(i)+'.dat',/remove_all))
jd=reform(data(0,*))
jd=jd-2455825.67292d0 & jd=jd*24.*60.
flx=reform(data(1,*))
!P.charsize=2
!P.thick=2
!x.thick=2
!y.thick=2
gofindslope,jd,flx,fo,tConst,yhat
print,format='(a6,1x,1(a,f9.4,a))',names(i),' 1/2 time: ',tConst*alog10(2.)
if (i eq 0) then plot_io,ystyle=3,title='Flat field fluxes',xstyle=3,xrange=[0,60],yrange=[10,20000],jd,flx,xtitle='Minutes to/since Sunset',ytitle='cts/s'
if (i gt 0) then oplot,jd,flx,linestyle=i
oplot,jd,yhat,color=fsc_color('red')
endfor
end

