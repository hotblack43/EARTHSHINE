FUNCTION PSF,istyle,power,p
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
 
 ; PSF(istyle,power,pars)
 common PSFstuff,iflag,PSForig
 iflag=1
 basepower=1.6
 ic=0
 istyle=2
 r_lim=3.5
 factor=0.1
 for p_add=-0.3,0.3,0.1 do begin
     power=basepower+p_add
	parms=[r_lim,factor]
     f=PSF(istyle,power,parms)
	print,power,parms,f(1,0)
     if (ic eq 0) then plot_oo,/nodata,title='!7a!3=1.4/1.5/1.6/1.7/1.8',f(*,0),xrange=[0.9,30],xstyle=3,$
     xtitle='r [pixel]',ytitle='normalized PSF'
     if (ic gt 0) then oplot,f(*,0),color=fsc_color('orange')
     ic=ic+1
     endfor
 end
