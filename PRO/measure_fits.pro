PRO get_4_spots,im,means
;contour,im,/cell_fill
im0=im(100:200,100:200)
im1=im(300:400,100:200)
im2=im(100:200,300:400)
im3=im(300:400,300:400)
means=fltarr(4)
means(0)=mean(im0)
means(1)=mean(im1)
means(2)=mean(im2)
means(3)=mean(im3)
;print,'0:',mean(im0),stddev(im0)
;print,'1:',mean(im1),stddev(im1)
;print,'2:',mean(im2),stddev(im2)
;print,'3:',mean(im3),stddev(im3)
return
end

starfiles=file_search('C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\data*.fit',count=n)
print,starfiles
imref=readfits(starfiles(0))
get_4_spots,imref,means_ref
slope_ref=means_ref(3)-means_ref(0)
for i=1, n-1,1 do begin
	im=readfits(starfiles(i))
    get_4_spots,im,means
	slope=means(3)-means(0)
	delta_slope=(slope-slope_ref)/slope_ref*100.
	print,'Change in slope wrt. ref image is:',delta_slope,' %.'
	print,slope,slope_ref
endfor
end