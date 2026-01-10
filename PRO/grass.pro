;read_jpeg,'Crabgrass.JPG',im
im=readfits('doghouse.jpg')
help,im
im=total(im,1)
n=20
primes=prime(n*2)
primes=reform(primes,n,2)
help,primes
for i=0,n-1,1 do begin
out=shift(im,primes(i,0),primes(i,1))
writefits,strcompress('grass_image'+string(i)+'.fit',/remove_all),out
endfor

end

