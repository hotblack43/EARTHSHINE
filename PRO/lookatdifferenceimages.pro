FUNCTION super_duper_align,imethod,im,ref,corr
if (imethod eq 0) then deltas=alignoffset((im),(ref), cor)
if (imethod eq 1) then deltas=alignoffset(sqrt(im,/double),sqrt(ref,/double), cor)
if (imethod eq 2) then deltas=alignoffset((im^2),(ref^2), cor)
if (imethod eq 3) then deltas=alignoffset(alog10(im,/double),alog10(ref,/double), cor)
if (imethod eq 4) then deltas=alignoffset(hist_equal(im),hist_equal(ref), cor)
return,deltas
end



openw,44,'results_various_alignmethods.dat'
for imethod=0,3,1 do begin
im=readfits('~/MOONDROPBOX/JD2456104/2456104.7882003MOON_V_AIR.fits.gz')
reference=avg(im,2)
writefits,'ref_0.fits',reference
print,'average reference image formed ...'
for iter=0,8,1 do begin
print,'Iteration # ',iter
tvscl,hist_equal(reference)
sumdeltassq=0.0
sumresids=0.0
for k=0,99,1 do begin
delta= super_duper_align(imethod,im(*,*,k), reference, corr)
im(*,*,k)=shift_sub(im(*,*,k),-delta(0),-delta(1))
sumdeltassq=sumdeltassq+(delta(0)^2+delta(1)^2)
sumresids=total((reference-im(*,*,k))^2)
endfor	; end loop ove rimages
reference=avg(im,2)
writefits,strcompress('ref_'+string(iter,format='(i2)')+'.fits',/remove_all),reference
print,sumdeltassq,' SD/MEAN: ',stddev(im)/mean(im),sumresids
printf,44,imethod,iter,sumdeltassq,stddev(im)/mean(im),sumresids
endfor	; end iter loop
endfor	; end imethod loop
close,44
end
