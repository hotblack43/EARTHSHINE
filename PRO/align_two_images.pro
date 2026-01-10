PRO normit,target,moveit
mv=mean(double(target),/NaN)
factor=mv/mean(double(moveit),/NaN)
print,'factor :',factor
moveit=double(moveit)*factor
return
end

target=readfits('TOMSTONE/2709_ROLO_rotatedm90.fit')
moveit=readfits('./OUTPUT/IDEAL/ideal_LunarImg_0000.fit')
; normalize to same mean
print,mean(target),mean(moveit)
normit,target,moveit
print,mean(target),mean(moveit)
maxerr=1e33
;	0.660000       0      1.18000      28      -7
;	     0.640000     0.280000      1.18000      28      -7       4.1922401
;  0.630000    0.0799999      1.18000      28      -6
for b=-2.,2.,.01 do begin
for c=1.0,1.4,0.01 do begin
for d=25,30,1 do begin
for e=-5,-8,-1 do begin
for a=0.62,0.68,0.01 do begin
testim=a*shift(rot(reverse(moveit),b,c,/interp),d,e)
err=total((target-testim)^2)
if (err lt maxerr) then begin
print,a,b,c,d,e,total((target-testim)^2,/double,/NaN)
tvscl,[target,testim,target-testim]
maxerr=err
writefits,'rotatedandscaled.fit',testim
endif
endfor
endfor
endfor
endfor
endfor
end

