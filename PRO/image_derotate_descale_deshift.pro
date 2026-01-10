

PRO fix_image,im,dark,n,m,width
l=size(im,/dimensions)
; first subtract the dark frame, using floats
im=float(im)-float(dark)
; subtract the sky level
sky=mean(im(602/2:816/2,608/2:813/2))
im=float(im)-float(sky)
; make image square
n=min([l(0),l(1)])
m=n
im=im(0:n-1,0:n-1)

return
end

;=======================================================
openw,23,'Andrew_derotation.dat'
files=file_search('C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\AUSTRALIAMOON\moon20*.FIT',count=Nims)
;files=file_search('/home/pth/SCIENCEPROJECTS/moon/ANDREW/DATA/moon*.FIT',count=Nims)
dark=readfits('C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\AUSTRALIAMOON\sydneydark.fit')
;dark=readfits('/home/pth/SCIENCEPROJECTS/moon/ANDREW/DATA/sydneydark.fit')

;----------------------------------
im1=readfits(files(150),/silent)
;
width=240
fix_image,im1,dark,n,m,width
print,'Pixel %:',n_elements(where(im1 gt 0.001*max(im1)))/(float(n*n))*100.
;
for im_num=0,Nims-1,1 do begin
	im2=readfits(files(im_num))
	l=size(im2,/dimensions)
	;im2=congrid(im2,l(0)*1.02,l(1)*1.02,/interp)
	im2=im2(0:l(0)-1,0:l(1)-1)
	fix_image,im2,dark,n,m,width
	im1use=im1
	im2use=im2
	srs_idl, im1use,im2use,Ffft_tm, Ffft_rad, Ffft_radc, absF_tm, absF_rad, $
            R, Rc, IRc, maxn, IX, IY, II, y, x, polar_coord1, $
            n, m, base, pIm1, pIm2, i, j, V00, V01, V10, V11, $
            X0, X1, y0, y1, s, R1, R2, R3, R1_Real, R1_Img, scale,angle
	diff=im1use-rot(shift(im2,ix/2.,iy/2.),angle,scale)
	kdx=where(finite(diff) eq 1 and im1use gt 0.0001*max(im1use))
	print,format='(i4,2(1x,f10.4),2(1x,i4),3(f12.4))', im_num,scale,angle,IX, IY,mean(diff(kdx)),stddev(diff(kdx)),mean(im1use)
	printf,23,format='(i4,2(1x,f10.4),2(1x,i4),3(f12.4))', im_num,scale,angle,IX, IY,mean(diff(kdx)),stddev(diff(kdx)),mean(im1use)
	!P.MULTI=[0,2,1]
	plot,total(diff,2),charsize=3
	;contour,abs(diff)/abs(im1use)*100.,charsize=2
	tvscl,diff
endfor
close,23
end


