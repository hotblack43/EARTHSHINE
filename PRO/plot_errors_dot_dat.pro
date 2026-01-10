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
!P.MULTI=[0,1,1]
!P.CHARSIZE=2
!P.THICK=2
!x.THICK=2
!y.THICK=2
; first sort the data into seperate files for each filter
n=0
for ifilter=0,n_elements(fnames)-1,1 do begin
openr,1,'errors_FORCRAY.dat'
;openr,1,'errors.dat'
ic=0
while not eof(1) do begin
filtername=''
JD=0.0d0
alfa=0.0
err1=0.0
err2=0.0
readf,1,jd,alfa,err1,err2,filtername
filtername=strcompress(filtername,/remove_all)
filtername=strmid(filtername,1,strlen(filtername)-1)
if (strcompress(filtername,/remove_all) eq strcompress(fnames(ifilter),/remove_all)) then begin
if (ic eq 0) then openw,23,strcompress(fnames(ifilter)+'_.dat',/remove_all)
printf,23,format='(f15.7,3(1x,f21.7))',jd,alfa,err1,err2
n=n+1
ic=ic+1
endif
endwhile
close,23
close,1
endfor
for ifilter=0,n_elements(fnames)-1,1 do begin
print,'Reading '+strcompress(fnames(ifilter)+'_.dat',/remove_all)
data=get_data(strcompress(fnames(ifilter)+'_.dat',/remove_all))
jd=reform(data(0,*))
JDName=long(jd(0))
jd=jd-long(jd(0))
alfa=reform(data(1,*))
err1=reform(data(2,*))
err2=reform(data(3,*))
if (ifilter eq 0) then plot,/NODATA,xtitle='JD fraction',jd,alfa,yrange=[min(alfa),max(alfa)],ytitle='!7a!3',charsize=1.3,psym=7,xstyle=3,ystyle=3,title=string(JDName)+' 32bit - EFM - 11x11 - 2 iterations',color=fsc_color(plotfarve)
oplot,jd,alfa,color=fsc_color(farver(ifilter)),psym=7
oplot,[!x.crange],[3./1.6,3./1.6],linestyle=2
oplot,[!x.crange],[2.7/1.6,2.7/1.6],linestyle=2
oplot,[!x.crange],[2.55/1.6,2.55/1.6],linestyle=2
xyouts,/normal,0.2,0.8,'Orange=VE1; Red=VE2; Blue=B; Cyan=V; Green=IRCUT',charsize=1.3
endfor
end
