PRO powersp,im,ps
im=im/total(im,/double)
z=fft(im,-1,/double)
zz=z*conj(z)
ps=double(zz)
return
end

PRO getJDfromname,filename,JD
bits=strsplit(filename,'/',/extract)
parts=strsplit(bits(5),'MOON',/extract)
JD=double(parts(0))
return
end

file=file_search('/media/thejll/OLDHD/MOONDROPBOX/','*MOON_V_AIR.fi*',count=nstacks)
fmt_str='(f15.7,1x,f9.2,1x,a)'
openw,44,'stability_all_V_stacks.txt'
for istack=0,nstacks-1,1 do begin
print,file(istack)
getJDfromname,file(istack),JD
stack=readfits(file(istack))
l=size(stack)
print,l
if (l(0) gt 2) then begin
nims=l(3)
im_orig=reform(stack(*,*,50))
powersp,im_orig,ps_orig
stability=0.0
for i=0,99,1 do begin
im=reform(stack(*,*,i))
tvscl,(im)
dx=256*(randomu(seed)-0.5)
dy=256*(randomu(seed)-0.5)
im_shifted=shift(im,dx,dy)
powersp,im_shifted,ps_shifted
ratio=ps_orig/ps_shifted
diff=(ps_shifted-ps_orig)/ps_orig
stability=stability+total(diff^2)
endfor
printf,44,format=fmt_str,JD,sqrt(stability)/float(nims),file(istack)
print,format=fmt_str,JD,sqrt(stability)/float(nims),file(istack)
endif
endfor
close,44
end
