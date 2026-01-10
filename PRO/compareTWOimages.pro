


im1=readfits('image1.fits')
im2=readfits('image2.fits')
diff=(im1-im2)/(0.5*(im1+im2))*100.
set_plot,'ps'
device,filename='compared.ps'
plot,diff(*,256),ystyle=3,xtitle='Column #',ytitle='% difference'
device,/close
print,'inspect compared.ps'
end
