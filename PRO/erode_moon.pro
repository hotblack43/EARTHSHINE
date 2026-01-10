file='Moon_simulated_36_DOUBLE.FIT'
im_orig=readfits(file)
im=sobel(im_orig)
; Threshold and make binary image:  
B = im GE 0.1*max(im)
  
; Create the shape operator:  
S = REPLICATE(1, 3, 3)  
  
; "Opening" operator:  
C = DILATE(ERODE(B, S), S)
;
contour,c,/isotropic,xstyle=1,ystyle=1
end

