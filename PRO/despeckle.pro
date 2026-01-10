PRO despeckle,image
; removes single hot pixels
l=size(image,/dimensions)
ncols=l(0)
nrows=l(1)
for i=1,ncols-2,1 do begin
for j=1,nrows-2,1 do begin
sum=image(i-1,j-1)+image(i-1,j)+image(i-1,j+1) +   image(i,j-1)+image(i,j)+image(i,j+1) +   image(i+1,j-1)+image(i+1,j)+image(i+1,j+1)
if (sum eq 1) then image(i,j)=0
endfor
endfor
return
end

