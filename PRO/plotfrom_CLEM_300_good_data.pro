PRO getfromfile,filename,filtername,JD,alb,erralb,airm,alfa,phase,glon,glat
 str=''
 openr,1,filename
 ic=0
 while not eof(1) do begin
     readf,1,str
     bits=strsplit(str,' ',/extract)
     if (bits(8) eq filtername) then begin
         if (ic eq 0) then dataB=[double(bits(0:7))]
         if (ic gt 0) then dataB=[[dataB],[double(bits(0:7))]]
         ic=ic+1
         endif
     endwhile
 close,1
 JD=reform(dataB(0,*))
 alb=reform(dataB(1,*))
 erralb=reform(dataB(2,*))
 alfa=reform(dataB(3,*))
 airm=reform(dataB(4,*))
 phase=reform(dataB(5,*))
 glon=reform(dataB(6,*))
 glat=reform(dataB(7,*))
 return
 end
 
 PRO plot_phase_albedo,filtername,alfamin,alfamax,slopetouse,alfa0
 common settings,linorlog
 getfromfile,'CLEM_300_good_data.txt',filtername,JD,alb,erralb,airm,alfa,phase,glon,glat
 if (linorlog ne 1) then stop
 if (linorlog eq 1) then begin
     plot,psym=7,xrange=[70,140],title=filtername,abs(phase),alb,xtitle='|Lunar phase|',ytitle='Lambert albedo',xstyle=3,ystyle=3
     oploterr,abs(phase),alb,erralb
     endif
 return
 end
 
 PRO plot_alfa_albedo,filtername,alfamin,alfamax,slopetouse,alfa0
 common settings,linorlog
 getfromfile,'CLEM_300_good_data.txt',filtername,JD,alb,erralb,airm,alfa,phase,glon,glat
 if (linorlog ne 1) then stop
 if (linorlog eq 1) then begin
     plot,xrange=[alfamin,alfamax],title=filtername,alfa,alb,xtitle='!7a!3',ytitle='Lambert albedo',psym=7,xstyle=3,ystyle=3
     oploterr,alfa,alb,erralb
     ;x=findgen(100)/50.+1.0
     ;oplot,x,alfa0-alog10(x)*slopetouse
     endif
 return
 end
 
 PRO plot_phase_alfa,filtername,alfamin,alfamax,slopetouse,alfa0
 common settings,linorlog
 getfromfile,'CLEM_300_good_data.txt',filtername,JD,alb,erralb,airm,alfa,phase,glon,glat
 if (linorlog ne 1) then stop
 if (linorlog eq 1) then begin
     plot,xrange=[90,140],yrange=[alfamin,alfamax],title=filtername,abs(phase),alfa,xtitle='|Lunar phase|',ytitle='!7a!3',psym=7,xstyle=3,ystyle=3
     ;x=findgen(100)/50.+1.0
     ;oplot,x,alfa0-alog10(x)*slopetouse
     endif
 return
 end
 
 PRO plot_airmass_alfa,filtername,alfamin,alfamax,slopetouse,alfa0
 common settings,linorlog
 getfromfile,'CLEM_300_good_data.txt',filtername,JD,alb,erralb,airm,alfa,phase,glon,glat
 plot_oi,xrange=[0.9,5],yrange=[alfamin,alfamax],title=filtername,airm,alfa,xtitle='Airmass',ytitle='!7a!3',psym=7,xstyle=3,ystyle=3
 x=findgen(100)/50.+1.0
 oplot,x,alfa0-alog10(x)*slopetouse
 return
 end
 
 PRO plot_airmass_albedo,filtername,alfamin,alfamax,slopetouse,alfa0
 common settings,linorlog
 getfromfile,'CLEM_300_good_data.txt',filtername,JD,alb,erralb,airm,alfa,phase,glon,glat
 plot,xrange=[0.9,5],title=filtername,airm,alb,xtitle='Airmass',ytitle='Lambert albedo',psym=7,xstyle=3,ystyle=3
oploterr,airm,alb,erralb
 return
 end
 
 common settings,linorlog
 !P.CHARSIZE=1.7
 ; First plot airmass and alfa and fit (by eye) some lines
 !P.MULTI=[0,2,3]
 linorlog=2
 plot_airmass_alfa,'B',1.71,1.76,0.031,1.752
 plot_airmass_alfa,'V',1.71,1.76,0.021,1.752
 plot_airmass_alfa,'VE1',1.69,1.74,0.011,1.728
 plot_airmass_alfa,'IRCUT',1.69,1.74,0.011,1.728
 plot_airmass_alfa,'VE2',1.65,1.70,0.008,1.69
 ; plot phase and alfa
 !P.MULTI=[0,1,5]
 linorlog=1
 plot_phase_alfa,'B',1.71,1.76,0.031,1.752
 plot_phase_alfa,'V',1.71,1.76,0.021,1.752
 plot_phase_alfa,'VE1',1.69,1.74,0.011,1.728
 plot_phase_alfa,'IRCUT',1.69,1.74,0.011,1.728
 plot_phase_alfa,'VE2',1.65,1.70,0.008,1.69
 ; plot alfa and albedo
 !P.MULTI=[0,1,5]
 linorlog=1
 plot_alfa_albedo,'B',1.71,1.76,0.031,1.752
 plot_alfa_albedo,'V',1.71,1.76,0.021,1.752
 plot_alfa_albedo,'VE1',1.69,1.74,0.011,1.728
 plot_alfa_albedo,'IRCUT',1.69,1.74,0.011,1.728
 plot_alfa_albedo,'VE2',1.65,1.70,0.008,1.69
 ; plot phase and albedo
 !P.MULTI=[0,1,5]
 linorlog=1
 plot_phase_albedo,'B',1.71,1.76,0.031,1.752
 plot_phase_albedo,'V',1.71,1.76,0.021,1.752
 plot_phase_albedo,'VE1',1.69,1.74,0.011,1.728
 plot_phase_albedo,'IRCUT',1.69,1.74,0.011,1.728
 plot_phase_albedo,'VE2',1.65,1.70,0.008,1.69
 ; plot airmass and albedo
 !P.MULTI=[0,2,3]
 linorlog=1
 plot_airmass_albedo,'B',1.71,1.76,0.031,1.752
 plot_airmass_albedo,'V',1.71,1.76,0.021,1.752
 plot_airmass_albedo,'VE1',1.69,1.74,0.011,1.728
 plot_airmass_albedo,'IRCUT',1.69,1.74,0.011,1.728
 plot_airmass_albedo,'VE2',1.65,1.70,0.008,1.69
 end
