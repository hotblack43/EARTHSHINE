FUNCTION moonresidual_CIE, X
common moonres,im1,im2,im3
common uselater,im4,difference
common skybias,bias
l=size(im1,/dimensions)
factor=abs(x(0))
scale=x(1)
bias=x(2)
ideal=im1
observed_image=im2
outside=im3
; Step 2 Generate a current guess for the PDF
get_pdf_CIE,l,pdf,scale
; Step 3 Fold the ideal image with the PDF
trial_image=fft(fft(ideal,-1,/double)*fft(pdf,-1,/double),1,/double)
trial_image=double(sqrt(trial_image*conj(trial_image)))
;print,mean(observed_image)/mean(trial_image)
; Step 4 Subtract the folded image from observed_image
difference=observed_image-trial_image*abs(factor)
err= total(abs(difference*outside),/double)
print,'RMSE=',err,'scale=',scale,'factor=',factor,'bias=',bias
dummy=difference*outside
plot,dummy(*,l(1)/2.),charsize=2
im4=trial_image*abs(factor)
RETURN, err
END
