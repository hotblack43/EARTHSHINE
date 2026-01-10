pathname='/home/pth/Desktop/ASTRO/ANDOR/'
 file1='align_stacked_BBSO-33Frame-LO-r1-1.fits'
 file2='align_stacked_BBSO-10Frame-r2.fits'
 im1=double(readfits(pathname+file1))
 im2=double(readfits(pathname+file2))
 im1=im1/mean(im1)*mean(im2)	; rescale means
 key='w'
 contour,im1/im2,/cell_fill,nlevels=71
 while (key ne 'q') do begin
 y1=0
 x1=0
 scale=1.0
     key=get_kbrd()
     
     if (key eq 'u') then begin
         y1=y1+1
         endif
     if (key eq 'd') then begin
         y1=y1-1
         endif
     if (key eq 'r') then begin
         x1=x1+1
         endif
     if (key eq 'l') then begin
         x1=x1-1
         endif
     
     if (key eq 'S') then begin
         scale=scale*1.05
         endif
     if (key eq 's') then begin
         scale=scale/1.05
   	 endif
   	print,x1,y1,scale 
     rotim= ROT(im1, 0.0, scale,cubic=-0.5)
     subim=shift_sub(rotim, x1, y1)
	im1=subim
     ratio=im1/im2
     contour,ratio,/cell_fill,nlevels=71
     endwhile
 end
