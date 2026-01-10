files=file_search('OUTPUT/UNflatdarked_OUTPUT/Lun*.fit')
n=n_elements(files)
for i=0,n-1,1 do begin
	print,i
	im=double(readfits(files(i)))
	if (i eq 0) then sum = im
	if (i gt 0) then sum=[[[sum]],[[im]]]
endfor
median_image=median(sum,dimension=3)
surface,median_image,charsize=3
writefits,'median_image.fit',float(median_image)
end
