PRO hone,im1,im2shifted,best_shifted,r_best
r_best=-1e22
for dx=-1.0,1.0,0.07 do begin
for dy=-1.0,1.0,0.07 do begin
im3=shift_sub(im2shifted,dx,dy)
r=correlate(im1,im3,/double)
if (r gt r_best) then begin
r_best=r
best_dx=dx
best_dy=dy
best_shifted=im3
endif
endfor
endfor
return
end

common shifts,shifts
;..............................
files=file_search('/home/pth/Desktop/ASTRO/EARTHSHINE/M15/dithered/*.fits',count=n)
 bias=double(readfits('superbias.fits',/silent))
 im1=double(readfits('/home/pth/Desktop/ASTRO/EARTHSHINE/M15/dithered/2455849.0552535MOON_DITHER_B_AIR.fits',/silent))
 im1=im1-bias
 for ifile=0,n-1,1 do begin
     im2=double(readfits(files(ifile),/silent))
     if (max(im2) gt 20000. and max(im2) lt 55000.) then begin
         im2=im2-bias
         imethod=5
         supralign,im1,im2,im2shifted,R,imethod
         hone,im1,im2shifted,best_shifted,r_best
	if (r_best gt r) then im2shifted=best_shifted
         print,imethod,r,total(im2shifted/mean(im2shifted)-im2/mean(im2)),r_best
         tvscl,im2shifted/mean(im2shifted)-im1/mean(im1)
         endif
     endfor	; loop over images
 end
