im=readfits('/data/pth/HOLD_DARKCURRENTREDUCED/2455943.1042725MOON_VE2_AIR_DCR.fits',header)
help
smeared=im*0.0d0
for irow=0,511,1 do smeared(*,irow) = total(im,2,/double)
tvscl,hist_equal(smeared)
end

