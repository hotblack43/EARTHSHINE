PRO align_images,im,reference
pshift=4
shiftstep=1
maxcorr=-1e22
for ishift=-pshift,pshift,shiftstep do begin
for jshift=-pshift,pshift,shiftstep do begin
corr=correlate(reference,shift(im,ishift,jshift))
if (corr gt maxcorr) then begin
	maxcorr=corr
	bestshift_i=ishift
	bestshift_j=jshift
endif
endfor
endfor
im=shift(im,bestshift_i,bestshift_j)
print,'Best shifts:',bestshift_i,bestshift_j
return
end


files=file_search('/home/pth/Desktop/ASTRO/ANDOR/','Vega_ANDOR_*.fits',count=n)
reference=readfits(files(0))
nsubim=100
sum=reference
for i=1,n-1,1 do begin
	im=readfits(files(i) )
    align_images,im,reference
    sum=sum+im
    contour,sum/float(n)
endfor
end
