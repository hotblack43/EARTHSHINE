imname1='/data/pth/DARKCURRENTREDUCED/SELECTED_1/2456045.8499006MOON_VE1_AIR_DCR.fits'
imname2='/data/pth/DARKCURRENTREDUCED/SELECTED_1/2456045.8521221MOON_VE2_AIR_DCR.fits'

im1=readfits(imname1)
im1=im1/total(im1,/double)
im2=readfits(imname2)
im2=im2/total(im2,/double)
;
shifts=alignoffset(im1,im2)
im1=shift_sub(im1,-shifts(0),-shifts(1))
diff=(im2-im1)
diffpct=(im2-im1)/im2*100.
writefits,'pctdiff.fits',diffpct
writefits,'difff.fits',diff
end
