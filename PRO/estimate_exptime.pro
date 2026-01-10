n=1000
t1=systime(/seconds)
for i=0,n-1,1 do begin
f='MSO_observed.fit'
im=readfits(f,header)
idx=strpos(header,'EXPTIME')
ipoint=where(idx eq 0)
expt=float(strmid(header(ipoint),10,30))
estimate=mean(im)/45000.0*expt
;print,'MEan of image is :',mean(im)
;print,'Exposure time was:',expt
endfor
print,'Estimated time needed to reach mean of 45000 is:',expt*45000.0/mean(im),' seconds'
t2=systime(/seconds)
print,(t2-t1)/float(n)
end
