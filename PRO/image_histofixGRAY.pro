path='C:\Documents and Settings\Peter Thejll\My Documents\Panoramas\'
file=path+'Trysunda_panorama_2005.jpg'

read_jpeg,file,imG,/grayscale
G=total(imG)
;---get reference picture
imref=path+'Glava_house_July2003_panorama.jpg'
read_jpeg,imref,refG,/grayscale
;...fix each color
fixG=histomatch(imG,refG)
write_jpeg,path+'gray.jpg',fixG
end