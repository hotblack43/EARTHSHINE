@get_ims.pro	; read in this subroutine
@calculate_SSE.pro	; read in this subroutine
;============================================
; Code to align two images and report some stats
 common stuff,inputim,observed,subim,counter
 counter=0
 window,0,xsize=400,ysize=400
 for itype=1,2,1 do begin
;itype = 1
 if (itype eq 1) then str='LAMBERT'
 if (itype eq 2) then str='HAPKE'
;----------------------------------------------------------------------------
; Australia image
; descriptor_str='Andrew'
; path='OUTPUT/IDEAL/'
; modelimagename=strcompress(path+str+'_Andrewim.fit',/remove_all)
; observedimagename='./ANDREW/sydney_2x2.fit'
;----------------------------------------------------------------------------
; BBSO image
;descriptor_str='BBSO'
;modelimagename=strcompress('OUTPUT/'+str+'_LunarImg_0001.fit',/remove_all)
;observedimagename='./BBSOimages/l07jul220036.fts'
;----------------------------------------------------------------------------
; Wildey normal albedo image
;descriptor_str='WILDEY'
;modelimagename=strcompress('OUTPUT/'+str+'_wildey.fit',/remove_all)
;observedimagename='/home/pth/SCIENCEPROJECTS/LUNARALBEDO/wildey_normal_albedo_DMI_version_1.fit'
;----------------------------------------------------------------------------
; ROLO perspective image
; descriptor_str='2709'
; modelimagename=strcompress('OUTPUT/'+str+'_ROLO_June14_2000.fit',/remove_all)
; descriptor_str='2332'
; modelimagename=strcompress('OUTPUT/'+str+'_ROLO_June3_1999.fit',/remove_all)
;descriptor_str='2321'
;modelimagename=strcompress('OUTPUT/'+str+'_ROLO_May_23_1999.fit',/remove_all)
;observedimagename='/home/pth/SCIENCEPROJECTS/EARTHSHINE/TOMSTONE/'+ descriptor_str+'_ROLO.fit'
;----------------------------------------------------------------------------
descriptor_str='BYHAND'
modelimagename='good_modelin.fit'
observedimagename='good_observed.fit'
;----------------------------------------------------------------------------
;
get_ims,inputim,observed,modelimagename,observedimagename
; save for reference
	writefits,'obs.fit',observed
	writefits,'mod.fit',inputim
 inputim=double(inputim)
 observed=double(observed)
 ; remove some sort of sky background
 remove_sky,observed
 remove_sky,inputim

 l=size(observed,/dimensions)
 ; Apply various image fiddles
inputim=smooth(inputim,3,/edge_truncate)
;inputim=median(inputim,3)
;inputim=reverse(inputim,2)
; save for reference
	writefits,'reversed_inputim.fit',inputim
 ;
 ; scale, rotate and clip until it matches other one
 scale=1.1d0
 rotangle=0.
 x0=1.0d0
 y0=1.0d0
 factor=1.0d0
 ; Define the starting point:
 start_parms = [y0,x0,rotangle,scale,factor]
 if (file_test(strcompress(str+'solution.dat',/remove_all)) eq 1) then begin
     openr,34,strcompress(str+'solution.dat',/remove_all)
     readf,34,start_parms
     close,34
 endif
 ; Find best parametrs using MPFIT2DFUN method
 Nx=l(0)
 Ny=l(1)
 XR = indgen(Nx)
 YC = indgen(Ny)
 X = double(XR # (YC*0 + 1))        ;     eqn. 1
 Y = double((XR*0 + 1) # YC)        ;     eqn. 2
 err=sqrt(observed>1) ; Poisson noise ...
 ;err=inputim*0.0+1.0
 z=observed*0.0	; just a dummy value?
 ; set up the PARINFO array - indicate double-sided derivatives (best)
 parinfo = replicate({mpside:2, value:0.D, $
 fixed:0, limited:[0,0], limits:[0.D,0],step:1.0d-5}, 5)
parinfo[0].fixed = 0
parinfo[1].fixed = 0
parinfo[2].fixed = 0
parinfo[3].fixed = 0
parinfo[4].fixed = 0
; shifts in y
parinfo[0].limited(0) = 1
parinfo[0].limits(0)  = -Ny/5.
parinfo[0].limited(1) = 1
parinfo[0].limits(1)  = Ny/5.

; shifts in x
parinfo[1].limited(0) = 1
parinfo[1].limits(0)  = -Nx/5.
parinfo[1].limited(1) = 1
parinfo[1].limits(1)  = NX/5.

; rotation
parinfo[2].limited(0) = 1
parinfo[2].limits(0)  = -2
parinfo[2].limited(1) = 1
parinfo[2].limits(1)  =  8
; spatial scaling
parinfo[3].limited(0) = 1
parinfo[3].limits(0)  = 0.5
parinfo[3].limited(1) = 1
parinfo[3].limits(1)  = 2.3
; multiplyng factor
parinfo[4].limited(0) = 1
parinfo[4].limits(0)  = 0.0
parinfo[*].value = start_parms
; print out limits and startiong values
for ipar=0,4,1 do begin
print,'........................................'
print,'Paramter ',ipar,' : ', start_parms(ipar)
print,'Is limited ?',parinfo[ipar].limited(0),parinfo[ipar].limited(1)
print,'What is limit ?',parinfo[ipar].limits(0),parinfo[ipar].limits(1)
print,'Is it fixed?',parinfo[ipar].fixed
endfor
print,'........................................'
 ; print,parinfo
 results = MPFIT2DFUN('calculate_SSE', X, Y, Z, ERR, $
 PARINFO=parinfo,perror=sigs,STATUS=hej)
 ; Print the solution point:
 print,'STATUS=',hej
 PRINT, 'Solution point: ', results
 openw,34,strcompress(str+'solution.dat',/remove_all)
 printf,34,results
 close,34
 ;
 window,0,xsize=l(0),ysize=l(1),title='Observed'
 tvscl,rebin(observed,l(0),l(1))
 window,1,xsize=l(0),ysize=l(1),title='Fitted model'
 tvscl,rebin(subim,l(0),l(1))
 window,2,xsize=l(0),ysize=l(1),title='Obs-Fit '
 device,decomposed=0 & loadct,16
 tvscl,rebin(observed-subim,l(0),l(1))
 ;
 writefits,'observed.fit',observed
 writefits,strcompress(str+'_fitted.fit',/remove_all),subim/results(4)
 ;
 PSF=FFT(FFT(observed,-1)/FFT(subim,-1),1)
 PSF=sqrt(double(PSF*conj(PSF)))
 ; take away mean offset
 PSF(0,0)=0.0
 PSF=PSF/total(PSF)
 print,'Normalized PSF is calculated'
 writefits,strcompress(str+'_PSF.fit',/remove_all),PSF
endfor	; end of itype loop
end
