im=readfits('mask.fits')
; Create the shape operator:  
S = REPLICATE(1, 3, 3)  
  
; "Opening" operator:  
C = DILATE(ERODE(im, S), S)  
  
; Show the result:  
TVSCL, C
end
