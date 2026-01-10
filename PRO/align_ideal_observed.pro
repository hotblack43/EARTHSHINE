ideal=readfits('OUTPUT/IDEAL/ideal_LunarImg_0000.fit')
observed=readfits('/media/SAMSUNG/MOONDROPBOX/JD2455769/2455769.0935239MOON_TAU_TAURI.fits')
bias=readfits('DAVE_BIAS.fits')
observed=observed-bias
ideal=reverse(ideal,1)
shifts=alignoffset(ideal,observed,corr)
print,shifts
ideal=shift(ideal,-shifts(0),-shifts(1))*1e3
ratio=observed/ideal
print,mean(ratio,/NaN)
contour,ratio,/isotropic,/cell_fill
surface,ratio,charsize=2,/zlog
end

