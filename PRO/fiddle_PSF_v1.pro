PRO getcircledprofile,psf,radius,profile
idx=where(psf eq max(psf))
coords=array_indices(psf,idx)
x0=coords(0)
y0=coords(1)
openw,33,'stuff.dat'
for i=0,511,1 do begin
for j=0,511,1 do begin
r=sqrt((i-x0)^2+(j-y0)^2)
printf,33,r,psf(i,j)
endfor
endfor
close,33
data=get_data('stuff.dat')
r=reform(data(0,*))
p=reform(data(1,*))
for rr=0,255,1 do begin
idx=where(r ge rr and r lt rr+1)
print,median(r(idx)),median(p(idx))
if (rr eq 0) then radius=median(r(idx))
if (rr eq 0) then profile=median(p(idx))
if (rr gt 0) then radius=[radius,median(r(idx))]
if (rr gt 0) then profile=[profile,median(p(idx))]
endfor
return
end

PRO getthedeconvolvedPSF,obs_in,ideal_in,PSF
obs=obs_in/total(obs_in)
ideal=ideal_in/total(ideal_in)
PSF=FFT(FFT(obs,-1)/FFT(ideal,-1),1)
PSF=float(sqrt(PSF*conj(PSF)))
return
end

cube=readfits('/data/pth/CUBES/cube_2456104.8770674_B_.fits')
obs=reform(cube(*,*,0))
ideal=reform(cube(*,*,4))
mask=ideal gt 1e-1
;tvscl,obs*mask
writefits,'try_masked_obs.fits',obs*mask
writefits,'try_idealused.fits',ideal
writefits,'try_obsused.fits',obs
;
!P.MULTI=[0,2,2]
!P.CHARSIZE=1.2
!P.CHARTHICK=2
getthedeconvolvedPSF,obs,ideal,PSF1
writefits,'PSF_obs_ideal.fits',PSF1
getthedeconvolvedPSF,obs,obs*mask,PSF2
writefits,'PSF_obs_maskedobs.fits',PSF2
surface,/zlog,shift(rebin(PSF1,32,32),16,16),title='ideal used as ideal'
surface,/zlog,shift(rebin(PSF2,32,32),16,16),title='obs*mask used as ideal'
deconvolved_obs=fft(fft(obs,-1)/fft(PSF1,-1),1)
deconvolved_obs=float(sqrt(deconvolved_obs*conj(deconvolved_obs)))
writefits,'obs_deconvolved_with_PSF1.fits',deconvolved_obs
deconvolved_obs=fft(fft(obs,-1)/fft(PSF2,-1),1)
deconvolved_obs=float(sqrt(deconvolved_obs*conj(deconvolved_obs)))
writefits,'obs_deconvolved_with_PSF2.fits',deconvolved_obs
;
getcircledprofile,psf1,radius1,profile1
getcircledprofile,psf2,radius2,profile2
plot_oo,radius1,profile1,xrange=[0.1,300],xtitle='Radius [pixels]',ytitle='PSF, rotationally averaged',title='Black: ideal - Red: masked observation'
oplot,radius2,profile2,color=fsc_color('red')
; use Hanningw indow
getthedeconvolvedPSF,obs*hanning(512,512),ideal*hanning(512,512),PSF1b
getthedeconvolvedPSF,obs*hanning(512,512),obs*mask*hanning(512,512),PSF2b
getcircledprofile,psf1b,radius1,profile1
getcircledprofile,psf2b,radius2,profile2
plot_oo,yrange=[10,1e5],radius1,profile1,xrange=[0.1,300],xtitle='Radius [pixels]',ytitle='PSF, rotationally averaged',title='With Hanning window'
oplot,radius2,profile2,color=fsc_color('red')
deconvolved_obs=fft(fft(obs*hanning(512,512),-1)/fft(PSF1b,-1),1)
deconvolved_obs=float(sqrt(deconvolved_obs*conj(deconvolved_obs)))
writefits,'obs_timesHanning_deconvolved_with_PSF1b.fits',deconvolved_obs
end

