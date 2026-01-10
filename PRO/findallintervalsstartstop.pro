PRO getalldata,start,stop,meanB,meanV,meanVE1,meanVE2,meanIRCUT
;
data=get_data('data_B.dat')
meanB=-9.111111
idx=where(data(0,*) ge start and data(0,*) lt stop)
if (n_elements(idx) ge 2) then begin
meanB=mean(data(1,idx))
endif
;
data=get_data('data_V.dat')
meanV=-9.111111
idx=where(data(0,*) ge start and data(0,*) lt stop)
if (n_elements(idx) ge 2) then begin
meanV=mean(data(1,idx))
endif
;
data=get_data('data_VE1.dat')
meanVE1=-9.111111
idx=where(data(0,*) ge start and data(0,*) lt stop)
if (n_elements(idx) ge 2) then begin
meanVE1=mean(data(1,idx))
endif
;
data=get_data('data_VE2.dat')
meanVE2=-9.111111
idx=where(data(0,*) ge start and data(0,*) lt stop)
if (n_elements(idx) ge 2) then begin
meanVE2=mean(data(1,idx))
endif
;
data=get_data('data_IRCUT.dat')
meanIRCUT=-9.111111
idx=where(data(0,*) ge start and data(0,*) lt stop)
if (n_elements(idx) ge 2) then begin
meanIRCUT=mean(data(1,idx))
endif
return
end

openw,33,'meanalfavalues.dat'
file='uniq_timesEFM.dat'
data=get_data(file)
start=data(0)
n=n_elements(data)
for i=0,n-1,1 do begin
stop=start+(15./60.)/24.0d0
idx=where(data ge start and data lt stop)
if (n_elements(idx) gt 1) then begin
stop=max(data(idx))
;print,format='(2(1x,f15.7),1x,i4)',start,stop,n_elements(idx)
getalldata,start,stop,meanB,meanV,meanVE1,meanVE2,meanIRCUT
print,format='(5(1x,f9.4))',meanB,meanV,meanVE1,meanVE2,meanIRCUT
printf,33,format='(5(1x,f9.4))',meanB,meanV,meanVE1,meanVE2,meanIRCUT
endif
start=stop
endfor
close,33
end
