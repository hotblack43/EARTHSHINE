PRO checkthese,keydays
caldat,keydays,mm,dd,yy
openw,91,'Check_these_against_input.dat'
for i=0,n_elements(mm)-1,1 do begin
printf,91,format='(1x,i2,1x,i2,1x,i4)',mm(i),dd(i),yy(i)
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
; add  a test signal at all key dates
	keydays=long(get_data(keydatefile))
	for i=0,n_elements(keydays)-1,1 do begin
		signal=10./(1.+(jd - keydays(i))^2)
		VAI=VAI+signal
	endfor
endif
return
end

PRO SPEA,jd,VAI,interval,SPEAsum,siglevel,sigvalue,keyfile,SEM,meanval
;---------------------------------
keydays=long(get_data(keyfile))
checkthese,keydays
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
		if (icount eq 1) then collect=[VAI(idx)-yhat]
		if (icount gt 1) then collect=[[[collect]],[VAI(idx)-yhat]]
		if (icount eq 1) then meanval=[mean(yhat)]
		if (icount gt 1) then meanval=[meanval,mean(yhat)]
	endif
	endif
endfor
SPEAsum=sum/float(icount)
SEM=fltarr(n_elements(sum))
for k=0,n_elements(sum)-1,1 do SEM(k)=stddev(collect(k,*))/sqrt(icount-1)
meanval=mean(meanval)
; - now get the siglevel
nMC=200
;nMC=n_elements(VAI)/10.0
print,'Performing ',nMC,' MC trials.'
for i=0,nMC-1,1 do begin
sum=0.0
span=max(jd)-min(jd)
days=long(randomu(seed,n_elements(keydays))*(span-2*interval-2)+jd(interval+1))
sum=fltarr(2*interval+1)
icount=0
for j=0,n_elements(days)-1,1 do begin
        idx=where(abs(jd - days(j)) le interval)
	if (n_elements(idx) ne 2*interval+1) then stop
        if (n_elements(idx) eq 2*interval+1) then begin
		dummy=linfit(indgen(2*interval+1),VAI(idx),yfit=yhat)
                sum=sum+VAI(idx)-yhat
		icount=icount+1
        endif
endfor
sum=sum/float(icount)
if (i eq 0) then bigarr=[sum]
if (i gt 0) then bigarr=[[[bigarr]],[sum]]
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
;............
; Key dates file
files=['MJJAS_Non_Volc_SW_JD.dat','NDJFM_Non_Volc_SW_JD.dat','MJJAS_Volc_SW_JD.dat','NDJFM_Volc_SW_JD.dat']
files=['MJJAS_Non_Volc_SBC_SW_JD.dat','MJJAS_Volc_SBC_SW_JD.dat','NDJFM_Non_Volc_SBC_SW_JD.dat','NDJFM_Volc_SBC_SW_JD.dat']
files=['MJJAS_Non_Volc_SBC_JD.dat','MJJAS_Volc_SBC_JD.dat','NDJFM_Non_Volc_SBC_JD.dat','NDJFM_Volc_SBC_JD.dat']
file=['NDJFM_Volc_SBC_JD.dat']
;............
; VAI files
file='SPECIAL_REL_VORT_VAI_factor_0p5/N_SPECIAL_GPH_VAISPECIAL_VAI_1948_2007_500mb.dat'
tstr='VAI from gph R.V. 0p5 50N-85N '
;..
file='/home/thejll/SCIENCEPROJECTS/VAI/SPECIAL_REL_VORT_VAI_factor_0p3/N_VAI_0p3_GPH_1948_2007_500mb.dat'
tstr='VAI from gph R.V. 0p3 50N-85N '
;..
file='VAI.txt'
tstr='VAI from gph abs. vort., 0p95, 20N-75N '
;............
for ikey=0,n_elements(files)-1,1 do begin
keydatefile=files(ikey)
print,'Using key date file:',files(ikey)
print,'Getting VAI!'
print,'Using data file:',file
get_VAI,jd,VAI,file,keydatefile
print,'Got VAI!'
interval=28
SPEA,jd,VAI,interval,sum,siglevel,sigvalue,keydatefile,SEM,meanval
plot,indgen(2*interval+1)-interval,sum,xtitle='Days from key date',$
	ytitle='!7R!3',charsize=1.4,$
	title=strcompress(tstr+' S.L.='+string(fix(siglevel(0)))+' and '+string(fix(siglevel(1)))+' %.'),$
	psym=-4,subtitle=keydatefile,yrange=[min([sigvalue(0)*1.1,sum]),max([sum,sigvalue(1)*1.1])]
oploterr,indgen(2*interval+1)-interval,sum,sem
oplot,[!X.CRANGE],[sigvalue(0),sigvalue(0)],linestyle=2
oplot,[!X.CRANGE],[sigvalue(1),sigvalue(1)],linestyle=2
xyouts,/normal,0.2,0.8,'Mean removed by regression:'+string(meanval)
endfor
end


