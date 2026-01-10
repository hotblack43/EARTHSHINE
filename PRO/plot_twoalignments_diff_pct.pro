!P.thick=2
!x.thick=2
!y.thick=2
im=readfits('twoalignments_diff_pct.fits')
plot,im(*,256)*2.,charsize=2,ytitle='relative diff. in %',xstyle=3,xtitle='Column #'
plots,[!x.crange],[-0.1,-0.1],linestyle=2
plots,[!x.crange],[0.1,0.1],linestyle=2  
plots,[55,55],[!Y.crange],linestyle=1
end
