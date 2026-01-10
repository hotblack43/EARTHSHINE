im1=float(readfits('sydney_2x2.fit'))+100
im2=float(readfits('sydney_2x2_noglow.fit'))+100
;im2=float(readfits('sydney_2x2_noglow_r2.fit'))
dark=float(readfits('sydneydark.fit'))
im1=float(im1-dark)
im2=float(im2-dark)
diff=im1-im2
pct1=smooth(diff/im1*100.0,3)
pct2=smooth(diff/im2*100.0,3)
!P.MULTI=[0,1,2]
contour,pct1,levels=indgen(11),/isotropic,xstyle=1,ystyle=1,/cell_fill,charsize=2,title='Residual Moonglow in %'
contour,pct1,levels=indgen(11),c_labels=[0,0,0,0,0,0,1,1,1,1,0],/overplot,C_COLORS=INDGEN(11)*0,c_charsize=3,c_charthick=2
contour,pct2,levels=indgen(11),/isotropic,xstyle=1,ystyle=1,/cell_fill,charsize=2,title='Residual Moonglow in %'
contour,pct2,levels=indgen(11),c_labels=[0,0,0,0,0,0,1,1,1,1,0],/overplot,C_COLORS=INDGEN(11)*0,c_charsize=3,c_charthick=2

;surface,smooth(pct*100.0,3),charsize=2,min=-1,max=100
end
