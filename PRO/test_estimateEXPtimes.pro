; will test test_estimateEXPtimes
jd=systime(/julian);	2466930.0d0
for jd=systime(/julian),systime(/julian)+31.0,1. do begin
estimateEXPtimes,jd,FILTERtimes
filternames=['B','V','VE1','VE2','IRCUT']
for k=0,4,1 do begin
print,format='(a5,1x,a3,f9.4,a)',filternames(k),' : ',FILTERtimes(k),' s.'
endfor
endfor
end
