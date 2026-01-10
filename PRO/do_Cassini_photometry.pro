PRO flux_annulus,im_in,x,y,radius_outer,radius_inner,star_flux,sky
im=im_in
annulus_area=!pi*(radius_outer^2-radius_inner^2)
l=size(im,/dimensions)
sum1=0.0d0
sum2=0.0d0
for i=0,l(0)-1,1 do begin
for j=0,l(1)-1,1 do begin
r2=(x-i)^2+(y-j)^2
if (r2 le radius_outer^2) then sum1=sum1+im(i,j)
if (r2 le radius_inner^2) then sum2=sum2+im(i,j)
endfor
endfor
annulus_sum=sum1-sum2
sky_flux_per_pixel=annulus_sum/annulus_area
sky=sky_flux_per_pixel*!pi*radius_inner^2
star_flux=sum2-sky
return
end

PRO get_photometry,im,value,x,y,sky
radius_outer=45.
radius_inner=20.
left=fix(x-radius_outer)
right=fix(x+radius_outer)
down=fix(y-radius_outer)
up=fix(y+radius_outer)
surface,im(left:right,down:up),charsize=2
flux_annulus,im,x,y,radius_outer,radius_inner,star_flux,sky
value=star_flux
return
end


read_jpeg,'la-sci-sn-a-portrait-of-the-earth-from-900-mil-005.jpeg',im_orig
help,im_orig
for j=0,1,1 do begin
if (j eq 0) then print,' First Earth in all three bands!'
if (j eq 1) then print,' Then Moon in all three bands!'
for i=0,2,1 do begin
if (i eq 0) then str='R'
if (i eq 1) then str='G'
if (i eq 2) then str='B'
im=reform(im_orig(i,*,*))
print,'Max in this band: ',max(im)
contour,im,/isotropic
cursor,x,y
get_photometry,im,value,x,y,sky
print,str,x,y,value,sky
endfor
endfor
end
