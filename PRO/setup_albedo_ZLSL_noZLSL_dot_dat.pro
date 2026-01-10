openw,44,'albedo_ZLSL_noZLSL.dat'
data=get_data('CLEM.profiles_fitted_results_fan_yesnoZLSL_DSBS_TEST3_JUSTTHEDATA.txt')
openr,1,'JDyesandno'
while not eof (1) do begin
JD=''
readf,1,JD
idx=where(data(0,*) eq JD)
if (n_elements(idx) ge 2) then begin
for k=0,n_elements(idx)-1,1 do begin
arr=data(13,idx)
arr=arr(sort(arr))
if(total(abs(arr-data(13,idx(0)))) eq 0) then stop
vals=arr(uniq(arr))
if(n_elements(vals) ne 2) then stop
jdx=where(data(13,idx) eq vals(0))
kdx=where(data(13,idx) eq vals(1))
print,format='(f15.7,4(1x,f9.6))',JD,mean(data(1,idx(jdx))),0.0,mean(data(1,idx(kdx))),0.0
printf,44,format='(f15.7,4(1x,f9.6))',JD,mean(data(1,idx(jdx))),0.0,mean(data(1,idx(kdx))),0.0
endfor
endif else begin
print,'Not enough data'
endelse
endwhile
close,1
close,44
end
