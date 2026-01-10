file1='/home/pth/IMAGES/Argentière_Jean_Gilleta.jpg'
read_jpeg,file1,im1,/grayscale
file2='/home/pth/IMAGES/chamonix_1850.jpg'
file2='/home/pth/IMAGES/Alex James.jpg'
read_jpeg,file2,im2,/grayscale
;................
image_to_match_its_PDF=im2
image=im1
;.................
output_image = HistoMatch(image, image_to_match_its_PDF)
;........................
;
t=findgen(256)
hist_to_match			=histogram(im1,min=0,max=255,binsize=1)
hist_to_match=hist_to_match/float(total(hist_to_match))

hist_image_to_modify		=histogram(im2,min=0,max=255,binsize=1)
hist_image_to_modify=hist_image_to_modify/float(total(hist_image_to_modify))

hist_of_transformed_image	=histogram(output_image,min=0,max=255,binsize=1)
hist_of_transformed_image=hist_of_transformed_image/float(total(hist_of_transformed_image))
;
;window,3,title='Histograms'
plot,t,hist_to_match,thick=3,title='thick: target Hist, thin: Hist to modify, Symbols: Hist of transformed image',yrange=[0,max([hist_image_to_modify,hist_of_transformed_image,hist_to_match])]
oplot,t,hist_image_to_modify
oplot,t,hist_of_transformed_image,psym=-7
;
;window,0,title='image_to_match_its_PDF'
;tvscl,image_to_match_its_PDF
;window,1,title='image to transform'
;tvscl,image
;window,2,title='transformed image'
;tvscl,output_image
end
