function poidev, xm, SEED = seed
;+
; NAME:
;     POIDEV
; PURPOSE:
;     Generate a Poisson random deviate
; EXPLANATION:
;     Return an integer random deviate drawn from a Poisson distribution with
;     a specified mean.    Adapted from procedure of the same name in 
;     "Numerical Recipes" by Press et al. (1992), Section 7.3
;
;     NOTE: This routine became partially obsolete in V5.0 with the 
;     introduction of the POISSON keyword to the intrinsic functions 
;     RANDOMU and RANDOMN.     However, POIDEV is still useful for adding 
;     Poisson noise to an existing image array, for which the coding is much 
;     simpler than it would be using RANDOMU (see example 1) 
; CALLING SEQUENCE:
;     result = POIDEV( xm, [ SEED = ] )
;
; INPUTS:
;     xm - numeric scalar, vector or array, specifying the mean(s) of the 
;          Poisson distribution
;
; OUTPUT:
;     result - Long integer scalar or vector, same size as xm
;
; OPTIONAL KEYWORD INPUT-OUTPUT:
;     SEED -  Scalar to be used as the seed for the random distribution.  
;             For best results, SEED should be a large (>100) integer.
;             If SEED is undefined, then its value is taken from the system 
;             clock (see RANDOMU).    The value of SEED is always updated 
;             upon output.   This keyword can be used to have POIDEV give 
;             identical results on consecutive runs.     
;
; EXAMPLE:
;     (1) Add Poisson noise to an integral image array, im
;              IDL> imnoise = POIDEV( im)
;
;     (2) Verify the expected mean  and sigma for an input value of 81
;              IDL> p = POIDEV( intarr(10000) + 81)   ;Test for 10,000 points
;              IDL> print,mean(p),sigma(p)
;     Mean and sigma of the 10000 points should be close to 81 and 9
;
; METHOD: 
;     For small values (< 20) independent exponential deviates are generated 
;     until their sum exceeds the specified mean, the number of events 
;     required is returned as the Poisson deviate.   For large (> 20) values,
;     uniform random variates are compared with a Lorentzian distribution 
;     function.
;
; NOTES:
;     Negative values in the input array will be returned as zeros.  
;
;       
; REVISION HISTORY:
;      Version 1               Wayne Landsman        July  1992
;      Added SEED keyword                            September 1992
;      Call intrinsic LNGAMMA function               November 1994
;      Converted to IDL V5.0   W. Landsman   September 1997
;      Use COMPLEMENT keyword to WHERE()        W. Landsman August 2008
;-
  On_error,2
  compile_opt idl2

 Npts = N_elements( xm)
 
 case NPTS of 
 0: message,'ERROR - Poisson mean vector (first parameter) is undefined'
 1: output = lonarr(1) 
 else: output = make_array( SIZE = size(xm), /NOZERO ) 
 endcase 
 
   index = where( xm LE 20, Nindex, complement=big, Ncomplement=Nbig)

   if Nindex GT 0 then begin

   g = exp( -xm[ index] )           ;To compare with exponential distribution
   em1 = replicate( -1, Nindex )    ;Counts number of events
   t = replicate( 1., Nindex )          ;Counts (log) of total time

  Ngood = Nindex
  good = lindgen( Nindex)                 ;GOOD indexes the original array
  good1 = good                         ;GOOD1 indexes the GOOD vector

 REJECT:  em1[good] = em1[good] + 1      ;Increment event counter
   t = t[good1]*randomu( seed, Ngood )   ;Add exponential deviate, equivalent
                                         ;to multiplying random deviate
   good1 = where( t GT g[good], Ngood1)  ;Has sum of exponential deviates 
                                         ;exceeded specified mean?
   if ( Ngood1 GE 1 ) then begin
           good = good[ good1]
           Ngood = Ngood1
           goto, REJECT
   endif
   output[index] = em1
 endif
     if Nindex EQ Npts then return, output
; ***************************************

    xbig = xm[big]

    sq = sqrt( 2.*xbig )           ;Sq, Alxm, and g are precomputed
    alxm = alog( xbig )
    g = xbig * alxm - lngamma( xbig + 1.)

    Ngood = Nbig  & Ngood1 = Nbig
    good = lindgen( Ngood)
    good1 = good
    y = fltarr(Ngood, /NOZERO ) & em = y


REJECT1:   y[good] = tan( !PI * randomu( seed, Ngood ) )  
   em[good] = sq[good]*y[good] + xbig[good]
   good2 = where( em[good] LT 0. , Ngood )
   if (Ngood GT 0) then begin
            good = good[good2]
            goto, REJECT1
   endif

   fixem = long( em[good1] )
   test = check_math( 0, 1)         ;Don't want overflow messages
   t = 0.9*(1. + y[good1]^2)*exp( fixem*alxm[good1] - $ 
               lngamma( fixem + 1.) - g[good1] )
   good2 = where( randomu (seed, Ngood1) GT T , Ngood)
   if ( Ngood GT 0 ) then begin
            good1 = good1[good2]
            good = good1
            goto, REJECT1
   endif
   output[ big ] = long(em)

 return, output

 end
PRO get_a_synthetic_image,JD,im1,par1,par2
albedo = par1
; Generate one FITS images of the Moon for the given JD with PSF and Earth's albedo in par1
; the swithc to be put into file moon_BRDF.txt is in par2
get_lun,hjkl
openw,hjkl,'JDtouseforSYNTH'
printf,hjkl,format='(f15.7)',JD
close,hjkl
free_lun,hjkl
;=================================================
; set up albedo 
get_lun,hjkl
openw,hjkl,'single_scattering_albedo.dat'
printf,hjkl,par1
close,hjkl
free_lun,hjkl
;=================================================
; set up moon_BRDF
get_lun,hjkl
openw,hjkl,'moon_BRDF.txt'
printf,hjkl,par2
close,hjkl
free_lun,hjkl
;================================================
spawn,'gdl go_get_particular_synthimage_16_for_ML.pro'
get_lun,iuhgyuygf
openr,iuhgyuygf,'nameofparticularsynthimage.txt'
thename=''
readf,iuhgyuygf,thename
close,iuhgyuygf
im1=readfits(thename,/silent)
;================================================
return
end




;====================================================
;
; This version ONLY produces convolved images - there is no blocking
; For blocking use code such as  "/home/pth/WORKSHOP/FITSIMAGES/setup_data_8x8_with_image_flips_DNR_reduction_3.Rmd"
;
;====================================================
; Moon reflectance specification
moon_albedo  = 1     ; 0=uniform (0.0720) , 1=Clementine albedos from file
moon_BRDF    = 1     ; 0=uniform (Lambert), 1=uniform(Hapke), 2=from file
nalbedo=6000
corefactor = 2
rlimit = 9
        path = 'OUTPUT/MLIMAGES/testim_'
        ;path= '/media/pth/SSD1/MLIMAGES/testim_'
for itrial=1,nalbedo,1 do begin
	close,/all
        JD=2455852.8772108d0+28.0*(randomu(seed)-0.5)
        mphase,JD,illfrac
        if illfrac LT 0.6 then begin
	albedo=randomu(seed)*0.5+0.1
	get_a_synthetic_image,JD,im1,albedo,301
        ; scale it arbitrarily
        im1=im1*(randomu(seed)+0.5)
	; convolve it
	writefits,'mixed117.fits',im1,mixedimageheader
        alfa1 = randomu(seed)*0.2+1.7
 	str='./justconvolve_scwc mixed117.fits trialout117.fits '+string(alfa1)+' '+string(corefactor)+' '+string(rlimit)
 	spawn,str
 	folded=readfits('trialout117.fits',/silent)
; re-scale
;	folded = folded/max(folded)*50000.0d0
; generate Poisson noise - should it be 'added'? Isn't it a 'draw from' situation?.
        Pnoise = PoiDev(folded)
	folded = Pnoise
	;folded=folded + 0.5 * Pnoise
	writefits,strcompress(path+string(albedo)+'_'+string(illfrac)+'_.fits',/remove_all),folded
	; Dimensionaly reduce that image
	;n=8
	;blocked = REBIN(folded, n,n)
	;openw, 73, 'data_8x8_for_ML_convolved_different_alfa_PoiDev_JD_total_albedo_illfrac.dat', /append
	;printf,73,[rebin(blocked,n*n),total(folded),albedo,illfrac],FORMAT='(64(F12.3,1X),F22.7,1X,2(f12.3,1x))'
;
;	close,73
	print,JD,illfrac,alfa1
	print,'--------------------------------- oOo --------------------------------'
	endif
endfor
end
