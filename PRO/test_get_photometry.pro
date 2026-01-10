PRO flux_annulus,im,x,y,radius_outer,radius_inner,star_flux
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
star_flux=sum2-sky_flux_per_pixel*!pi*radius_inner^2
return
end

PRO get_photometry,im,value,x,y
common flags,iflag
if (iflag ne 314) then begin
contour,im
cursor,x,y
endif
radius_outer=25.
radius_inner=10.
left=fix(x-radius_outer)
right=fix(x+radius_outer)
down=fix(y-radius_outer)
up=fix(y+radius_outer)
surface,im(left:right,down:up),charsize=2
flux_annulus,im,x,y,radius_outer,radius_inner,star_flux
value=star_flux
return
end

common flags,iflag
openw,44,'photometry.dat'
iflag=0
IM=readfits('C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\data 7.fit')
get_photometry,im,value,x,y
print,0,x,y,value
iflag=315
files=file_search('C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\data*.fit',count=n)
for i=0,n-3,1 do begin
IM=readfits(files(i))
get_photometry,im,value,x,y
print,i,x,y,value
printf,44,i,x,y,value
endfor
close,44
end