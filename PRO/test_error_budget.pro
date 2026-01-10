PRO goplot
common text,N_DF,N_FF,time_to_saturation
data=get_data('data.dat')
t=reform(data(0,*))
type=reform(data(1,*))
err1=reform(data(2,*))
err2=reform(data(3,*))
err3=reform(data(4,*))
err4=reform(data(5,*))
dIerr=reform(data(6,*))
!P.MULTI=[0,1,2]
idx=where(type eq 1)
plot_oi,t(idx),dIerr(idx),xtitle='Exposure time [s]',ytitle='Relative Error on I [%]',psym=-7,xthick=3.0, ythick=3.0, charthick=3.0, charsize=1.2,$
ystyle=3,xstyle=1,title=strcompress('N!dFF!n='+string(n_FF)+' N!dDF!n= '+string(N_DF)+' t!dsat!n= '+string(time_to_saturation,format='(g7.2)'))
plots,[time_to_saturation,time_to_saturation],[!Y.crange],linestyle=2
plot_oi,t(idx),err1(idx),psym=-7,xtitle='Exposure time [s]',ytitle='Relative Error Contrib. [%]',xstyle=1,$
yrange=[0,100],ystyle=3,xthick=3.0, ythick=3.0, charthick=3.0, charsize=1.2
signature,string(systime())
oplot,t(idx),err2(idx),psym=-6
oplot,t(idx),err3(idx),psym=-5
oplot,t(idx),err4(idx),psym=-4
; Legend
vstep=+5
xyouts,/data,10,80,'O' & plots,/data,[15,20],[80,80],psym=-7 
xyouts,/data,10,80-1.*vstep,'F' & plots,/data,[15,20],[80-1.*vstep,80-1.*vstep],psym=-6 
xyouts,/data,10,80-2.*vstep,'D' & plots,/data,[15,20],[80-2.*vstep,80-2.*vstep],psym=-5 
xyouts,/data,10,80-3.*vstep,'t' & plots,/data,[15,20],[80-3.*vstep,80-3.*vstep],psym=-4 
plots,[time_to_saturation,time_to_saturation],[!Y.crange],linestyle=2
return
end

PRO get_FlatField_absolute_err,N_FF,delD,delF
 ; Calculates the SD of a FFg enerate as the average 
 ; of N_FF flat fields (ell-exposed) and the bias subtracted
 ;-----------------------------------------------------------
 common stuff, well_exposed
 ; first abs err of one well-exposed FF
 SD_oneframe=sqrt(well_exposed)	; assuming Poisson stats
 ; get the SD if N frames are averaged
 SD_N_frames=SD_oneframe/sqrt(N_FF)
 ; get the total SD of the average frame that has the DF subtracted
 abs_err_N_frames=sqrt(SD_N_frames^2+delD^2)
 ; then scale it to mean 1
 delF=abs_err_N_frames/well_exposed
 return
 end
 
 PRO get_DarkFrame_absolute_err,N,DFabserr
 ; returns the standard deviation of N bias or dark frames after normal averaging
 ; scaled to Henriette's experiment with 120 frames.
 ;-----------------------------------------------------------
 DFabserr=0.062/sqrt(N)*sqrt(120.)	; at N frames averaged
 return
 end
 
 
 ;===============================================================================
 ; Code to simulate the relative contributions of various terms.
 ;===============================================================================
 common stuff, well_exposed
 common text,N_DF,N_FF,time_to_saturation
 well_exposed=55000.0d0
 for jpow=-1.,2.,0.2 do begin
 time_to_saturation=10^jpow	; time in seconds to reach the 'well_exposed' level
 ; Typical Dark or Bias Frame level is 400
 DF=393.0d0
 ; The Flat Field (FF) is generated from the average of many FFs and is then scaled to
 ; level 1 (conceptually at least)
 FF=DF+1.0d0	; FF is DF + accumulated light
 N_DF=5000L	; number of Bias frames or dark frames added
 get_DarkFrame_absolute_err,N_DF,delD ; get the dark or bias frame absolute; err
 n_FF=500
 get_FlatField_absolute_err,N_FF,delD,delF
 delT=2e-4	; nominal exposure time uncertainty
 N=10.*10.	; how many pixels are there in the 'patch' we use?
 itypename=['BS','DS']
 print,'================================================================'
 print,'Assuming:'
 print,'mean value of Dark Frame=',df
 print,'mean value of Flat Field + Dark Frame=',ff
 print,'del t_exp=',delT,' seconds.'
 print,'Number of coadded pixels in a "patch": ',N
 print,' ... we then get ...'
 openw,66,'data.dat'
 for ipow=-1.0,2,.1 do begin
     for itype=1,2,1 do begin
     print,'-------------------------------------------------------------------'
     print,'This is for ',itypename(itype-1)
         print,'-------------------------------------------------------------------'
         T=10^ipow	; time in seconds
         if (itype eq 1) then begin
             ; typical value of O for any ' well-exposed frames' frames:
             O=DF+well_exposed/time_to_saturation*T	; observation is DF + accumulated light
             endif
         if (itype eq 2) then begin
             ; typical value of O for CoAdd type frames on the DS:
             O = DF + 55./10.*T
             endif
         delO=sqrt((sqrt(O)^2+delD^2))	; if Poisson, no averaging, + chain-rule
         I=abs((O-DF)/(FF-DF)/T)
         ; So the results are for 1 pixel
         dIdO=abs(1./(FF-DF)/t)
         dIDF=abs((DF-O)/(FF-DF)^2/t)
         dIdD=abs((O-FF)/(FF-DF)^2/t)
         dIdt=abs((DF-O)/(FF-DF)/t^2)
         print,' t: ',T,' seconds.'
         dI2=(dIdO*delO)^2+(dIDF*delF)^2+(dIdD*delD)^2+(dIdt*delT)^2
         print,format='(1x,a9,f13.3,1x,a)','O: ',O,' counts.'
         print,format='(1x,a9,f13.3,1x,a)','I: ',I,' counts/second.'
         print,format='(1x,a9,f11.4)','dI: ',sqrt(dI2)
         print,format='(4(1x,a9,f11.4))','dO: ',delO,'dF: ',delF,'dD: ',delD,'dt: ',delt
         print,format='(4(1x,a9,f11.4))','dI/dO: ',dIdO,'dI/dF: ',dIDF,'dI/dD: ',dIdD,'dI/dt: ',dIdt
         f='(a,g7.2,a,g8.3,a)'
         print,format=f,'(dI/dO*delO)^2: ',(dIdO*delO)^2,', in relative terms: ',(dIdO*delO)^2/dI2*100.0,' %.'
         print,format=f,'(dI/DF*delF)^2: ',(dIDF*delF)^2,', in relative terms: ',(dIDF*delF)^2/dI2*100.0,' %.'
         print,format=f,'(dI/dD*delD)^2: ',(dIdD*delD)^2,', in relative terms: ',(dIdD*delD)^2/dI2*100.0,' %.'
         print,format=f,'(dI/dt*delT)^2: ',(dIdt*delT)^2,', in relative terms: ',(dIdt*delT)^2/dI2*100.0,' %.'
         delI=sqrt((dIdO*delO)^2+(dIDF*delF)^2+(dIdD*delD)^2+(dIdt*delT)^2)
       	 printf,66,format='(f7.3,1x,i3,5(1x,g9.3))',t,itype,(dIdO*delO)^2/dI2*100.0,(dIDF*delF)^2/dI2*100.0,(dIdD*delD)^2/dI2*100.0,(dIdt*delT)^2/dI2*100.0,delI/I*100.
         print,strcompress('Total relative err on one pixel: '+string(delI/I*100.)+' %')
         print,strcompress('Total relative err on '+string(fix(N))+' independent elements: '+string(delI/I*100./sqrt(N))+' %')
         print,'-------------------------------------------------------------------'
         enDFor
     enDFor
     close,66
	;
	goplot
     endfor
 end
