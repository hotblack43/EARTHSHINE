JDlist='Vjds.list'
get_lun,lls
openr,lls,JDList
openw,83,'photometry.dat'
while not eof(lls) do begin
JD=''
readf,lls,JD
get_lun,qwe & openw,qwe,'JDtouseforSYNTH'
 printf,qwe,format='(f15.7)',JD
close,qwe & free_lun,qwe   ; JD now resides in file 'JDtouseforSYNTH'
 ; get the synth code to generate the refim
 spawn,'idl go_get_particular_synthimage_nolroclem.pro'
endwhile
close,lls
close,83
free_lun,lls
end
