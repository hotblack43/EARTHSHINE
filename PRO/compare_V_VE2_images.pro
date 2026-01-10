bias=readfits('DAVE_BIAS.fits')
V=readfits('summed_V.fits')-bias
VE2=readfits('summed_VE2.fits')-bias
print,'V:',total(V)
print,'VE2:',total(VE2)
contour,alog10(v),/isotropic,/cell_fill,nlevels=101,xstyle=3,ystyle=3,title='V'
cursor,a,b
plots,[!x.crange],[b,b]
plots,[a,a],[!y.crange]
Getannul, V, a, b, 15, 30, data,idx
print,mean(data),median(data)
v=v-mean(data)
print,'V:',total(V)
contour,alog10(v),/isotropic,/cell_fill,nlevels=101,xstyle=3,ystyle=3,title='V'
writefits,'V_sky_removed.fits',v
; VE2
contour,alog10(ve2),/isotropic,/cell_fill,nlevels=101,xstyle=3,ystyle=3,title='V'
cursor,a,b
plots,[!x.crange],[b,b]
plots,[a,a],[!y.crange]
Getannul, Ve2, a, b, 15, 30, data,idx
print,mean(data),median(data)
ve2=ve2-mean(data)
print,'VE2:',total(VE2)
contour,alog10(ve2),/isotropic,/cell_fill,nlevels=101,xstyle=3,ystyle=3,title='VE2'
writefits,'VE2_scaled_to_V.fits',VE2/total(VE2)*total(V)
print,'Scaled image of VE2 now saved'
end

