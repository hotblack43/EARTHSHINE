read_jpeg,'holder.jpg',im
writefits,'avg.fits',avg(im,0)
writefits,'R.fits',reform(im(0,*,*))
writefits,'G.fits',reform(im(1,*,*))
writefits,'B.fits',reform(im(2,*,*))
end
