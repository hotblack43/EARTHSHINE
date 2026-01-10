im1=readfits('refim.fits')-393.5
print,'mean of new image:',mean(im1)
im2=readfits('BMINUSVWORKAREA/2455945.1760145_B.fits')
shifts=alignoffset(im1,im2)
im1=shift_sub(im1,-shifts(0),-shifts(1))
print,'mean of std image:',mean(im2)
sp1=fft(im1,-1)
sp1=float(sqrt(sp1*conj(sp1)))
sp2=fft(im2,-1)
sp2=float(sqrt(sp2*conj(sp2)))
!P.MULTI=[0,1,2]
!P.CHARSIZE=1.7
!P.thick=3
!x.thick=2
!y.thick=2
plot,sp1(0,*),/ylog,xrange=[0,512/2],title='New image: black, STD image: red',xstyle=3,ystyle=3,xtitle='k',ytitle='Power new image'
oplot,sp2(0,*),color=fsc_color('red')
plot,sp1(0,*)/sp2(0,*),xrange=[0,512/2],xstyle=3,ystyle=3,xtitle='k',ytitle='Power ratios new/std'
;
w=40
!P.MULTI=[0,2,2]
plot,im1(48-w:48+w,292),title='Left edge'
oplot,im2(48-w:48+w,292),color=fsc_color('red')
plot,im1(342-w:342+w,292),title='Right edge'
oplot,im2(342-w:342+w,292),color=fsc_color('red')
plot,im1(198,440-w:440+w),title='Upper edge'
oplot,im2(198,440-w:440+w),color=fsc_color('red')
plot,im1(198,146-w:146+w),title='Lower edge'
oplot,im2(198,146-w:146+w),color=fsc_color('red')
end
