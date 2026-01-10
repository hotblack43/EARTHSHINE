!P.MULTI=[0,1,2]
im1=readfits('JAC/bestdifference.fits')
im2=readfits('JACOBTEST/output.fits')
im3=readfits('JACOBTEST/output2.fits')
diff=(im1-im2)/im1*100.
plot,xstyle=3,total(diff(*,240:260),2),xtitle='Column',ytitle='% difference',title='IDL and Cray try 1',charsize=2
diff=(im1-im3)/im1*100.
plot,xstyle=3,total(diff(*,240:260),2),xtitle='Column',ytitle='% difference',title='IDL and Cray try 2',charsize=2
;plot,total(median(diff,3),1),xtitle='Column',ytitle='% difference',title='IDL and Cray try 1',charsize=2
end

