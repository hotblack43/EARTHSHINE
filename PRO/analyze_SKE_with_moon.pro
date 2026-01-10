path='/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455641/'
dark=readfits(path+'meanhalfmedian_dark.fits')
orig_im=readfits(path+'2455641.6380796Moon-CoAdd-SKECoverHalf.fits')
l=size(orig_im,/dimensions)
nims=l(2)
for i=0,nims-1,1 do begin
orig_im(*,*,i)=orig_im(*,*,i)-dark
if (i eq nims-1) then plot_io,orig_im(*,257,i),$
yrange=[1,1e5],ystyle=1,xstyle=1,charsize=2,$
title='Moon, SKE to left of 250'
print,i,mean(orig_im(0:20,*,i))
endfor
meanim=avg(orig_im,2)
writefits,'meanim_Moon_SKE.fits',meanim
oplot,meanim(*,257),color=fsc_color('red'),thick=3
oplot,shift(reverse(meanim(*,257)),150),color=fsc_color('blue'),thick=3
plots,[253,253],[1,1e5],linestyle=2
plots,[409,409],[1,1e5],linestyle=2
; save the rpofiles
openw,3,'SKE_profile.dat'
for i=0,511,1 do begin
if (i le 253) then printf,3,abs(i-253),meanim(i,257)
endfor
close,3
openw,3,'SKY_profile.dat'
for i=0,511,1 do begin
if (i ge 409) then printf,3,abs(i-409),meanim(i,257)
endfor
close,3
end
