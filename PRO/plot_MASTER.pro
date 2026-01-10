PRO peters, z, pars, F
 a0=pars(0)
 dk=pars(1)
 f=a0*exp(-(dk*z))
 return
 END
 PRO peters2, z, pars, F, pder
 a0=pars(0)
 dk=pars(1)
 f=a0*10^(-0.4*(dk*z))
   IF N_PARAMS() GE 4 THEN begin
    pder = [[f/a0], [f*(-0.4*alog(10.)*z)]]
   endif
 return
 END

 
 PRO gofitexpfunction,x,y,A0,deltaK,iaction
 common cols,colname
 weights=0.0*y+1.0
 pars=[0.3,0.004]
 afit=[1,1]
 chi2tol=1e-5
 Result = CURVEFIT( X, Y, Weights, pars , Sigma, /DOUBLE, FITA=afit, FUNCTION_NAME='peters2', /NODERIVATIVE, TOL=chi2tol, CHISQ=chi2, STATUS=stat, ITMAX=1000)
 xx=findgen(100)/100.*8.0
 peters2,xx,pars,yy	; generate fitted line to plot on top
 oplot,xx,yy,linestyle=1,color=fsc_color(colname)
 print,stat
 print,pars(0),' +/- ',sigma(0)
 print,pars(1),' +/- ',sigma(1)
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
 
 PRO getuniqueintegerJD,jd,nunique,intJDS
 intJDs=long(jd)
 intJDs=intJDS(sort(intJDs))
 intJDS=intJDs(uniq(intJDs))
 nunique=n_elements(intJDs)
 return
 end
 
 PRO get_airmass_fromJD,JD,amarr
 amarr=[]
 lat=ten([19,32.4])
 lon=ten([155,34.4])
 for k=0,n_elements(jd)-1,1 do begin
     ; get the airmass
     moonpos, JD(k), RAmoon, DECmoon
     am = airmass(JD(k), RAmoon*!dtor, DECmoon*!dtor, lat*!dtor, lon*!dtor)
     am=am(0)
     amarr=[amarr,am]
     endfor
 return
 end
 
 PRO getphasefromJD,JD,phasearr
 phasearr=[]
 for k=0,n_elements(jd)-1,1 do begin
     MOONPHASE,jd(k),phase_angle_M,alt_moon,alt_sun,obsname
     phase=phase_angle_M
     phasearr=[phasearr,phase]
     endfor
 return
 end
 
 PRO goplot,x_in,y_in,dy_in,filt_in,filterchoice,plottype,colname,xstr,ystr
 common ranges,xra,yra,titstr
 common cols,colnum
; first sort in order of increasing airmass
;lmx=sort(x)
;x=x_in(lmx)
;y=y_in(lmx)
;dy=dy_in(lmx)
;filt=filt_in(lmx)
 colnum=colname
 x=x_in
 y=y_in
 dy=dy_in
 filt=filt_in
 xra=[1,10]
 yra=[0.1,0.45]
 idx=where(filt eq filterchoice)
 if (idx(0) ne -1) then begin
     if (plottype eq 0) then begin
         plot,x(idx),y(idx),psym=-1,xrange=xra,yrange=yra,xtitle=xstr,ytitle=ystr,title='LRO'+titstr
         oploterr,x(idx),y(idx),dy(idx),3
         endif else begin
         oplot,x(idx),y(idx),psym=-1,color=fsc_color(colname)
         oploterr,x(idx),y(idx),dy(idx),3
         endelse
     if (n_elements(idx) ge 3) then begin
         iaction=0
         if ((filt(idx))(0) eq 'B') then iaction=1
         if ((filt(idx))(0) eq 'V') then iaction=2
         gofitexpfunction,x(idx),y(idx),A0,deltaK,iaction
         endif
     endif
 return
 end
 
 FUNCTION interquartilrange,x_in
 x=x_in
 n=n_elements(x)
 x=x(sort(x))
 q1=x(n/3.)
 q2=x(n/2.)
 q3=x(n*2./3.)
 value=q3-q1
 return,value
 end
 
 PRO makehisto2,x,xstr
 IQR=interquartilrange(x)
 binsize=2.*IQR*N_elements(x)^(-1./3.)
 histo,/abs,x,0,0.9,0.09/21.,xtitle=xstr,title='All albedo uncertainties'
 med=median(x)
 xyouts,/data,0.4,8,'median = '+string(med,format='(f8.5)')
 return
 end
 
 PRO makehisto,x,xstr
 IQR=interquartilrange(x)
 binsize=2.*IQR*N_elements(x)^(-1./3.)
 histo,/abs,x,0,0.04,0.04/21.,xtitle=xstr,title='All albedo uncertainties'
 med=median(x)
 xyouts,/data,0.02,8,'median = '+string(med,format='(f8.5)')
 return
 end
 
 
 
 common ranges,xra,yra,titstr
 !P.charsize=2
 !P.thick=3
 !P.charthick=2
 ;2456104.8120040     B   31    0.3719  0.005681
 file='MASTER_outputlist_from_bagging.txt'
 str="awk '{print $1,$3,$4,$5,$6}' "+file+" > data.dat"
 spawn,str
 str="awk '{print $2}' "+file+" > fileter_data.dat"
 spawn,str
 data=get_data('data.dat')
;--------------
 jd=reform(data(0,*))
 idx=sort(jd)
 data=data(*,idx)
;--------------
 jd=reform(data(0,*))
 getphasefromJD,JD,phasearr
 get_airmass_fromJD,JD,amarr
 N=reform(data(1,*))
 Albedo=reform(data(2,*))
 dAlbedo=reform(data(3,*))
 rmse=reform(data(4,*))
 openr,33,'fileter_data.dat'
 str=''
 filt=[]
 while not eof(33) do begin
     readf,33,str
     filt=[filt,str]
     endwhile
 close,33
 ; loop over all sets of JDs to get one plotper night.
 getuniqueintegerJD,jd,nunique,uniqueJDs
 !P.MULTI=[0,1,4]
 for iuniqueJD=0,nunique-1,1 do begin
     titstr=string(uniqueJDs(iuniqueJD))
     ldx=where(long(jd) eq uniqueJDs(iuniqueJD))
     if (ldx(0) ne -1) then begin
         ;
         goplot,amarr(ldx),albedo(ldx),dAlbedo(ldx),filt(ldx),'B',0,'black','Airmass','Albedo'
         goplot,amarr(ldx),albedo(ldx),dAlbedo(ldx),filt(ldx),'B',1,'blue','Airmass','Albedo'
         goplot,amarr(ldx),albedo(ldx),dAlbedo(ldx),filt(ldx),'V',1,'green','Airmass','Albedo'
         goplot,amarr(ldx),albedo(ldx),dAlbedo(ldx),filt(ldx),'VE1',1,'orange','Airmass','Albedo'
         goplot,amarr(ldx),albedo(ldx),dAlbedo(ldx),filt(ldx),'IRCUT',1,'yellow','Airmass','Albedo'
         goplot,amarr(ldx),albedo(ldx),dAlbedo(ldx),filt(ldx),'VE2',1,'red','Airmass','Albedo'
         ;
         ;makehisto,dAlbedo(ldx),'!7D!3 albedo (LRO)'
         ;makehisto2,rmse(ldx),'RMSE (LRO)'
         endif
     endfor
 signature,'/home/pth/SCI/EARTHSHINE/plot_MASTER.pro'
 end
