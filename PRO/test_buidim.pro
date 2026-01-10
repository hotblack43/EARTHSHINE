


PRO buildim,im1,im2,obs,im1replaced,im2replaced
; will replace the BS in im1 and im2 with the obs BS
idx=where(obs gt max(obs)/100.)
im1replaced=im1
im2replaced=im2
im1replaced(idx)=obs(idx)/total(obs(idx),/double)*total(im1(idx),/double)
im2replaced(idx)=obs(idx)/total(obs(idx),/double)*total(im2(idx),/double)
return
end







im1=readfits('im1.fits',h1)
im2=readfits('im2.fits',h2)
help,h1,h2
stop
obs=readfits('HGL/observed_image_JD2455945.1776847.fits')
buildim,im1,im2,obs,im1replaced,im2replaced
!P.MULTI=[0,1,1]
plot,im2(*,256),/ylog,yrange=[1e-2,1e3]
oplot,im2replaced(*,256),color=fsc_color('red')
end
