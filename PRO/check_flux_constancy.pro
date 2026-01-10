!P.charsize=2.1
ifwantalignment=1
bias=readfits('./TTAURI/superbias.fits')
file='/data/pth/DATA/ANDOR/MOONDROPBOX/JD2456073/2456073.7983881MOON_V_AIR.fits.gz'
stack=readfits(file,hdummy)
stack=stack(*,*,1:99)
l=size(stack)
openw,33,'flux.dat'
sum=0.0
for i=0,l(3)-1,1 do begin
im=stack(*,*,i)-bias
printf,33,i,total(im,/double),max(smooth(im,31)),mean(im(0:20,511-20:511))
sum=sum+total(stack(*,*,i)-bias)
endfor
sum=sum/float(l(3))
close,33
data=get_data('flux.dat')
!P.MULTI=[0,1,3]
plot,title=file,xtitle='Frame #',ytitle='Total flux dev. from mean in %',data(0,*),(data(1,*)-sum)/sum*100.,xstyle=3,ystyle=3
print,'SD: ',stddev(data(1,*))/sum*100.
plot,title=file,xtitle='Frame #',ytitle='Max value in smoothed image',data(0,*),data(2,*),xstyle=3,ystyle=3
plot,title=file,xtitle='Frame #',ytitle='Mean sky counts',data(0,*),data(3,*),xstyle=3,ystyle=3
end
