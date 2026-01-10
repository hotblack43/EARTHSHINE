im=readfits('median_image_CCD_sxvh9.fit')
im=im-9.381
perfect=readfits('ideal_LunarImg_0030.fit')
l=size(im,/dimensions)
rat=perfect
for i=0,l(0)-1,1 do begin
for j=0,l(1)-1,1 do begin
if (perfect(i,j) ne 0) then rat(i,j)=im(i,j)/perfect(i,j)
endfor
endfor
contour,rat
plot,rat(*,500)
print,mean(rat(200:600,500)),mean(rat(700:800,500))
end

