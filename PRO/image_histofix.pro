path='C:\Documents and Settings\Peter Thejll\My Documents\Panoramas\'
file=path+'Glava_house_July2003_panorama.jpg'

read_jpeg,file,imRGB
imR=reform(imRGB(0,*,*))
imG=reform(imRGB(1,*,*))
imB=reform(imRGB(2,*,*))
R=total(imR) & G=total(imG) & B=total(imB)
print,'R-G:',r-g,'G-B:',g-b,'r-b:',r-b
;---get reference picture
imref=path+'Trysunda_panorama_2005.jpg'
read_jpeg,imref,ref
refR=reform(ref(0,*,*))
refG=reform(ref(1,*,*))
refB=reform(ref(2,*,*))
;...fix each color
fixR=histomatch(imR,refR)
fixG=histomatch(imG,refG)
fixB=histomatch(imB,refB)
;-scale each color to old total
fixR=fixR/total(fixR)*R
fixG=fixG/total(fixG)*G
fixB=fixB/total(fixB)*B
; putthe new colors together
final=imRGB*0.0
final(0,*,*)=fixR
final(1,*,*)=fixG
final(2,*,*)=fixB

print,'R-G:',r-g,'G-B:',g-b,'r-b:',r-b
write_bmp,path+'test.bmp',final
end