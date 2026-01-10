PRO	put_poisson,im
l=size(im,/dimensions)

for i=0,l(0)-1,1 do begin
for j=0,l(1)-1,1 do begin
if (im(i,j) gt 0) then im(i,j)=randomn(seed,poisson=im(i,j))
endfor
endfor
kdx=where(im lt 0)
if (kdx(0) ne -1) then im(kdx)=0.0
return
end
