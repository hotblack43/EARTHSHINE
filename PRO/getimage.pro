PRO getimage,c_image
 common sizes,l
 common imagedescrip,noise
;-----------------------

;file='C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\stacked_new_349_float.FIT'
;file='H:\Processed\KING_0040.fit'
;-----------------------
 file='/home/pth/SCI/moon/ANDREW/stacked_new_349_float.FIT'
; file='KING.fit'
;-----------------------
 c_image=readfits(file)
;.............................
; add some noise if you want
; c_image=c_image/max(c_image)*50000.+10.*randomn(seed)
;.............................
 l=size(c_image,/dimensions)
 ll=min(l)
 c_image=c_image(0:ll-1,0:ll-1)	; clip so its square
 c_image=congrid(c_image,128,128) ; resize to 2^n
 l=size(c_image,/dimensions)
;--------------------------------------------------------
; measure the noise in the high-pass filtered image
 nn=3
 noise=c_image-smooth(c_image,nn,/edge_truncate)
 noise=sqrt(mean(noise^2))
 noise=10.0
 return
 end
