PRO get_ideal_image,input_image,ideal_image
; Will generate an 'ideal image' from an observed
; image by cutting away low pixels
common ideal,cutoff
ideal_image=(input_image gt cutoff*max(input_image))*input_image
return
end

; Will generate an 'ideal' image from an observed image by
; cutting off low pixels
; The output is a file suitable for input to the removal program
;
common ideal,cutoff
cutoff=0.05
observed_image_name='padded_sydney_2x2.fit'
input_image=readfits(observed_image_name)
 get_ideal_image,input_image,ideal_image
writefits,'ideal_image_padded_sydney_2x2.fit',ideal_image
end