im=(readfits('/home/pth/SCIENCEPROJECTS/EARTHSHINE/simulated_observed_image_20.fit'))
im=long(im)
;
shannon_entropy,im,h
print,'H: ',h
end
