 PRO gosubdivide,nvector,im,vector
 l=size(im,/dimensions)
 vector=dblarr(nvector*nvector)
 bl=l(0)/float(nvector)
 ic=0
 tot=total(im,/double)
 for iim=0,nvector-1,1 do begin
 for jim=0,nvector-1,1 do begin
 subim=im(bl*iim:bl*(iim+1)-1,bl*jim:bl*(jim+1)-1)
 ;print,bl*iim,bl*(iim+1)-1,bl*jim,bl*(jim+1)-1
 vector(ic)=mean(subim)/tot*1e5
 ic=ic+1
 endfor
 endfor
 return
end
 
 ;----------------------------------------------------
 ; Code to generate 'random synthetic observed-like' images
 ; in order to check if flux is conserved
 ;----------------------------------------------------
 !P.CHARSIZE=2
 common ims,observed,trialim,idealused,ideal,blackimage,whiteimage
 common errs,functionvalue,residual2BOX
 openw,63,'fluxes.dat'
 nsets=1000
 alfamin=1.5
 alfamax=1.85
 pedmin=0.0
 pedmax=.001
 albedomin=0.1
 albedomax=0.9
 JDmin=2455900.0d0
 JDmax=2455932.0d0
 nvector=sqrt(8^2)	; so many subimage-means to extract
 header=' alfa, ped, SSA, JD'
 for k=nvector^2,1,-1 do header=strcompress('V'+string(fix(k))+',',/remove_all)+header
 for iset=0,nsets-1,1 do begin
 seed=fix((systime(/seconds)-long(systime(/seconds)))*1e4)
 ; generate a random JD in the proper range
 JD=randomu(seed)*(JDmax-JDmin)+JDmin
 ; generate a random alfa in the proper range
 alfa=randomu(seed)*(alfamax-alfamin)+alfamin
 ; generate a pedestal in the proper range
 pedestal=randomu(seed)*(pedmax-pedmin)+pedmin
 ; set up a random albedo
 SSA=randomu(seed)*(albedomax-albedomin)+albedomin
 print,'alfa,pedestal,albedo: ',alfa,pedestal,SSA
 ; run eshine_special
 spawn,'./make_a_synthetic_model_of_three_albedos.scr '+string(SSA)+' '+string(JD)
 whiteimage=readfits('veryspcialimageSSA1p000.fits')
 blackimage=readfits('veryspcialimageSSA0p000.fits')
 ; generate a synthetic ideal iamge
 ideal=(whiteimage*SSA+blackimage*(1.-SSA))
 writefits,'usethisidealimage.fits',ideal
 ; get the fluxin that image
 fluxoriginal=total(ideal,/double)
 ; now genrate a noisy version of that image
 str='./justconvolve usethisidealimage.fits out.fits '+string(alfa)
 spawn,str
 print,'spawned ',+str
 ; now read that image and extract the data needed
 im=readfits('out.fits')
 ; get the flux in that version
 fluxlater=total(im,/double)
 fmtstr='(4(1x,f20.5))'
 printf,63,format=fmtstr,alfa,SSA,fluxoriginal,fluxlater
 print,format=fmtstr,alfa,SSA,fluxoriginal,fluxlater
 endfor
 close,63
 end
