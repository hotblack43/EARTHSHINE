im1=readfits('Capella_coadded_iteration_2001.fits')
im2=readfits('Capella_coadded_iteration_2001_v2.fits')
diff1=(im1-im2)/im2*100.0

         shifts=alignoffset(im1,im2,Cor)
         im1=shift_sub(im1,-shifts(0),-shifts(1))

diff2=(im1-im2)/im2*100.0
surface,diff2,/lego
end
