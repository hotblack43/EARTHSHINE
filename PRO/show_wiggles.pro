bias=readfits('TTAURI/superbias.fits')
npatches=4
w=15
values=fltarr(npatches)
rel_values=fltarr(npatches)
coords=[[82,323],[40,460],[311,248],[313,142]]
;im=double(readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455945/2455945.1776847MOON_V_AIR.fits.gz'))
;im=double(readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455945/2455945.0945457MOON_B_AIR.fits.gz'))
im=double(readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455945/2455945.1721207MOON_VE2_AIR.fits.gz'))
l=size(im,/dimensions)
nims=l(2)
; drop the first frame
im=im(*,*,1:nims-1)
l=size(im,/dimensions)
nims=l(2)
for k=0,nims-1,1 do im(*,*,k)=im(*,*,k)-bias
ref=avg(im,2)
refmean=mean(ref,/double)
stack=im
for iter=0,5,1 do begin
openw,33,'series.dat'
print,'Iteration: ',iter
sum=0.0
print,'mean, SD: ',mean(stack),stddev(stack)
for i=0,nims-1,1 do begin
sheet=reform(stack(*,*,i))
sheet=sheet/mean(sheet,/double)*refmean
shifts=alignoffset((sheet)^2,(ref)^2,Cor)
if (i eq 0) then newstack=shift_sub(sheet,-shifts(0),-shifts(1))
if (i gt 0) then newstack=[[[newstack]],[[shift_sub(sheet,-shifts(0),-shifts(1))]]]
sum=sum+sqrt((shifts(0)^2+shifts(1)^2)) 
for k=0,npatches-1,1 do begin
delta=shift_sub(sheet,-shifts(0),-shifts(1))-ref
values(k)=mean(delta(coords(0,k)-w:coords(0,k)+w,coords(1,k)-w:coords(1,k)+w))
rel_values(k)=mean(delta(coords(0,k)-w:coords(0,k)+w,coords(1,k)-w:coords(1,k)+w))/mean(sheet(coords(0,k)-w:coords(0,k)+w,coords(1,k)-w:coords(1,k)+w))
endfor
printf,33,format='(8(1x,f9.4))',values,rel_values
;print,format='(8(1x,f9.4))',values,rel_values
endfor
print,'Summed shifts:',sum
ref=avg(newstack,2)
;stack=newstack
close,33
endfor
; now make 'wigglefilm'
for i=0,nims-1,1 do begin
tvscl,hist_equal(stack(*,*,i)-ref)
if (i eq 0) then newstack=(stack(*,*,i)-ref)
if (i gt 0) then newstack=[[[newstack]],[[(stack(*,*,i)-ref)]]]
if (i eq 0) then newstack2=hist_equal(stack(*,*,i)-ref)
if (i gt 0) then newstack2=[[[newstack2]],[[hist_equal(stack(*,*,i)-ref)]]]
endfor
writefits,'residualimages.fits',newstack
writefits,'histequal_residualimages.fits',newstack2
end
