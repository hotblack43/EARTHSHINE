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
 ; version 1 of code to set up input for the MBP
 ; has alfa as target
 ;----------------------------------------------------
 !P.CHARSIZE=2
 common ims,observed,trialim,idealused,ideal,blackimage,whiteimage
 common errs,functionvalue,residual2BOX
 openw,63,'BIGtestandtraingsetfileforMPB.dat'
 nsets=1000
 alfamin=1.5
 alfamax=1.85
 pedmin=10.0
 pedmax=15.0
 nvector=sqrt(8^2)	; so many subimage-means to extract
 fmtstr=strcompress('('+string(fix(nvector^2))+'(f10.7,1x),1x,f10.7)',/remove_all)
	print,fmtstr
 for iset=0,nsets-1,1 do begin
 seed=fix((systime(/seconds)-long(systime(/seconds)))*1e4)
 ; generate a random alfa in the proper range
 alfa=randomu(seed)*(alfamax-alfamin)+alfamin
 ; generate a pedestal in the proper range
 pedestal=randomu(seed)*(pedmax-pedmin)+pedmin
 print,'alfa,pedestal: ',alfa,pedestal
 ; generate a random synettic image
 str='./syntheticmoon usethisidealimage.fits synthetic.fits '+string(alfa)+' 1 '+string(seed)
 spawn,str
 print,'spawned ',+str
 ; now read that image and extract the data needed
 im=readfits('synthetic.fits')
 gosubdivide,nvector,im+pedestal,vector
 printf,63,format=fmtstr,vector,alfa
 endfor
 close,63
 print,'Now subdibide that set '
 end
