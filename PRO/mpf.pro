PRO plot_all,hjd,ku,kuerr,kb1,kb1err,kb,kberr,kb2,kb2err,kv1,kv1err,kv,kverr,kg,kgerr,tstreng
jd=hjd+2400000.0d0
caldat,jd,mm,dd,yy,hr,min,sec
fracyear=yy+(mm-1)/12.0d0+dd/365.25
!P.multi=[0,1,7]
plot,fracyear,ku,xtitle='year',ytitle='k!dU!n',charsize=1.8,xstyle=1,ystyle=1,title=tstreng,psym=3
plot,fracyear,kb1,xtitle='Year',ytitle='k!dB1!n',charsize=1.8,xstyle=1,ystyle=1,psym=3
plot,fracyear,kb,xtitle='Year',ytitle='k!dB!n',charsize=1.8,xstyle=1,ystyle=1,psym=3
plot,fracyear,kb2,xtitle='Year',ytitle='k!dB2!n',charsize=1.8,xstyle=1,ystyle=1,psym=3
plot,fracyear,kv1,xtitle='Year',ytitle='k!dV1!n',charsize=1.8,xstyle=1,ystyle=1,psym=3
plot,fracyear,kv,xtitle='Year',ytitle='k!dV!n',charsize=1.8,xstyle=1,ystyle=1,psym=3
plot,fracyear,kg,xtitle='Year',ytitle='k!dG!n',charsize=1.8,xstyle=1,ystyle=1,psym=3
return
end


FUNCTION extinction, X, A
common wave,wave,o3_corr
idx=where(wave eq x)
   extinct = a(0)*x^a(1)+a(2)*x^a(3)+a(4)*o3_corr(idx(0))
   RETURN,extinct
END

PRO extract_data,data,date,hjd,ku,kuerr,kb1,kb1err,kb,kberr,kb2,kb2err,kv1,kv1err,kv,kverr,kg,kgerr
date=reform(data(0,*))
hjd=reform(data(1,*))
ku=reform(data(2,*))
kuerr=reform(data(3,*))
kb1=reform(data(4,*))
kb1err=reform(data(5,*))
kb=reform(data(6,*))
kberr=reform(data(7,*))
kb2=reform(data(8,*))
kb2err=reform(data(9,*))
kv1=reform(data(10,*))
kv1err=reform(data(11,*))
kv=reform(data(12,*))
kverr=reform(data(13,*))
kg=reform(data(14,*))
kgerr=reform(data(15,*))
return
end

;=============Programme=================================
common wave,wave,o3_corr
o3_corr=[.016d0,0.0d0,0.0d0,0.01d0,.025d0,.030d0,.039d0]	; abs per airamss at the filters bands due to O3
file='/data/pth/G3526/NBI/ALL/LASILLA/lasilla_77_92.dat'
file='lasilla_77_92.dat'
data=get_data(file)
extract_data,data,date,hjd,ku,kuerr,kb1,kb1err,kb,kberr,kb2,kb2err,kv1,kv1err,kv,kverr,kg,kgerr
plot_all,hjd,ku,kuerr,kb1,kb1err,kb,kberr,kb2,kb2err,kv1,kv1err,kv,kverr,kg,kgerr,'Before selection'
!P.multi=[0,1,2]
histo,kv,0,1,0.01,xtitle='k!dV!n',title='Before selection'
; filter the data
;idx=where(hjd gt 44322. and hjd lt 45052.)	; before Chicon
idx=where(hjd gt 45052. and hjd lt 45052.+2.*365.)	; after Chicon
;idx=where(kverr/kV lt 20./10.)	; median value of kV
print,'Found ',n_elements(idx),' good data points.'
data=data(*,idx)
extract_data,data,date,hjd,ku,kuerr,kb1,kb1err,kb,kberr,kb2,kb2err,kv1,kv1err,kv,kverr,kg,kgerr
plot_all,hjd,ku,kuerr,kb1,kb1err,kb,kberr,kb2,kb2err,kv1,kv1err,kv,kverr,kg,kgerr,'After selection'
!P.multi=[0,1,2]
histo,kv,0,1,0.01,xtitle='k!dV!n',title='After selection'
n=n_elements(kg)
; start fitting
wave=[3464.,4015.,4227.,4476.,5395.,5488.,5807.]
wave=wave/10000.0d0
fita=[1,1,1,1,1]
a=fita*0.0
icount=0
!P.MULTI=[0,2,3]
maxiter=1000
zlimit=2.0
zmax=zlimit
for i=0,n-1,1 do begin
	x=wave
	y=[ku(i),kb1(i),kb(i),kb2(i),kv1(i),kv(i),kg(i)]
	erry=[kuerr(i),kb1err(i),kberr(i),kb2err(i),kv1err(i),kverr(i),kgerr(i)]/1000.0d0
	kdx=where(erry eq 0)
	if (kdx(0) ne -1) then erry(kdx)=0.001
;
;....
	parinfo=replicate({value:0.D,fixed:0,limited:[0,0],limits:[0.D,0]},5)
; setting limits on bRC
	parinfo(0).limited[0]=0
	parinfo(0).limits[0]=0.0d0
; setting limits on Rayleigh power
 	parinfo(1).limited[0]=0
 	parinfo(1).limited[1]=0
 	parinfo(1).limits[0]=-9d0
 	parinfo(1).limits[1]=9d0
	parinfo(1).fixed=1
; setting limits on bp
	parinfo(2).limited[0]=0
	parinfo(2).limits[0]=0.0d0
; setting limits on aerosol power
	parinfo(3).limited[0]=1
	parinfo(3).limited[1]=1
	parinfo(3).limits[0]=-10.0d0
	parinfo(3).limits[1]=10.
	parinfo(3).fixed=0
; setting limits on O3 factor
	parinfo(4).limited[0]=1
	parinfo(4).limits[0]=0.0d0
	parinfo(4).fixed=0
; set start values
	a(0)=0.008
	a(1)=-4.05
	a(2)=1.0
	a(3)=-1.39
	a(4)=0.0
	parinfo(*).value=[a(0),a(1),a(2),a(3),a(4)]
; fit
	parms = MPFITFUN('extinction', X, Y, erry, a,yfit=yfit, $
		PARINFO=parinfo, $
		PERROR=sigs,/quiet,maxiter=maxiter,niter=niter)
	print,'number of iterations;',niter,' of ',maxiter
	a=parms
	residuals=y-yfit
	RMSE=sqrt(total(residuals^2)/n_elements(y))
	zeds=abs(residuals/erry)
;	if (abs(sigs(1)) lt abs(a(1)) and abs(sigs(3)) lt abs(a(3)) $
;	if (mean(zeds) le zlimit $
	if (max(zeds) le zmax $
	and a(0) ne parinfo(0).limits[0]$
	and a(1) ne parinfo(1).limits[0]$
	and a(1) ne parinfo(1).limits[1]$
	and a(2) ne parinfo(2).limits[0]$
	and a(3) ne parinfo(3).limits[0]$
	and a(3) ne parinfo(3).limits[1]$
	and a(4) ne parinfo(4).limits[0] $
	and niter ne maxiter) then begin
		plot,x,y,xtitle='Wavelength',ytitle='Extinction (mags)',psym=3,title=hjd(i)
		oploterr,x,y,erry
		oplot,x,yfit
		plot,x,y-yfit,psym=7,ytitle='Residuals',title=hjd(i)
		oploterr,x,y-yfit,erry
		plots,[!x.crange],[0,0],linestyle=4
		for k=0,n_elements(a)-1,1 do print,format='(5(1x,f10.4,1x,a3,1x,f8.3))',a(k),'+/-',sigs(k)
		print,'RMSE:',RMSE,' niter:',niter,' of max ',maxiter
		if (icount eq 0) then begin
			bRC=a(0)
			alfa_RC= a(1)
			bp=a(2)
			alfa_p= a(3)
			bO3= a(4)
			fits=[a]
	help,fits
		endif
		if (icount gt 0) then begin
			bRC=[bRC,a(0)]
			alfa_RC=[alfa_RC,a(1)]
			bp=[bp,a(2)]
			alfa_p=[alfa_p,a(3)]
			bO3=[bO3,a(4)]
			fits=[[fits],[a]]
	help,fits
		endif

		icount=icount+1
	endif
endfor
; Now select thos esolutions that did not "go to the rail"
; call something here ...
!P.MULTI=[0,1,5]
minval=min([alfa_rc,alfa_p])
maxval=max([alfa_rc,alfa_p])
!P.charsize=2
histo,bRC,min(bRC),max(bRC),0.0001,title='Rayleigh scattering coefficient'
histo,alfa_RC,minval,maxval,0.5,title='Rayleigh scattering power'
histo,bp,min(bp),max(bp),0.1,title='Aerosol scattering coefficient'
histo,alfa_p,minval,maxval,0.5,title='Aerosol law power'
histo,bO3,min(bO3),max(bO3),.125,title='O!d3!n factor'
end


