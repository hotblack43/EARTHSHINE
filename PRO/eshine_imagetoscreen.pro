
;===============================================================================
;
; PRO eshine_imagetoscreen
;
; Version 2007-06-07
;
;===============================================================================


PRO eshine_imagetoscreen,  image_16bit, image_info, imsize, windx1, windx2


;------------------------------
; Define a screen factor
;------------------------------
screenfactor = 1.0


;------------------------------
; Create an 8-bit image
;------------------------------
image_8bit = bytscl(image_16bit)


;-----------------------------------------------------------------------
; Retrieve image information
;-----------------------------------------------------------------------
hist = histogram(image_8bit)


;-----------------------------------------------------------------------
; Plot in a window on screen.
;-----------------------------------------------------------------------
set_plot,'win'

window,0,xpos=390,ypos=0,xsize=fix(imsize/screenfactor),ysize=fix(imsize/screenfactor)
tv,congrid(image_8bit,fix(imsize/screenfactor),fix(imsize/screenfactor))

!P.MULTI = [0,2,1]
window,1,xpos=390,ypos=530,xsize=800,ysize=340
plot, indgen(imsize)-imsize/2, image_8bit[*,imsize/2], xrange=[-imsize/2,imsize/2], yrange=[0,256], xstyle=1, ystyle=1, thick=2.0, xtitle='pixels', ytitle='E!Imoon!N', title='pixel values along Moon''s equator', charsize=1.4, charthick=1.2
plot, alog10(hist+0.000001), xrange=[0,256], yrange=[0,4.5], xstyle=1, ystyle=1, thick=2.0, xtitle='pixel value', ytitle='log(number of pixels)', title='histogram for pixel values', charsize=1.4, charthick=1.2


END
