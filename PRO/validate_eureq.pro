FUNCTION ssa,v
; 17	0.028	"SSA = 67,562972597077*V19 + 1,92095398460194*V37 + 26,6607078492265*V20*V27 - 70,1934264504121*V49"

ssa = 67.562972597077d0*V(18) + 1.92095398460194d0*V(36) + 26.6607078492265d0*V(19)*V(26) - 70.1934264504121d0*V(48)
return,ssa
end

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
 ; This code will use a formula determined by Eureqa for the SSA
 ; on a series of new synethtic, noisy images in order to validate said formula.
 ;----------------------------------------------------
 !P.CHARSIZE=2
 common ims,observed,trialim,idealused,ideal,blackimage,whiteimage
 common errs,functionvalue,residual2BOX
 whiteimage=readfits('veryspcialimageSSA1p000.fit')
 blackimage=readfits('veryspcialimageSSA0p000.fit')
 openw,63,'validation.dat'
 nsets=100
 ; the below limits must be the same as for which the formula was developped!
alfamin=1.4
 alfamax=1.9
 pedmin=0.0
 pedmax=50.0
 albedomin=0.1
 albedomax=0.9
 nvector=sqrt(8^2)      ; so many subimage-means to extract

 ;
 for iset=0,nsets-1,1 do begin
 seed=fix((systime(/seconds)-long(systime(/seconds)))*1e4)
 ; generate a random alfa in the proper range
 alfa=randomu(seed)*(alfamax-alfamin)+alfamin
 ; generate a pedestal in the proper range
 pedestal=randomu(seed)*(pedmax-pedmin)+pedmin
 ; set up a random albedo
 SSA=randomu(seed)*(albedomax-albedomin)+albedomin
 print,'alfa,pedestal,albedo: ',alfa,pedestal,SSA
 ; generate a synthetic ideal iamge
 ideal=(whiteimage*SSA+blackimage*(1.-SSA))
 writefits,'usethisidealimage.fits',ideal
 ; mow genrate a noisy version of that image
 str='./syntheticmoon usethisidealimage.fits synthetic.fits '+string(alfa)+' 1 '+string(seed(0))
 spawn,str
 print,'spawned ',+str
 ; now read that image and extract the data needed
 im=readfits('synthetic.fits')
 gosubdivide,nvector,im+pedestal,vector
 ; now us ethe formula on the vector to find the SSA
 albedoout=ssa(vector)
 print,iset,SSA,albedoout,(albedoout-SSA)/SSA*100.
 printf,63,iset,SSA,albedoout,(albedoout-SSA)/SSA*100.
 endfor
 close,63
 end

