FUNCTION PSF,istyle,power,p
; will modify and return the standard 1536x1536 PSF
; power	: INPUT power to raise PSF to
; p	: INPUT parameters for r_lim and XYZ (not used)
;-----------------------------------------------------------
; istyle=1	: the old style - raise whole PSF tosome power
; istyle=2	: rause just winds outside r_lim to power
 common PSFstuff,iflag,PSForig
 if (iflag ne 314) then  begin
     PSForig=readfits('./FORCRAY/psf_1536.fits')
     iflag=314
     endif
 if (istyle eq 1) then begin
     ; just riase original PSF to the power
     PSFf=PSForig^power
     endif
 if (istyle eq 2) then begin
     PSFf=PSForig
; keep core as is inside r_lim
; raise wings outside to power
     r_lim=p(0)	; in units of pixels
     PSFlim=median([PSForig(fix(r_lim+1)),PSForig(fix(r_lim+1))])
     PSFf=PSFf/PSFlim
     print,'At r_lim=',r_lim,' the PSForig is:',PSFlim
;    idx=where(PSForig gt PSFlim)
     jdx=where(PSForig le PSFlim)
     PSFf(jdx)=PSFf(jdx)^power
     endif
 ; normalize
 PSFf=PSFf/total(PSFf,/DOUBLE)
 return,PSFf
 end
