im=long(readfits('Stars_13frame_r1.fits'))
l=size(im,/dimensions)
n=l(2)
refim=reform(im(*,*,0))
for i=1,n-1,1 do begin
diff=reform(im(*,*,i))-refim
writefits,strcompress('diffim_'+string(i)+'.fits',/remove_all),diff
print,mean(diff)
endfor
end
