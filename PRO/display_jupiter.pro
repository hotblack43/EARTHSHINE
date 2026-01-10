FUNCTION hmm,x
y=x(sort(x))
n=n_elements(y)
y=y(n*0.25:n*0.75)
value=mean(y,/double)
return,value
end

PRO get_exptime,header,exptime
idx=where(strpos(header, 'EXPOSURE') eq 0)
str='999'
if (idx(0) ne -1) then str=header(idx)
exptime=float(strmid(str,9,strlen(str)-1))
return
end

bias=double(readfits('superbias.fits'))
files=file_search('/media/thejll/OLDHD/MOONDROPBOX/JD2455833/*JUPITER_V_*.fits*',count=n)
ic=0
for i=0,n-1,1 do begin
im=double(readfits(files(i),h,/silent))
scale=hmm(im(*,0:100))/hmm(bias(*,0:100))
print,scale
im=im-bias*scale
get_exptime,h,exptime
if (max(im) gt 1000) then begin
	if (ic eq 0) then stack=im
	if (ic gt 0) then stack=[[[stack]],[[im]]]
	ic=ic+1
	help,stack
endif
endfor
l=size(stack,/dimensions)
nims=l(2)
; now align the stack
ref=stack(*,*,0)
for i=1,nims-1,1 do begin
im=reform(stack(*,*,i))
shifts=alignoffset(ref,im)
ref=ref+shift_sub(im,shifts(0),shifts(1))
print,'shifts: ',shifts
print,mean(im(*,0:100)),mean(im(*,400:511))
tvscl,hist_equal(ref)
endfor
; repeat, with improved ref
for i=0,nims-1,1 do begin
im=reform(stack(*,*,i))
shifts=alignoffset(ref,im)
ref=ref+shift_sub(im,shifts(0),shifts(1))
tvscl,hist_equal(ref)
endfor
writefits,'jupiter_stacked_V.fits',ref/max(ref)*50000.0d0
end
