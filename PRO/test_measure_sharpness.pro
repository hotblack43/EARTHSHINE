PRO getsharpness,im_in
im=im_in/total(im_in,/double)
s=abs(im-shift(im,1,1))
s=rebin(s,512L*512L)
s2=s(sort(s))
n=n_elements(s2)
print,'Sharpness: ',stddev(s)
return
end




dull=readfits('dull.fits')
sharp=readfits('sharp.fits')
getsharpness,dull
getsharpness,sharp
end
