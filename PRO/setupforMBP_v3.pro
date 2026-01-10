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
 ; version 3 of code to set up input for Eureqa 
 ;----------------------------------------------------
 !P.CHARSIZE=2
 common ims,observed,trialim,idealused,ideal,blackimage,whiteimage
 common errs,functionvalue,residual2BOX
 openw,63,'lotsadata.dat'
 nsets=1000
 alfamin=1.5
 alfamax=1.85
 pedmin=400.0
 pedmax=450.0
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
 ; mow genrate a noisy version of that image
 help,seed,alfa
 str='./syntheticmoon usethisidealimage.fits synthetic.fits '+string(alfa)+' 30 '+string(seed(0))
 spawn,str
 print,'spawned ',+str
 ; now read that image and extract the data needed
 im=readfits('synthetic.fits')
 gosubdivide,nvector,im+pedestal,vector
 if (iset eq 0) then begin
	printf,format='(a)',63,header
 endif
 fmtstr=strcompress('('+string(fix(nvector^2))+'(f12.7,","),2(f12.7,","),f12.7,1x,f16.7)',/remove_all)
 printf,63,format=fmtstr,vector,alfa,pedestal,SSA,JD
 print,format=fmtstr,vector,alfa,pedestal,SSA,JD
 endfor
 close,63
 print,'Now subdivide that set '
 end
