PRO print_average,im,av,txt
; prints average of a sub-part of im
w=9
subim=im(373-w:363+w,297-w:297+w)
av=mean(subim)
print,'Average: ',av,' ',txt
return
end

PRO putinPoisson,im,seed
l=size(im,/dimensions)
for i=0,l(0)-1,1 do begin
for j=0,l(1)-1,1 do begin
val=im(i,j)
if (val ne 0) then im(i,j)=randomn(seed,poisson=val)
endfor
endfor
return
end

openw,33,'data.dat'
nloop=1000
ideal=readfits('target_for_noise_tests.fits')
for iloop=1,nloop,1 do begin
; get stats for ideal image
print_average,ideal,idealav,'Ideal image'
im=ideal
; add Poisson nois eusing DIL
putinPoisson,im,seed
print_average,im,poissav,'Poisson added image - IDL'
; add Poisson nois eusing Chris Flynns (modified) code
seedin=long(randomn(seed)*1e5)
spawn,'./addPoissonnoise target_for_noise_tests.fits c.fits '+string(seedin)
c=readfits('c.fits')
print_average,c,poisChris,'Poisson added image - Chris code'
printf,33,(poissav-idealav)/idealav*100.0,(poisChris-idealav)/idealav*100.0
endfor
close,33
;
data=get_data('data.dat')
id=reform(data(0,*))
cr=reform(data(1,*))
!P.CHARSIZE=1.4
!P.MULTI=[0,1,2]
histo,id,-20,20,n_elements(id)/250.,xtitle='% error',title='IDL code'
histo,cr,-20,20,n_elements(cr)/250.,xtitle='% error',title='Fortran code'
end
