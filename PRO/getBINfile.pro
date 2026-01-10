PRO getBINfile,path_in,im,obs
; path_in is the PATH where the raw files sit
pth=strcompress(path_in+'/output.raw',/remove_all)
;print,'pth: ',pth
ino=file_info(pth)
n=ino.size
if(n eq 1048576L) then begin
nn=sqrt(n)/2
im=fltarr(nn,nn)
endif
if(n eq 2*1048576L) then begin
nn=sqrt(2097152L/2)/2
im=dblarr(nn,nn)
endif
openr,1,pth
readu,1,im
close,1
; get the observed image
pth=strcompress(path_in+'/target.raw',/remove_all)
;print,'pth: ',pth
ino=file_info(pth)
n=ino.size
if(n eq 1048576L) then begin
nn=sqrt(n)/2
obs=fltarr(nn,nn)
endif
if(n eq 2*1048576L) then begin
nn=sqrt(2097152L/2)/2
obs=dblarr(nn,nn)
endif
openr,1,pth
readu,1,obs
close,1
return
end
