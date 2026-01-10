OD=1.0532
err=0.0024
hi=10^(od+err)
lo=10^(od-err)
errpct=(hi-lo)/(hi+lo)*100.0
print,'Theerror is :',errpct,' %.'
end
