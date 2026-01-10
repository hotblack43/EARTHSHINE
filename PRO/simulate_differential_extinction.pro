 PRO peters, z, pars, F, pder
 a0=pars(0)
 dk=pars(1)
 f=a0*10^(-0.4*(dk*z))
   IF N_PARAMS() GE 4 THEN begin
    pder = [[f/a0], [f*(-0.4*alog(10.)*z)]]
   endif
 return
 END


PRO gofitexpfunction,x,y,A0,deltaK,iaction
 weights=0.0*y+1.0
 pars=[0.3,0.004]
 afit=[1,1]
 chi2tol=1e-5
 Result = CURVEFIT( X, Y, Weights, pars , Sigma, /DOUBLE, FITA=afit, FUNCTION_NAME='peters', /NODERIVATIVE, TOL=chi2tol, CHISQ=chi2, STATUS=stat, ITMAX=1000)
 xx=findgen(101)/100.*8.0
 peters,xx,pars,yy      ; generate fitted line to plot on top
 oplot,xx,yy,color=fsc_color('green'),psym=-1
 print,'Status: ',stat
 print,pars(0),' +/- ',sigma(0)
 print,'CURVEFIT: Alb vs Z slope: ',pars(1),' +/- ',sigma(1)
 res2=linfit(x,y)
 print,'LINFIT  : Alb vs Z slope: ',res2(1),' +/- ',sigma(1)
 if (iaction eq 1) then begin
     str1='A!dB!n(z=0) ='+string(pars(0),format='(f6.3)')
     str2='dk ='+string(pars(1),format='(f7.4)')
     xyouts,/data,0.25,0.4,str1+' '+str2,charsize=1.2
     endif
 if (iaction eq 2) then begin
     str1='A!dV!n(z=0) ='+string(pars(0),format='(f6.3)')
     str2='dk ='+string(pars(1),format='(f7.4)')
     xyouts,/data,0.25,0.2,str1+' '+str2,charsize=1.2
     endif
 a0=pars(0)
 deltak=pars(1)
 return
 end

FUNCTION getalbedo,filter_table,flux1,flux2
 ; Albedois the ratio of two fluxes
 wave=filter_table(0,*)
 filter_trans=filter_table(1,*)
 ; filter transmits ...
 transmitted1=int_tabulated(wave,flux1*filter_trans,/double)	; integrated flux of source 1 through filter
 transmitted2=int_tabulated(wave,flux2*filter_trans,/double)	; integrated flux of source 2 through filter
 albedo=transmitted1/transmitted2
 if (albedo ge 1 or albedo le 0) then stop
 return,albedo
 end
 
 FUNCTION extinction,wave
 value=(1./wave^4)/(1./5500.)^4*0.2
 return,value
 end
 
 FUNCTION extincted,flux,Z
 common wavelength,wave
 mags=-2.5*alog10(flux)
 observed_mag=mags+extinction(wave)*Z
 fluxout=10^(observed_mag/(-2.5))
 return,fluxout
 end
 
 FUNCTION mags,flux,trans_in
 wave=trans_in(0,*)
 trans=trans_in(1,*)
 mag=-2.5*alog10(int_tabulated(wave,flux*trans,/double))
 return,mag
 end

 PRO get_normalized_filter,fstr,V,wave
 ; Fetch listed filter transmission curves
 v=get_data('./SYSINFO/TRANS/'+fstr+'_transmission.dat')
 v(0,*)=v(0,*)*10.	; place on Angström scale
 ; interpolate onto wave
 newy=[]
 for k=0,n_elements(wave)-1,1 do begin
 newy=[newy,interpol(v(1,*),v(0,*),wave(k))]
 endfor
; experimemntal code here
;newy=newy^40
 ; 
 v=[transpose(wave),transpose(newy)]
 ; Normalize
 v(1,*)=v(1,*)/int_tabulated(v(0,*),v(1,*),/double)
 ; check normalization
 print,'Area: ',int_tabulated(v(0,*),v(1,*),/double)
 return
 end
 
 
 common wavelength,wave
 !P.MULTI=[0,1,2]
;window,0,xsize=600,ysize=900
 ; Define a wavelength scale to work with
 wave=findgen(6000)+2000	; wavelength in A
 ; fetch filters on a predefined wavelength scale
 get_normalized_filter,'B',B,wave
 get_normalized_filter,'V',V,wave
 ; define two sources at different temperatures
 blue=planck(wave,3560)
 red=planck(wave,3270)*1e1 ; BS is brighter than DS
 
 !P.THICK=4
 !P.charsize=1.7
 !P.charthick=2
 plot,wave,red,xtitle='Wavelength [A]',ytitle='Flux'
 listen=[]
 ; For each valueof airmass Z now generate albedo (from ratio blue/red)
 ; from simulated observed fluxes - i.e. extincted 
 for Z=1.0,3.0,0.3 do begin
     oplot,wave,extincted(red,Z)
     albedo_B=getalbedo(B,extincted(blue,Z),extincted(red,Z))
     albedo_V=getalbedo(V,extincted(blue,Z),extincted(red,Z))
     listen=[[listen],[z,albedo_B,albedo_V]]
     endfor
 print,'    z       AB       AV : '
 print,listen
 ; overplot scaled transmission curves
 oplot,b(0,*),b(1,*)/max(b(1,*))*0.5*!Y.crange(1),color=fsc_color('blue')
 oplot,v(0,*),v(1,*)/max(v(1,*))*0.5*!Y.crange(1),color=fsc_color('green')
 plot,psym=-7,listen(0,*),listen(1,*),xtitle='Z',ytitle='Albedo',xstyle=3,xrange=[0,3],yrange=[min(listen(1:2,*)),max(listen(1:2,*))]
 oplot,listen(0,*),listen(2,*),psym=-7
 gofitexpfunction,reform(listen(0,*)),reform(listen(1,*)),A0,deltaK,1
;gofitLINEARfunction,reform(listen(0,*)),reform(listen(1,*)),A0,deltaK,1
 print,'B regression: ',robust_linefit(listen(0,*),listen(1,*))
 print,'V regression: ',robust_linefit(listen(0,*),listen(2,*))
 print,'k(B): ',extinction(4500.)
 print,'k(V): ',extinction(5500.)
 print,'B-V  blue object: ',mags(blue,B)-mags(blue,V)
 print,'B-V redder object: ',mags(red,B)-mags(red,V)
 end
