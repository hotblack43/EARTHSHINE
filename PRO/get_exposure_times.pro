@stuff21.pro
PRO get_times,file,act,exptime
im=readfits(file,h,/sil)
get_info_from_header,h,'DMI_ACT_EXP',act
get_EXPOSURE,h,exptime
end

files=file_search('/media/SAMSUNG/CLEANEDUP2455917/2455*_B_*.fits',count=nfiles)
openw,23,'exposuretimes_2455917_B.dat'
for ifil=0,nfiles-1,1 do begin
get_times,files(ifil),act,exptime
print,format='(2(1x,f8.5))',exptime,act
printf,23,format='(2(1x,f8.5))',exptime,act
endfor
close,23
end

