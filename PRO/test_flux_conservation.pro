









; Will test if the flux in a MoOON image is conserved under interpolation
im=readfits('~/2456034.1142920MOON_B_AIR_DCR.fits')+10.
shifted1=shift_sub(im,0.42d0,0.23d0)
shifted3=shift_sub(shifted1,-0.42d0,-0.23d0)
diff=(shifted3-im)/im
print,mean(abs(diff),/double)*100.,' %'
end
