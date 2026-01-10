im1=readfits('KINGimages/KING_0000.fit')
im1=im1/total(im1)
im2=readfits('IDEAL/ideal_LunarImg_0000.fit')
im2=im2/total(im2)
z1=fft(im1,-1)
z1pow=z1*conj(z1)
z2=fft(im2,-1)
z2pow=z2*conj(z2)
ratio=z1pow/z2pow
!P.MULTI=[0,1,3]
surface,z1pow,/zlog,title='Convolved image power spectrum',charsize=2
surface,z2pow,/zlog,title='Clean image power spectrum',charsize=2
surface,ratio,title='Ratio of power spectra',charsize=2
!P.MULTI=[0,1,1]
contour,ratio,title='P(conv)/P(clean)',charsize=2,xstyle=1,ystyle=1,/cell_fill,nlevels=101
loadct,29
nlevels=20
levels=findgen(nlevels)/float(nlevels-1)*(1.0-0.96)+0.96
contour,ratio,levels=levels,/overplot,c_labels=indgen(nlevels)*0+1,color=255
end
