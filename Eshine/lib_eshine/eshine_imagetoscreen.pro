
;===============================================================================
;
; PRO eshine_imagetoscreen
;
; Version 2007-08-01
;
;===============================================================================


PRO eshine_imagetoscreen,  image_16bit, image_info, if_show, device_str, windx1, windx2


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
l = size(image_8bit,/dimensions)
xsize = l[0]
ysize = l[1]


;-----------------------------------------------------------------------
; Plot in a window on screen.
;-----------------------------------------------------------------------
if (if_show EQ 1) AND (device_str NE 'PS') then begin

  set_plot,'X'
;  set_plot,'win'

  window,0,xpos=390,ypos=0,xsize=fix(xsize/screenfactor),ysize=fix(ysize/screenfactor)
  tv,congrid(image_8bit,fix(xsize/screenfactor),fix(ysize/screenfactor))

  !P.MULTI = [0,2,1]
  window,1,xpos=390,ypos=530,xsize=800,ysize=340
  plot, indgen(xsize)-xsize/2, image_8bit[*,xsize/2], xrange=[-xsize/2,xsize/2], yrange=[0,256], xstyle=1, ystyle=1, thick=2.0, xtitle='pixels', ytitle='E!Imoon!N', title='pixel values along Moon''s equator', charsize=1.4, charthick=1.2
  plot, alog10(hist+0.000001), xrange=[0,256], yrange=[0,4.5], xstyle=1, ystyle=1, thick=2.0, xtitle='pixel value', ytitle='log(number of pixels)', title='histogram for pixel values', charsize=1.4, charthick=1.2

endif


END
