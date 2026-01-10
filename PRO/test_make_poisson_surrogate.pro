FUNCTION gomakesurroagte,im
nx=512
ny=512
surr=im*0.0
for i=0,nx-1,1 do begin
for j=0,ny-1,1 do begin
pois=randomn(seed,poisson=im(i,j))
surr(i,j)=pois
endfor
endfor
return,surr
end



im=readfits('observed_image_JD2456045.8521221.fits')
for itry=1,100,1 do begin
surr=gomakesurroagte(im)
tvscl,hist_equal((surr-im)/im)
print,im(20,20)-surr(20,20)
endfor
end
