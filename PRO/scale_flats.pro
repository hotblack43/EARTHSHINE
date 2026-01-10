PRO remove_bias,image
bias=readfits('one_median_bias_frame.FIT')
image=image-bias
print,'Removed bias'
return
end

!P.MULTI=[0,1,2]
files=file_search('~/Desktop/ASTRO/MOON/May28/FLATS1/LEFT/','*.FIT')
n=n_elements(files)
im0=readfits(files(0))
remove_bias,im0
stack=im0
icount=1
;for i=1,n-1,1 do begin
for i=1,11,1 do begin
imi=readfits(files(i))
remove_bias,imi
ratio=imi/im0
left_mean=mean(ratio(0:550,*))
print,i,left_mean
stack=[[[stack]],[[imi*left_mean]]]
icount=icount+1
endfor
meanframe=total(stack,3)/float(icount)
left_mean=mean(meanframe(0:550,*))
writefits,'mean_left_side_flat.FIT',float(meanframe/left_mean)
end
