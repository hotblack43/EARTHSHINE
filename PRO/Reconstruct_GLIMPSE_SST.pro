PRO fix_identical,ilat,ilon
n=n_elements(ilat)
for i=0,n-2,1 do begin
for j=i+1,n-1,1 do begin
if (ilat(i) eq ilat(j) and (ilon(i) eq ilon(j))) then begin
ilat(i)=fix(ilat(i)/2)
print,'Fixed problem'
endif
endfor
endfor
return
end

device,decomposed=0
;loadct,39
;
file='/home/pth/Desktop/WORK/DATA/LSM.nc'
lon_lsm=0L
lat_lsm=0L
lsm=0L
id = NCDF_OPEN(file)
help,id,lon_lsm
print,NCDF_VARID(id,'lon')
NCDF_VARGET, id, 'lon',    lon_lsm
print,'Hej'
NCDF_VARGET, id, 'lat',    lat_lsm
NCDF_VARGET, id, 'var172',   lsm
NCDF_CLOSE,  id
print,'Done!'
;
file='/home/pth/Desktop/WORK/DATA/SST_1500-2000.nc'
ncdf_cat,file
id = NCDF_OPEN(file)
lon=0
lat=0
time=0
NCDF_VARGET, id, 'lon',    lon
nlon=n_elements(lon)*1.0
NCDF_VARGET, id, 'lat',    lat
nlat=n_elements(lat)*1.0
NCDF_VARGET, id, 'time',   time
year=fix(time/10000.)
rest=time-year*10000L
month=fix(rest/100.)
fracyear=year+(month-0.5)/12.
NCDF_VARGET, id, 'var139',   SST
NCDF_CLOSE,  id
print,'Done!'
;

;
ntime=501
SST=REBIN(SST,128,64,501)	; rebin to annual mean data
;SST=SST*0.+1.+273.15
;
weight=dblarr(nlon,nlat)
for ilon=0,nlon-1,1 do begin
for ilat=0,nlat-1,1 do begin
weight(ilon,ilat)=cos(lat(ilat)/360.*2.*!pi)
endfor
endfor

;
mean_land=dblarr(ntime)
mean_sea=dblarr(ntime)
mean_global=dblarr(ntime)
; LAND & SEA averages
idx=where(lsm eq 1)
jdx=where(lsm eq 0)
for i=0,ntime-1,1 do begin
	slice=reform(sst(*,*,i))
	mean_land(i)=total(slice(idx)*weight(idx))/total(weight(idx))
	mean_sea(i)=total(slice(jdx)*weight(jdx))/total(weight(jdx))
	mean_global(i)=total(slice*weight)/total(weight)
endfor


!P.MULTI=[0,1,4]

plot,mean_land-273.15,xtitle='Year',ytitle='Mean weighted land T',charsize=2,ystyle=1
plot,mean_sea-273.15,xtitle='Year',ytitle='Mean weighted ocean T',charsize=2,ystyle=1
plot,mean_global-273.15,xtitle='Year',ytitle='Ocean T/Land T',charsize=2,ystyle=1
plot,mean_land/mean_sea,xtitle='Year',ytitle='Land T/Sea T',charsize=2,ystyle=1
openw,11,'Land_Sea_LandSea.dat'
for i=0,ntime-1,1 do begin
printf,11,format='(i5,3(1x,f7.2))',i+1500,mean_land(i)-273.15,mean_sea(i)-273.15,mean_global(i)-273.15
print,format='(i5,3(1x,f7.2))',i+1500,mean_land(i)-273.15,mean_sea(i)-273.15,mean_global(i)-273.15

endfor
close,11
;----------------------------------
;----test 1 - random sample of unmodified point Temperatures
if_test1=1
if (if_test1 eq 1) then begin
str='Test 1 - reconstructing global temperatures, random sample'
target=mean_global

nrandom=20
ntest=100
proxy=dblarr(nrandom,ntime)
tau=dblarr(ntest)
stdd=dblarr(ntest)
steps=dblarr(ntest)
for itest=0,ntest-1,1 do begin
ilat=fix(randomu(seed,nrandom)*nlat)
ilon=fix(randomu(seed,nrandom)*nlon)
fix_identical,ilat,ilon
fix_identical,ilat,ilon
for irandom=0,nrandom-1,1 do begin
	proxy(irandom,*)=SST(ilon(irandom),ilat(irandom),*)
endfor
;--
xx=proxy
yy=target
res=regress(xx,yy,yfit=yfit,/double,sigma=sigs)
;--
residuals=yy-yfit
plot,residuals,xtitle='Year',ytitle='Residual',charsize=2,ystyle=1,title=str
tau(itest)=a_correlate(residuals,1)
steps(itest)=(1.0+tau(itest))/(1.0-tau(itest))
stdd(itest)=stddev(residuals)
print,format='(1x,f8.4,1x,f8.4,1x,f8.2)',stdd(itest),tau(itest),steps(itest)
endfor
!P.MULTI=[0,3,2]
histo,tau,0,1,0.1,xtitle='!7s!3'
histo,steps,0,5,0.2,xtitle='n'
histo,stdd,0,0.4,0.025,xtitle='!7r!3'
print,'Mean AC1  :',mean(tau)
print,'Mean n_eff:',mean(steps)
print,'Mean sigma:',mean(stdd)
endif	; end of test 1
;----------------------------------
;----test 2 - like test 1 but backw_elim is used instead of REGRESS
if_test2=0
if (if_test2 eq 1) then begin
str='Test 2 - back_elim, then as test 1'
target=mean_global

nrandom=80
ntest=100
proxy=dblarr(nrandom,ntime)
tau=dblarr(ntest)
stdd=dblarr(ntest)
steps=dblarr(ntest)
for itest=0,ntest-1,1 do begin
ilat=fix(randomu(seed,nrandom)*nlat)
ilon=fix(randomu(seed,nrandom)*nlon)
fix_identical,ilat,ilon
fix_identical,ilat,ilon
for irandom=0,nrandom-1,1 do begin
	proxy(irandom,*)=SST(ilon(irandom),ilat(irandom),*)
endfor
;--
xx=proxy
yy=target
res=backw_elim(xx,yy,0.05,yfit=yfit,/double,sigma=sigs,varlist=varlist)
print,varlist
;--
residuals=yy-yfit
plot,residuals,xtitle='Year',ytitle='Residual',charsize=2,ystyle=1,title=str
tau(itest)=a_correlate(residuals,1)
steps(itest)=(1.0+tau(itest))/(1.0-tau(itest))
stdd(itest)=stddev(residuals)
print,format='(1x,f8.4,1x,f8.4,1x,f8.2)',stdd(itest),tau(itest),steps(itest)
endfor
!P.MULTI=[0,3,2]
histo,tau,0,1,0.1,xtitle='!7s!3'
histo,steps,0,5,0.2,xtitle='n'
histo,stdd,0,0.4,0.025,xtitle='!7r!3'
print,'Mean AC1  :',mean(tau)
print,'Mean n_eff:',mean(steps)
print,'Mean sigma:',mean(stdd)
endif	; end of test 2
;----------------------------------
;----test 3 -like test 1 but using co_regress
if_test3=0
if (if_test3 eq 1) then begin
str='Test 3 '
target=mean_global
nrandom=30
ntest=100
proxy=dblarr(nrandom,ntime)
tau=dblarr(ntest)
stdd=dblarr(ntest)
steps=dblarr(ntest)
for itest=0,ntest-1,1 do begin
ilat=fix(randomu(seed,nrandom)*nlat)
ilon=fix(randomu(seed,nrandom)*nlon)
fix_identical,ilat,ilon
fix_identical,ilat,ilon
for irandom=0,nrandom-1,1 do begin
	proxy(irandom,*)=SST(ilon(irandom),ilat(irandom),*)
endfor
;--
xx=proxy
yy=target
res=co_regress(xx,yy,yfit=yfit,/double,sigma=sigs,rho=rho,niter=niter)
;print,niter
;--
residuals=yy-yfit
plot,residuals,xtitle='Year',ytitle='Residual',charsize=2,ystyle=1,title=str
tau(itest)=a_correlate(residuals,1)
steps(itest)=(1.0+tau(itest))/(1.0-tau(itest))
stdd(itest)=stddev(residuals)
print,format='(1x,f8.4,1x,f8.4,1x,f8.2)',stdd(itest),tau(itest),steps(itest)
endfor
!P.MULTI=[0,3,1]
histo,tau,0,1,0.1,xtitle='!7s!3'
histo,steps,0,5,0.2,xtitle='n'
histo,stdd,0,0.4,0.025,xtitle='!7r!3'
print,'Mean AC1  :',mean(tau)
print,'Mean n_eff:',mean(steps)
print,'Mean sigma:',mean(stdd)
endif	; end of test 3
;----------------------------------
;----test 4 - random sample of unmodified point Temperatures
if_test4=0
if (if_test4 eq 1) then begin
str='Test 4 - like 1, short calibration periode'
target=mean_global
time_idx=indgen(100)+399
time_idx=indgen(100)+394

nrandom=10
ntest=100
yfit=fltarr(ntest,ntime)
residuals=fltarr(ntest)
proxy=dblarr(nrandom,ntime)
tau=dblarr(ntest)
stdd=dblarr(ntest)
steps=dblarr(ntest)
for itest=0,ntest-1,1 do begin
ilat=fix(randomu(seed,nrandom)*nlat)
ilon=fix(randomu(seed,nrandom)*nlon)
fix_identical,ilat,ilon
fix_identical,ilat,ilon
for irandom=0,nrandom-1,1 do begin
	proxy(irandom,*)=SST(ilon(irandom),ilat(irandom),*)
endfor
;--
xx=proxy
yy=target
res=regress(xx(*,time_idx),yy(time_idx),/double,sigma=sigs,const=const)
yfit(itest,*)=const+res # xx
;--
residuals=yy-yfit(itest,*)
plot,residuals,xtitle='Year',ytitle='Residual',charsize=2,ystyle=1,title=str
tau(itest)=a_correlate(residuals,1)
steps(itest)=(1.0+tau(itest))/(1.0-tau(itest))
stdd(itest)=stddev(residuals)
print,format='(1x,f8.4,1x,f8.4,1x,f8.2)',stdd(itest),tau(itest),steps(itest)
endfor
!P.MULTI=[0,3,2]
histo,tau,0,1,0.1,xtitle='!7s!3'
histo,steps,0,5,0.2,xtitle='n'
histo,stdd,0,0.4,0.025,xtitle='!7r!3'
print,'Mean AC1  :',mean(tau)
print,'Mean n_eff:',mean(steps)
print,'Mean sigma:',mean(stdd)
!P.MULTI=[0,1,3]
plot,yy,xtitle='Year',ytitle='T and T_hat',ystyle=1
for ijk=0,ntest-1,1 do begin
	oplot,yfit(ijk,*),psym=3
endfor
oplot,yy,color=0,thick=7
oplot,yy,color=254,thick=2
plots,[time_idx(0),time_idx(0)],[!Y.CRANGE]
plots,[time_idx(99),time_idx(99)],[!Y.CRANGE]
mean_line=fltarr(ntime)
upper_90=fltarr(ntime)
lower_90=fltarr(ntime)
stdd=fltarr(ntime)
for i=0,ntime-1,1 do begin
array=yfit(*,i)
array=array(sort(array))
mean_line(i)=mean(array)
upper_90(i)= array(0.9*ntest)
lower_90(i)= array(0.1*ntest)
stdd(i)=stddev(array)
endfor
oplot,mean_line,color=57,thick=2
oplot,upper_90,color=57
oplot,lower_90,color=57
;plot,yy,xtitle='Year',ytitle='T and T_hat',ystyle=1,color=254,thick=2
;oplot,mean_line,color=57,thick=2
;plots,[time_idx(0),time_idx(0)],[!Y.CRANGE]
;plots,[time_idx(99),time_idx(99)],[!Y.CRANGE]

plot,yy-mean_line,xtitle='Year',ytitle='T - mean T',ystyle=1,color=254,thick=2
plots,[!X.CRANGE],[0,0]
plots,[time_idx(0),time_idx(0)],[!Y.CRANGE]
plots,[time_idx(99),time_idx(99)],[!Y.CRANGE]

plot,stdd,xtitle='Year',ytitle='STD',ystyle=1,color=254,thick=2
plots,[!X.CRANGE],[0,0]
plots,[time_idx(0),time_idx(0)],[!Y.CRANGE]
plots,[time_idx(99),time_idx(99)],[!Y.CRANGE]

endif	; end of test 4

end
