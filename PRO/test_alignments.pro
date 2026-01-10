im=readfits('synth_stack_2456073.7781942.fits')
l=size(im,/dimension)
n=l(2)
refim=avg(im,2)
sum1=0.0
sum2=0.0
for i=0,n-1,1 do begin
im1=refim
im2=im(*,*,i)
idx=where(im1 lt 0.5*max(im1))
im1b=im1
im1b(idx)=0.0
im2b=im2
im2b(idx)=0.0
shifts1=alignoffset(im1,im2)
shifts2=alignoffset(im1b,im2b)
print,shifts1,shifts2
sum1=sum1+shifts1^2
sum2=sum2+shifts2^2
endfor
print,'SSS 1: ',sum1
print,'SSS 2: ',sum2
end
