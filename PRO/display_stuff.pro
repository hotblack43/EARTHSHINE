
PRO display_stuff,imin2,im4,observed_image,cleaned_image,difference
common circleSTUFF,circle,radius,moon_coords
window,1,title='Cleaned-up image'
tvscl,cleaned_image
window,2,title='Scattered light image'
tvscl,im4
window,3,title='Observed image'
tvscl,observed_image
window,4,title='Observed - Scattered'
tvscl,difference
window,5,title='Slice in residuals'
plot,difference(*,moon_coords(1)/2.),charsize=2,yrange=[-10,30]
return
end
