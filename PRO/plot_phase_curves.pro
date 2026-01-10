file='exoatmosphericBS.txt'
data=get_data(file)
;
phase=reform(data(2,*))
idx=sort(abs(phase))
data=data(*,idx)
fnum=reform(data(0,*))
JD=reform(data(1,*))
phase=reform(data(2,*))
BS_0=reform(data(3,*))
direction=reform(data(4,*))
fnames=['B','V','VE1','VE2','IRCUT']
;
plot,abs(phase),BS_0,psym=7,xstyle=3,ystyle=3,title='Phase curves for BS',xtitle='|phase|',ytitle='BS [mags]'
colname=['blue','green','orange','red','yellow']
print,'----------------'
for j=0,4,1 do begin
print,(colname(j))
idx=where(fnum eq j)
oplot,abs(phase(idx)),BS_0(idx),color=fsc_color(colname(j)),linestyle=0
;res=linfit(abs(phase(idx)),BS_0(idx),sigma=sigs,/double,yfit=yhat)
res=robust_linefit(abs(phase(idx)),BS_0(idx),yhat,sig,sigs)
oplot,abs(phase(idx)),yhat,color=fsc_color(colname(j)),linestyle=2
print,res(0),' +/- ',sigs(0)
print,res(1),' +/- ',sigs(1)
print,'----------------'
endfor
end
