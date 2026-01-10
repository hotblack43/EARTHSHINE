basealfa=1.54
!P.CHARSIZE=1.7
ideal=readfits(/silent,'ideal_testimage_halocancellation.fits')
writefits,'imagetofold.fits',ideal
; first generate a halo image using one alfa
str='./justconvolve imagetofold.fits out.fits '+string(basealfa)
spawn,str
haloim_1=readfits(/silent,'out.fits')
; then generate a halo image using another alfa
str='./justconvolve imagetofold.fits out.fits '+string(basealfa+0.02)
spawn,str
haloim_2=readfits(/silent,'out.fits')
writefits,'sharperimage.fits',haloim_2
; look at the difference
!P.MULTI=[0,1,2]
plot_io,xstyle=3,ideal(*,256),yrange=[1e-4,1e2]
oplot,haloim_1(*,256),color=fsc_color('red')
oplot,haloim_2(*,256),color=fsc_color('blue')
;
diff=haloim_1-haloim_2
w=16
line=diff(*,256-w:256+w)/ideal(*,256-w:256+w)
plot,xstyle=3,ytitle='% error',$
avg(line,1)*100.0,$
yrange=[-6,6]
; now convolve the sharper image with successive PSF(alfa)'s and plot the diff:
ic=0
for alfa=1.8,1.7,-0.01 do begin
print,alfa
str='./justconvolve sharperimage.fits out.fits '+string(alfa)
spawn,str
newhaloim=readfits(/silent,'out.fits')
diff=haloim_1-newhaloim
line=diff(*,256-w:256+w)/ideal(*,256-w:256+w)
if (ic mod 2 eq 0) then oplot,avg(line,1)*100.0,color=fsc_color('green')
if (ic mod 2 eq 1) then oplot,avg(line,1)*100.0,color=fsc_color('red')
ic=ic+1
endfor
oplot,[!X.crange],[1,1],linestyle=2
oplot,[!X.crange],[.1,.1],linestyle=2

end

