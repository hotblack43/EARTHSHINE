nJD=200
JDmin=julday(1,1,1950)*1.0d0
JDmax=julday(1,1,2014)*1.0d0
JD=randomu(seed,nJD)*(JDmax-JDmin)+JDmin
for i=0,nJD-1,1 do begin
openw,33,'JDtouseforSYNTH_117'
printf,33,format='(f15.7)',JD(i)
print,format='(f15.7)',JD(i)
close,33
spawn,'idl go_get_particular_synthimage_118.pro'

endfor
end
