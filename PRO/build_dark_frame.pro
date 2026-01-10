darkfiles=file_search('f:\Dark*.fit',count=ndarks)
print,darkfiles
icount=1
for i=0,ndarks-1,1 do begin
	im=readfits(darkfiles(i))
    if (i eq 0) then stack=[im]
    if (i gt 0) then stack=[[[stack]],[[im]]]
    help,stack
endfor
med=median(stack,/double,dimension=3)
surface,med,charsize=2
writefits,'f:\median_dark_frame.fit',med
; bad pixels
badlimit=3.4
badpixels=where((med - smooth(med,5))/stddev(median) gt badlimit)
fixed_median=med
fixed_median(badpixels)=mean(med(badpixels))
surface,fixed_median,charsize=2
writefits,'f:\dark_frame_med_fix.fit',fixed_median
writefits,'f:\dark_frame_med_fix_25smoo.fit',smooth(fixed_median,25,/edge_truncate)
end