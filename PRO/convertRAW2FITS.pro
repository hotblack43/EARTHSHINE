PRO getBINfile,filename,im
ino=file_info(filename)
n=ino.size
;print,'found n= ',n
if(n eq 1048576L) then begin
nn=sqrt(n)/2
im=fltarr(nn,nn)
endif
if(n eq 2*1048576L) then begin
nn=sqrt(2097152L/2)/2
im=dblarr(nn,nn)
endif
get_lun,w
openr,w,filename & readu,w,im & close,w
free_lun,w
return
end

getBINfile,'inputfile.raw',im
writefits,'outputfile.fits',im
end
