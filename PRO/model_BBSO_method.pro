; model the BBSO linear sky method
!P.multi=[0,1,2]
N=1000
x0=N/2.-0.023
y0=N/2.-0.0012
noisy=fltarr(n,n)
factor=1.
nfields=32.
for ifield=0,nfields-1,1 do begin
 x=indgen(N) # replicate(1,N)
 y=replicate(1,N) # indgen(N)
 radius_surface=sqrt((x-x0)^2+(y-y0)^2)
 scattered=(40 - radius_surface/20.)*(40-radius_surface/20. gt 0)
 scattered=scattered/factor
 for i=0,n-1,1 do begin
 for j=0,n-1,1 do begin
 noisy(i,j)=randomn(seed,poisson=scattered(i,j))
 endfor
 endfor
 if (ifield eq 0) then sumfield=noisy
 if (ifield gt 0) then sumfield=sumfield+noisy
endfor ; end of ifield
noisy=sumfield/nfields
; surface,noisy,x,y
angles=atan((y-y0)/(x-x0))/2./!pi*360.
rstep=9.
anglestep=5.
openw,23,'BBSO.dat'
for r=100,500,rstep do begin
	idx=where(radius_surface gt r and radius_surface lt r+rstep and angles gt 40 and angles le 40+anglestep and x gt x0)
	;	help,idx
		if (n_elements(idx) gt 2) then begin
	surf=noisy*0
	surf(idx)=noisy(idx)
	;contour,surf,/isotropic
	print,mean(radius_surface(idx)),mean(noisy(idx)),stddev(noisy(idx)),n_elements(idx)
printf,23,mean(radius_surface(idx)),mean(noisy(idx)),stddev(noisy(idx)),n_elements(idx)
	endif

endfor
close,23
data=get_data('BBSO.dat')
r=reform(data(0,*))
mn=reform(data(1,*))
st=reform(data(2,*))
n=reform(data(3,*))
st_mn=st/sqrt(n)
idx=where(r gt 250)
r=r(idx)
mn=mn(idx)
st_mn=st_mn(idx)
!P.MULTI=[0,1,1]
plot,r,mn,xrange=[200,600],xstyle=1,xtitle='Radius from lunar disc center (pixels)',ytitle='Intensity (counts)',title='Nfields='+string(fix(nfields))
oploterr,r,mn,st_mn
res=linfit(r,mn,measure_errors=st_mn,/double,yfit=yhat,sigma=sigs)
print,'a: ',res(0),'+/-',sigs(0)
print,'b: ',res(1),'+/-',sigs(1)
oplot,r,yhat

r2=findgen(100)/100.*350+210.
yhat2=res(0)+res(1)*r2
dy=sqrt(sigs(0)^2+sigs(1)^2*(r2-mean(r2))^2)
oplot,r2,yhat2+dy,linestyle=3
oplot,r2,yhat2-dy,linestyle=3
plots,[250,250],[!Y.crange],linestyle=2
kdx=where(r2 lt 250)
print,'mean predictand error on disc:',mean(dy(kdx))
xyouts,/data,330,28/factor,strcompress('a='+strmid(string(res(0)),0,12)+'+/-'+strmid(string(sigs(0)),0,10),/remove_all),charsize=1.9
xyouts,/data,330,25/factor,strcompress('b='+strmid(string(res(1)),0,11)+'+/-'+strmid(string(sigs(1)),0,10),/remove_all),charsize=1.9
xyouts,/data,260,19.4/factor,strcompress('!7D!3='+strmid(string(mean(dy(kdx))),0,12))
print,mean(dy(kdx))/2./28.*100.0,' % of ES at 28'
arrow,/data,255,21/factor,230,28/factor,thick=2,/solid
 end