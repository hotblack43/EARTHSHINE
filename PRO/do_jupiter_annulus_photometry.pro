PRO flux_annulus,im,x,y,radius_outer,radius_inner,star_flux,sky
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

openw,44,'jupiter_photometry.dat'
bias=readfits('DAVE_BIAS.fits')
files=file_search('/media/SAMSUNG/MOONDROPBOX/JD2455769/*JUPITER*.fits',count=n)
for i=0,n-1,1 do begin
IM=readfits(files(i))-bias
x=134
y=232
get_photometry,im,value,x,y,sky
print,i,x,y,value,sky
printf,44,i,x,y,value,sky
endfor
close,44
end
