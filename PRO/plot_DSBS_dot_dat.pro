dev='X'
dev='ps'
set_plot,dev
if (dev eq 'X') then plotfarve='white'
if (dev eq 'ps') then begin
plotfarve='black'
device,/color
endif
fnames=['VE1','VE2','B','V','IRCUT']
farver=['orange','red','blue','cyan','green']
!P.MULTI=[0,1,3]
!P.CHARSIZE=2
!P.THICK=2
!x.THICK=2
!y.THICK=2
fmt12='(a10,1x,a20,f8.4,a8,f8.4,a,f8.4)'
; first sort the data into seperate files for each filter
n=0
jdmin=1e23
jdmax=-1e23
for ifilter=0,n_elements(fnames)-1,1 do begin
openr,1,'DSBS_FORCRAY.dat'
ic=0
while not eof(1) do begin
filtername=''
JD=0.0d0
alfa=0.0
DSBS1=0.0
DSBS2=0.0
;2455924.7199653       1.7134  0.00057315  0.00040805 'VE1
readf,1,jd,alfa,DSBS1,DSBS2,filtername
if (jd lt jdmin) then jdmin=jd
if (jd gt jdmax) then jdmax=jd
filtername=strcompress(filtername,/remove_all)
filtername=strmid(filtername,1,strlen(filtername)-1)
if (strcompress(filtername,/remove_all) eq strcompress(fnames(ifilter),/remove_all)) then begin
if (ic eq 0) then openw,23,strcompress(fnames(ifilter)+'_.dat',/remove_all)
printf,23,format='(f15.7,3(1x,f21.7))',jd,alfa,DSBS1,DSBS2
n=n+1
ic=ic+1
endif
endwhile
close,23
close,1
endfor
;...............Plot alfa
for ifilter=0,n_elements(fnames)-1,1 do begin
nametoopen=strcompress(fnames(ifilter)+'_.dat',/remove_all)
if (file_exist(nametoopen) eq 1) then begin
print,'Reading '+strcompress(fnames(ifilter)+'_.dat',/remove_all)
data=get_data(strcompress(fnames(ifilter)+'_.dat',/remove_all))
jd=reform(data(0,*))
JDName=long(jd(0))
jd=jd-long(jd(0))
alfa=reform(data(1,*))
DSBS1=reform(data(2,*))
DSBS2=reform(data(3,*))
if (ifilter eq 0) then plot,/NODATA,xtitle='JD fraction',jd,alfa,yrange=[1.6,1.8],ytitle='!7a!3',charsize=1.3,psym=7,xstyle=3,ystyle=3,title=string(JDName),xrange=[jdmin-long(jdmin),jdmax-long(jdmax)],color=fsc_color(plotfarve)
oplot,jd,alfa,color=fsc_color(farver(ifilter)),psym=7
endif
endfor
;...............
minrat=0
maxrat=0.02
for ifilter=0,n_elements(fnames)-1,1 do begin
nametoopen=strcompress(fnames(ifilter)+'_.dat',/remove_all)
if (file_exist(nametoopen) eq 1) then begin
;print,'Reading '+strcompress(fnames(ifilter)+'_.dat',/remove_all)
data=get_data(strcompress(fnames(ifilter)+'_.dat',/remove_all))
jd=reform(data(0,*))
JDName=long(jd(0))
jd=jd-long(jd(0))
alfa=reform(data(1,*))
DSBS1=reform(data(2,*))
idx=where(DSBS1 gt 0) & jd=jd(idx) & alfa=alfa(idx) & DSBS1=DSBS1(idx)
if (ifilter eq 0) then plot,/NODATA,xtitle='JD fraction',jd,DSBS1,yrange=[minrat,maxrat],ytitle='DS/BS: median/mean 1',charsize=1.3,psym=7,xstyle=3,ystyle=3,title=string(JDName)+'EFM; patch 1',color=fsc_color(plotfarve),xrange=[!X.CRANGE]
oplot,jd,DSBS1,color=fsc_color(farver(ifilter)),psym=7
print,format=fmt12,fnames(ifilter),'mean: ',mean(DSBS1),' +/- SD',stddev(DSBS1),' Zm: ',mean(DSBS1)/(stddev(DSBS1)/sqrt(n_elements(DSBS1)-1))
res=linfit(jd,DSBS1,/double,yfit=yhat,sigma=sig)
print,format=fmt12,fnames(ifilter),'regression: ',res(1),' +/- ',sig(1),' Z: ',res(1)/sig(1)
oplot,jd,yhat,color=fsc_color(farver(ifilter))
;print,fnames(ifilter),min(DSBS1),max(DSBS1)
endif
endfor
;...............
print,'                      '
for ifilter=0,n_elements(fnames)-1,1 do begin
nametoopen=strcompress(fnames(ifilter)+'_.dat',/remove_all)
if (file_exist(nametoopen) eq 1) then begin
data=get_data(strcompress(fnames(ifilter)+'_.dat',/remove_all))
jd=reform(data(0,*))
JDName=long(jd(0))
jd=jd-long(jd(0))
alfa=reform(data(1,*))
DSBS2=reform(data(3,*))
idx=where(DSBS2 gt 0) & jd=jd(idx) & alfa=alfa(idx) & DSBS2=DSBS2(idx)
if (ifilter eq 0) then plot,/NODATA,xtitle='JD fraction',jd,DSBS2,yrange=[minrat/2.,maxrat],ytitle='DS/BS: median/mean 2',charsize=1.3,psym=7,xstyle=3,ystyle=3,title=string(JDName)+'EFM; patch 2',color=fsc_color(plotfarve),xrange=[!X.CRANGE]
oplot,jd,DSBS2,color=fsc_color(farver(ifilter)),psym=7
xyouts,/normal,0.1,0.9,'Orange=VE1; Red=VE2; Blue=B; Cyan=V; Green=IRCUT',charsize=1.3
print,format=fmt12,fnames(ifilter),'mean: ',mean(DSBS2),' +/- SD',stddev(DSBS2),' Zm: ',mean(DSBS2)/(stddev(DSBS2)/sqrt(n_elements(DSBS2)-1))
res=linfit(jd,DSBS2,/double,yfit=yhat,sigma=sig)
print,format=fmt12,fnames(ifilter),'regression: ',res(1),' +/- ',sig(1),' Z: ',res(1)/sig(1)
oplot,jd,yhat,color=fsc_color(farver(ifilter))
;print,fnames(ifilter),min(DSBS2),max(DSBS2)
endif
endfor
end
