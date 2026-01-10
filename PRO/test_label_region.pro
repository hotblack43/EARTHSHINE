image = DIST(40)  
image=randomu(seed,512,512)
image(where(image lt 0.1))=0
image(where(image ge 0.1))=1
  
; Get blob indices:  
b = LABEL_REGION(image)  
  
; Get population of each blob:  
h = HISTOGRAM(b)  
FOR i=0, N_ELEMENTS(h)-1 DO PRINT, 'Region ',i, $  
   ', Population = ', h[i]  
;
   s = Size(image, /Dimensions)
   displayImage = LonArr(s[0], s[1])
   FOR j=1,Max(b )-1 DO BEGIN
       thisRegion = Where(b EQ j, count)
       IF count EQ 0 THEN Continue
       displayImage[thisRegion] = image[thisRegion]
   ENDFOR
   TVImage, BytScl(displayImage)
idx=array_indices(b,h)
print,idx
end
