PRO do_postpp,input_image,psf,parameters,ideal_image,designated_area_corners,cleaned_image
return
end

PRO go_minimize,input_image,psf,parameters,ideal_image,designated_area_corners,cleaned_image
return
end

PRO get_psf,psf,parameters
return
end

PRO get_ideal_image,ideal_image
common imin,input_image2
common ideal,cutoff
ideal_image=(input_image2 gt cutoff*max(input_image2))*input_image2
return
end

PRO get_input_image,input_image
common imin,input_image2
input_image=readfits(imagepath+'sydney_2x2.fit')
input_image2=input_image
return
end

;===========================================================
;
; MAIN PROGRAMM:  remove_scattered_light_NEW_v1.pro
;
;===========================================================
; Purpose: Will remove scattered light in an image, given the
; PSF, using designated areas of the image to minimize on.
;===========================================================
; Method: Fits a best model by using forward modelling from 
; an assumed ideal image that is convolved by a parametrized 
; PSF and compared to th einput image. Minimization in the 
; 'designated area' continues until a zero mean 
; flux is found there.
;===========================================================
; common blocks
common ideal,cutoff
common paths,imagepath
;-----------------------------------------------------------
; setting parameters
cutoff=0.25	; to make the idela image copy original 
                ; imag0e but ignore all pixels below 25% of max value
imagepath='ANDREW/'	; on Linux system
;-----------------------------------------------------------
;..... get the image that is to be treated
get_input_image,input_image
;-----------------------------------------------------------
; describe the 'designated area' by the corner coordinates
low=10
high=100
left=2
right=73
designated_area_corners=[low,high,left,right]
;-----------------------------------------------------------
;..... get the image that is assumed to be ideal
; note: this may be the input image with a floor cutoff - then 
; only the bright pixels in the image contribute to the scattered light
; but in general it could be any image, e.g. form the lunar simualtor.
get_ideal_image,ideal_image
;-----------------------------------------------------------
; get the PSF
get_psf,psf,parameters
;-----------------------------------------------------------
; call the minimization routine, take everything along
go_minimize,input_image,psf,parameters,ideal_image,designated_area_corners,cleaned_image
;-----------------------------------------------------------
; do various post-processing
do_postpp,input_image,psf,parameters,ideal_image,designated_area_corners,cleaned_image
end

