PRO remove_sky,im
l=size(im,/dimensions)
print,'In remove_sky l is:',l
sky=im(0:l(0)/10,0:l(1)/10)
print,'Sky is:',mean(sky)
im=im-mean(sky)*0.95
return
end
