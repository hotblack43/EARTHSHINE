FUNCTION myfunct, X, Y, P
;-----------------------------------------------------
; function used by MPFIT2DFUN - designates the value to be minimized
; For use with 'test_Chae.pro'
; Peter Thejll October 8, 2008
;-----------------------------------------------------
; X,Y	: (INPUT) here, really dummy arrays giving the coordinates of each pixel in the images
; P	: (INPUT) the value of the parameters to be optimized
; myfunct	: (OUTPUT) the value to be minimized (a sum over pixels om
;		 the rim of the circle in the difference image
;-----------------------------------------------------
;

common alignstuff,i
common images,im,reference,maxval,circle
;..........
shifted_im=shift_sub(im,-p(0),-p(1))
diff = shifted_im-reference
; show the image
tvscl,congrid(diff^2,500,500)
;; collect info on the edge of the Moon:
roi=diff(where(circle eq maxval))
number=total(abs(roi))
;number=total(diff^2)
return, number
    END
