flatfiles=file_search('f:\Flat*.fit',count=ndarks)
print,flatfiles
icount=1
; the the dark frame
dark=readfits('f:\dark_frame_med_fix_25smoo.fit')
	im0=readfits(flatfiles(0))
	stack=[im0-dark]
for i=1,ndarks-1,1 do begin
	im=readfits(flatfiles(i))
	im=im/mean(im)*mean(im0)
	l=size(im,/dimensions)
	im=rebin(im,l/2)
    stack=[[[stack]],[[im-dark]]]
 endfor
med=median(stack,/double,dimension=3)
surface,med,charsize=2
writefits,'f:\median_flat.fit',med
end