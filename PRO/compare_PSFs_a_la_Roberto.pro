PRO getPSFfromSB,r,SB,PSF
 common scaling,if_scale
 n=n_elements(r)
 PSF=dblarr(n)
 for i=1,n-2,1 do begin
     area0=!dpi*r(i-1)^2
     area1=!dpi*r(i)^2
     area2=!dpi*r(i+1)^2
     anulus_area=(area2-area1)/2.+(area1-area0)/2.
     PSF(i)=10^(-SB(i)/2.5)*anulus_area
     endfor
 PSF(0)=PSF(1)*3.4
 PSF(n-1)=PSF(n-2)
 if (if_scale eq 1) then begin
     gonormalisepsfwithitsVolume,r,psf,Volume
     psf=psf/volume
     endif
 return
 end
 
 FUNCTION ABmag,totalflux
 value=-2.5*alog10(totalflux/3631.)
 return,value
 end
 
 PRO gonormalisepsfwithitsVolume,r,psf,Volume
 rmax=max(r)
 surf=dblarr(rmax*2+1,rmax*2+1)
 l=size(surf,/dimensions)
 x0=l(0)/2
 y0=l(1)/2
 for i=0,l(0)-1,1 do begin
     for j=0,l(1)-1,1 do begin
         dist=sqrt((i-x0)^2+(j-y0)^2)
         surf(i,j)=interpol(psf,r,dist)
         endfor
     endfor
 ;surface,surf,/zlog
 Volume=total(surf,/double)
 return
 end
 
 PRO converttosurfacebrightrness,r,psf,mags_SB_psf
 ; NB: r is assumed to be in arc minutes
 n=n_elements(r)
 mags_SB_psf=r*0.0
 for i=1,n-2,1 do begin
     area0=!dpi*r(i-1)^2
     area1=!dpi*r(i)^2
     area2=!dpi*r(i+1)^2
     anulus_area=(area2-area1)/2.+(area1-area0)/2.
     flux_SB_psf=psf(i)/(anulus_area*3600.0)	; 3600 since r is in arcminutes
     mags_SB_psf(i)=-2.5*alog10(flux_SB_psf)
     endfor
 ;mags_SB_psf(0)=mags_SB_psf(1)
 mags_SB_psf(0)=-2.5*alog10(psf(0)/(!dpi*r(0)^2*3600.0))
 mags_SB_psf(n-1)=mags_SB_psf(n-2)
 return
 end
 
 PRO getTOMSTONEVEGA,r,psf
 common scaling,if_scale
 ; The Tom Stone ROLO PSF of VEGA in pixles vs counts
 file='./TOMSTONE/ROLO_765nm_Vega_psf.dat'
 data=get_data(file)
 pix=reform(data(0,*))
 psf=reform(data(1,*))
 idx=where(psf gt 0)
 r=pix(idx)*4.0	; now in arc seconds
 r=r/60.	; now in arc minutes
 psf=psf(idx)
 ;...
 idx=sort(r)
 r=r(idx)
 psf=psf(idx)
 ; clip the noisy end and extend with decaying exponential
 idx=where(r gt 16)
 psf(idx)=0.95e-3*exp(-(r(idx)-15)^0.7)
 ;
 if (if_scale eq 1) then begin
     gonormalisepsfwithitsVolume,r,psf,Volume
     print,'Volume is: ',Volume
     print,'Volume scaling requested'
     psf=psf/Volume
     endif
 return
 end
 
 ;-----------------------------
 common scaling,if_scale
 if_scale=1
 getTOMSTONEVEGA,r,psf
 ;
 converttosurfacebrightrness,r,psf,SB_psf
 vegayat1=interpol(SB_psf,r,1)
 vegayat2=interpol(SB_psf,r,2)
 vegayat0p1=interpol(SB_psf,r,0.1)
 ; Plot panel 1
 !P.MULTI=[0,2,3]
 !P.CHARSIZE=1.7
 plot_io,xstyle=3,ystyle=3,xrange=[0,55],r,psf,xtitle='Radius [arcmin]',ytitle='PSF [Vol. Norm. counts]'
 plot_oi,yrange=[20,0],xrange=[0.1,55],xstyle=3,ystyle=3,r,SB_psf,xtitle='Radius [arcmin]',ytitle='Surface brightness [mags/asec!u2!n]'
 plot_oo,xstyle=3,ystyle=3,r,psf,xtitle='Radius [arcmin]',ytitle='PSF [counts]'
 plot_oi,yrange=[25,-5],xrange=[0.001,55],xstyle=3,ystyle=3,r,SB_psf,xtitle='Radius [arcmin]',ytitle='Surface brightness [mags/asec!u2!n]'
 oplot,[0.1,0.1],[15,-5],linestyle=1
 oplot,[0.001,0.7],[vegayat0p1,vegayat0p1],linestyle=1
 oplot,[0.001,4],[vegayat2,vegayat2],linestyle=2
 oplot,[2.0,2.0],[23,3],linestyle=2
 ; overplot AvD
 plot_oi,yrange=[25,-5],xrange=[0.001,55],xstyle=3,ystyle=3,r,SB_psf,xtitle='Radius [arcmin]',ytitle='Surface brightness [mags/asec!u2!n]'
 ; overplot a 1/r² linenear the core
 oplot,r(0:140),-2.5*alog10(.01/r(0:140)^1.0),color=fsc_color('orange')
 oplot,[1,1],[13,6]	; vertical line at 1
 data=get_data('AvDsurfbri.dat')
 rAvD=10^reform(data(0,*))
 SB_AvD=reform(data(1,*))
 getPSFfromSB,rAvD,SB_AvD,PSF_AvD
 converttosurfacebrightrness,rAvD,PSF_AvD,SB_AvD
 AvDyat1=interpol(SB_AvD,rAvD,1)
 AvDyat0p1=interpol(SB_AvD,rAvD,0.1)
 oplot,rAvD,SB_AvD-(AvDyat1-vegayat1),color=fsc_color('blue')
 oplot,rAvD,SB_AvD-(AvDyat0p1-vegayat0p1),color=fsc_color('blue'),linestyle=2
 ; now alos MARKAB
 data=get_data('noheader_SB_MARKAB.dat')
 rMARKAB=reform(data(0,*))	; in arcminutes
 SBMARKAB=reform(data(1,*))	
 getPSFfromSB,rMARKAB,SBMARKAB,PSF_MARKAB
 converttosurfacebrightrness,rMARKAB,PSF_MARKAB,SBMARKAB
 MARKAByat1=interpol(SBMARKAB,rMARKAB,1)
 MARKAByat0p1=interpol(SBMARKAB,rMARKAB,0.1)
 oplot,rMARKAB,SBMARKAB-(MARKAByat1-vegayat1),color=fsc_color('red')
 oplot,rMARKAB,SBMARKAB-(MARKAByat0p1-vegayat0p1),color=fsc_color('red'),linestyle=2
 ;
 arrow,0.03,5,0.1,vegayat0p1,/data
 arrow,3,-2,1,vegayat1,/data
 end
 
