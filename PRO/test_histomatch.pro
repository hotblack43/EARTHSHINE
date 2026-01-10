; define image to scale
im1=readfits('/home/pth/SCIENCEPROJECTS/moon/ANDREW/andrews.sydney_2x2_noglow.fit')
; define image to match
;im1=readfits('/home/pth/SCIENCEPROJECTS/moon/ANDREW/stacked_2_349.FIT')
read_jpeg,'/home/pth/IMAGES/Argentière_Jean_Gilleta.jpg',im2,/grayscale
im2=dist(100,100)^2
im2=bytscl(im2)
im1=bytscl(im1)
;................
image=im1
image_to_match_its_PDF=im2
;.................
output_image = HistoMatch(image, image_to_match_its_PDF)
im3=output_image
;........................
;
minv=min([min(im1),min(im2)])
maxv=max([max(im1),max(im2)])
bins=(maxv-minv)/255.
t=findgen(256)*bins+minv

hist_to_match			=histogram(im1,min=minv,max=maxv,binsize=bins)
h1=hist_to_match
;hist_to_match=hist_to_match/float(total(hist_to_match))

hist_image_to_modify		=histogram(im2,min=minv,max=maxv,binsize=bins)
h2=hist_image_to_modify
;hist_image_to_modify=hist_image_to_modify/float(total(hist_image_to_modify))

hist_of_transformed_image	=histogram(output_image,min=minv,max=maxv,binsize=bins)
h3=hist_of_transformed_image
;hist_of_transformed_image=hist_of_transformed_image/float(total(hist_of_transformed_image))
;
;window,3,title='Histograms'
plot,t,hist_to_match,thick=3,title='thick: target Hist, thin: Hist to modify, Symbols: Hist of transformed image',yrange=[0,max([hist_image_to_modify,hist_of_transformed_image,hist_to_match])],xrange=[0,250],psym=10
oplot,t,hist_image_to_modify,psym=10
oplot,t,hist_of_transformed_image,psym=-7,linestyle=3
;
;window,0,title='image_to_match_its_PDF'
;tvscl,image_to_match_its_PDF
;window,1,title='image to transform'
;tvscl,image
;window,2,title='transformed image'
;tvscl,output_image
end
