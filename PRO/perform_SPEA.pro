PRO checkthese,keydays
caldat,keydays,mm,dd,yy
openw,91,'Check_these_against_input.dat'
for i=0,n_elements(mm)-1,1 do begin
	printf,91,format='(f20.1,1x,i2,1x,i2,1x,i4)',keydays(i),mm(i),dd(i),yy(i)
endfor
close,91
print,'Done checking dates - so should you!'
return
end


PRO get_VAI,jd,VAI,file,keydatefile
data=get_data(file)
jd=reform(data(0,*))
VAI=reform(data(1,*))
ifTest=0
if (ifTest eq 1) then begin
std_VAI=stddev(VAI)
; add  a test signal at all key dates
	keydays=long(get_data(keydatefile))
		for i=0,n_elements(keydays)-1,1 do begin
		signal=std_VAI*0.25
		disttokey=abs(jd - keydays(i)-20)
		idx=where(disttokey eq min(disttokey))
		print,idx
		VAI(idx(0))=VAI(idx(0))+signal
	endfor
endif
return
end

PRO SPEA,jd,VAI,interval,SPEAsum,siglevel,sigvalue,keyfile,SEM,mean_yhat
;---------------------------------
common stuff,nkeys
keydays=long(get_data(keyfile))
checkthese,keydays
nkeys=n_elements(keydays)
sum=fltarr(2*interval+1)
icount=0
for i=0,n_elements(keydays)-1,1 do begin
	if (keydays(i) lt julday(1,1,2008)-interval) then begin
	idx=where(abs(jd - keydays(i)) le interval)
	if (n_elements(idx) ne 2*interval+1) then begin
		print,'problem at:',keydays(i),i,jd(0),jd(n_elements(jd)-1)
		stop
	endif
	if (n_elements(idx) eq 2*interval+1) then begin
		dummy=linfit(indgen(2*interval+1),VAI(idx),yfit=yhat,/double)
		sum=sum+VAI(idx)-yhat
		icount=icount+1
		if (icount eq 1) then residuals=[VAI(idx)-yhat]
		if (icount gt 1) then residuals=[[[residuals]],[VAI(idx)-yhat]]
		if (icount eq 1) then mean_yhat=[mean(yhat)]
		if (icount gt 1) then mean_yhat=[mean_yhat,mean(yhat)]
	endif
	endif
endfor	; end of i loop
SPEAsum=sum/float(icount)
SEM=fltarr(n_elements(sum))
for k=0,n_elements(sum)-1,1 do SEM(k)=stddev(residuals(k,*))/sqrt(icount-1)
mean_yhat=mean(mean_yhat)
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
; - now get the siglevel
nMC=20
dummyx=indgen(2*interval+1)
print,'Performing ',nMC,' MC trials.'
for iMC=0,nMC-1,1 do begin
sumq=fltarr(2*interval+1)
useVAI=VAI
; Using the same key dates but surrogate data for VAI
icount=0
ac1=a_correlate(VAI,1)
;surrogate=pseudo_t_guarantee_ac1(VAI,ac1,1,seed)
surrogate=pseudo_t_guarantee_ac1(useVAI,ac1,2,seed)
for i=0,n_elements(keydays)-1,1 do begin
	if (keydays(i) lt julday(1,1,2008)-interval) then begin
	idx=where(abs(jd - keydays(i)) le interval)
	if (n_elements(idx) eq 2*interval+1) then begin
		dummy=linfit(dummyx,surrogate(idx),yfit=yhat2,/double)
		resid=surrogate(idx)-yhat2
		sumq=sumq+resid
		icount=icount+1
		if (icount eq 1) then residuals=[resid]
		if (icount gt 1) then residuals=[[[residuals]],[resid]]
	endif
	endif
endfor	; end of i loop over keydays
SPEA2sum=sumq/float(icount)
if (iMC eq 0) then bigarr=[SPEA2sum]
if (iMC gt 0) then bigarr=[bigarr,SPEA2sum]
endfor	; end of nMC loop

; find upper and lower 95% S.L.
z=bigarr(sort(bigarr))
slupper=z(0.95*n_elements(z))
sllower=z(0.05*n_elements(z))
siglevel=['5','95']
sigvalue=[sllower,slupper]
return
end


!P.MULTI=[0,1,1]
common stuff,nkeys
;............
; Key dates file
files=['MJJAS_Non_Volc_SW_JD.dat','NDJFM_Non_Volc_SW_JD.dat','MJJAS_Volc_SW_JD.dat','NDJFM_Volc_SW_JD.dat']
files=['MJJAS_Non_Volc_SBC_SW_JD.dat','MJJAS_Volc_SBC_SW_JD.dat','NDJFM_Non_Volc_SBC_SW_JD.dat','NDJFM_Volc_SBC_SW_JD.dat']
files=['MJJAS_Non_Volc_SBC_JD.dat','MJJAS_Volc_SBC_JD.dat','NDJFM_Non_Volc_SBC_JD.dat','NDJFM_Volc_SBC_JD.dat']
;files=['NDJFM_Volc_SBC_JD.dat']
;............
; VAI files
file='SPECIAL_REL_VORT_VAI_factor_0p5/N_SPECIAL_GPH_VAISPECIAL_VAI_1948_2007_500mb.dat'
tstr='VAI from gph R.V. 0p5 50N-85N '
;..
file='/home/thejll/SCIENCEPROJECTS/VAI/SPECIAL_REL_VORT_VAI_factor_0p3/N_VAI_0p3_GPH_1948_2007_500mb.dat'
tstr='VAI from gph R.V. 0p3 50N-85N '
;..
file='VAI_GPH_0p95_20N75N.dat'
tstr='VAI from gph abs. vort., 0p95, 20N-75N '
;
file='VAI_GPH_0p75_20N75N.dat'
tstr='VAI GPH 75% 20N-75N'
;
file='VAI_GPH_1p25_20N75N.dat'
tstr='VAI GPH 125% 20N-75N'
;
file='VAI_GPH_1p25_40N85N.dat'
tstr='VAI GPH 125% 40N-85N'
;............
for ikey=0,n_elements(files)-1,1 do begin
keydatefile=files(ikey)
print,'Using key date file:',files(ikey)
print,'Getting VAI!'
print,'Using data file:',file
get_VAI,jd,VAI,file,keydatefile
print,'Got VAI!'
interval=28
SPEA,jd,VAI,interval,sum,siglevel,sigvalue,keydatefile,SEM,mean_yhat
plot,indgen(2*interval+1)-interval,sum,xtitle='Days from key date',$
	ytitle='!7R!3',charsize=1.4,$
	title=strcompress(tstr+' S.L.='+string(fix(siglevel(0)))+' and '+string(fix(siglevel(1)))+' %.'),$
	psym=-4,subtitle=keydatefile,yrange=[min([sigvalue(0)*1.1,sum]),max([sum,sigvalue(1)*1.1])]
oploterr,indgen(2*interval+1)-interval,sum,sem
oplot,[!X.CRANGE],[sigvalue(0),sigvalue(0)],linestyle=2
oplot,[!X.CRANGE],[sigvalue(1),sigvalue(1)],linestyle=2
xyouts,/normal,0.2,0.8,'Mean removed by regression:'+string(mean_yhat)
xyouts,/normal,0.2,0.825,'Number of key days : '+string(nkeys)
endfor
end


