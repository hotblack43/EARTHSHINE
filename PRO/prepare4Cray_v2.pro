 PRO get_time,header,dectime
 ;
 idx=where(strpos(header, 'FRAME') eq 0)
 str='999'
 if (idx(0) ne -1) then str=header(idx)
 yy=fix(strmid(str,11,4))
 mm=fix(strmid(str,16,2))
 dd=fix(strmid(str,19,2))
 hh=fix(strmid(str,22,2))
 mi=fix(strmid(str,25,2))
 se=float(strmid(str,28,6))
 dectime=julday(mm,dd,yy,hh,mi,se)
 return
 end

PRO determineoffsetfactor,im,blurred,factor,offset
 ; Find the place in the image where the center of gravity lies
 ; and set up the 'force-fit patch' there.
 ;................
 ; Version 2
 ;................
 data=get_data('coords.dat')
 x0=reform(data(0,*))
 y0=reform(data(1,*))
 radius=reform(data(2,*))
 ;...............
 l=size(im,/dimensions)
 meshgrid,l(0),l(1),x,y
 cg_x=total(x*im)/total(im)   
 cg_y=total(y*im)/total(im)
 ;...............
 fittop=cg_x
 colwhere=cg_y
 fitsky=x0-radius-20              ; middle of sky force-fit patch in x 
 wid=2  ; width of patch to force image to fit in
 ;...............
 BSim=im(fittop-wid:fittop+wid,colwhere-wid:colwhere+wid)
 DSim=im(fitsky-wid:fitsky+wid,colwhere-wid:colwhere+wid)
 BSbl=blurred(fittop-wid:fittop+wid,colwhere-wid:colwhere+wid)
 DSbl=blurred(fitsky-wid:fitsky+wid,colwhere-wid:colwhere+wid)
 mnBSim=mean(BSim,/double)
 mnDSim=mean(DSim,/double)
 mnBSbl=mean(BSbl,/double)
 mnDSbl=mean(DSbl,/double)
 factor=mean((BSim-DSim)/(BSbl-DSbl),/double)
 ;factor=((mnBSim-mnDSim)/(mnBSbl-mnDSbl))
 ;factor=((mnBSim-mnDSim)/mean(blurred(fittop-wid:fittop+wid,colwhere-wid:colwhere+wid)-blurred(fitsky-wid:fitsky+wid,colwhere-wid:colwhere+wid),/double))
 ;...............
 offset=mnDSim-mnDSbl*factor
;	print,'factor, offset = ',factor,offset
 openw,49,'factor_offset_andFourTimes25.dat'
	printf,49,'factor, offset = ',factor,offset
	printf,49,'25 target BS values:',im(fittop-wid:fittop+wid,colwhere-wid:colwhere+wid)
	printf,49,'25 target DS values:',im(fitsky-wid:fitsky+wid,colwhere-wid:colwhere+wid)
	printf,49,'25 blurred BS values:',blurred(fittop-wid:fittop+wid,colwhere-wid:colwhere+wid)
	printf,49,'25 blurred DS values:',blurred(fitsky-wid:fitsky+wid,colwhere-wid:colwhere+wid)
 close,49
 ;...............
 get_lun,uu
 openw,uu,'a_b_c_wid.dat'
 printf,uu,fittop
 printf,uu,fitsky
 printf,uu,colwhere
 printf,uu,wid
 close,uu
 free_lun,uu
 return
 end
 
 ;---------------------------------------------------------------------------
 ; Code that sets up the necessary files for the Cray to run its forward model code on
 ; Version 2 - uses the center of gravity of the image to find the location of the
 ; 'force-fit patch'.
 ;---------------------------------------------------------------------------
 CPU, TPOOL_MIN_ELTS=10000, TPOOL_NTHREADS=2
 common im,viz
	viz=1
 ;---------------------------------------------------------------------------
 mask=readfits('mask.fits')	;	512x512 (allows only sky pixels)
    openw,34,'BINfiles/mask.bin' & writeu,34,mask & close,34
 observed=readfits('presentinput.fits')	; 512x512
;observed=readfits('presentinput.fits',h)	; 512x512
;get_time,h,dectime
;openw,34,'JD.dat' & printf,34,format='(f20.7)',dectime& close,34
    openw,34,'BINfiles/observed.bin' & writeu,34,observed & close,34
 ideal=readfits('ideal.fits')	; 1536x1536
    openw,34,'BINfiles/ideal.bin' & writeu,34,ideal & close,34
 PSForig=readfits('TTAURI/PSF_fromHalo_1536.fits')	; 1536x1536
 ;........................
 idealFFT=fft(ideal,-1)
 l=float(size(ideal,/dimensions))
 area=float(l(0)*l(1))
 nsteps=40
 alfamin=1.72
 alfamax=1.82
 error=fltarr(nsteps)
 alfas=findgen(nsteps)/float(nsteps)*(alfamax-alfamin)+alfamin
 a=90
 b=440
 a=0	; a and b are lefta nd right columnslimits for error evaluation
 b=250	
 a=0	; suitable settings for 'use the whole frame outside the disc'
 b=511
 ;............
 errmin=1e33
 ;........................
 for i=0,nsteps-1,1 do begin
     alfa=alfas(i)	& openw,77,'alfa.dat' & printf,77,alfa & close,77
     PSF=PSForig^alfa
     PSF=PSF/total(PSF,/double)
    openw,34,'BINfiles/PSFnorm.bin' & writeu,34,PSForig & close,34
     PSF=PSF*area
     convolved=float((fft(idealFFT*fft(PSF,-1),1)))
     ; determine factor and offset
     subim=convolved(512:2*512-1,512:2*512-1)
    openw,34,'BINfiles/convolved.bin' & writeu,34,convolved & close,34
    openw,34,'BINfiles/subim.bin' & writeu,34,subim & close,34
     determineoffsetfactor,observed,subim,factor,offset
     print,'TOTALS: ',total(observed,/double),total(subim,/double),(total(observed,/double)-total(subim,/double))/total(subim,/double)*100.,' %'
     subim=subim*factor+offset
    openw,34,'BINfiles/subim_after.bin' & writeu,34,subim & close,34
     errim=mask*(observed-subim)
    openw,34,'BINfiles/errim.bin' & writeu,34,errim & close,34
	if (viz eq 1) then begin
     plot,total(errim(*,*),2)
     oplot,[a,a],[!Y.crange],linestyle=1
     oplot,[b,b],[!Y.crange],linestyle=1
     oplot,[!X.crange],[0,0],linestyle=1
	endif
     err=total(errim(a:b,*)^2)
     error(i)=err
     print,i,alfa,err
     if (err lt errmin) then begin
         errmin=err
         bestmodel=subim
         endif
      endfor
 idx=where(error eq min(error))
 print,'Smallest error is:',error(idx(0)),' at alfa=',alfas(idx(0))
 openw,34,'bestalfa.dat' & printf,34,error(idx(0))/n_elements(where(mask eq 1)),alfas(idx(0))& close,34
 writefits,'bestmodel.fits',bestmodel
 writefits,'bestdifference.fits',(bestmodel-observed)
 end
