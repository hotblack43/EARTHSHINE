PRO remove_bias,image
bias=readfits('one_median_bias_frame.FIT')
image=image-bias
print,'Removed bias'
return
end

im=readfits('IMG1.FIT')
remove_bias,im
plot,total(im,2)
normaliser=mean(im(900:1100,*))
im=im/normaliser
writefits,'Right_side_flat.FIT',im
end
