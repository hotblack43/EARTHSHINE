PRO goaddpoisson,im,n
 writefits,'input_2_goaddpoisson.fits',im
; Draws Poisson-distributed numbers from the 
; distribution that follows from adding n such numbers
factor=sqrt(n)
for i=0,511,1 do begin
for j=0,511,1 do begin
arg=n*im(i,j)+n
val=im(i,j)
rnd=max([randomu(seed,poisson=arg)/float(n)-1,0])
im(i,j)=rnd
print,arg,rnd,val
endfor
endfor
 writefits,'output_goaddpoisson.fits',im
return
end

im=readfits('input_goaddpoisson.fits')
goaddpoisson,im,100
end
