PRO getridofoutsiders,data
; will remove data that are indicated in the 'master_outliers.jd' file
; that file is hand-created based on out put in outsiders.jd
 if (file_exist('master_outsiders.jd') eq 1) then begin
     jd=reform(data(0,*))
     data2=get_data('master_outsiders.jd')
     jd2=reform(data2(0,*))
     array=[]
     for i=0,n_elements(jd)-1,1 do begin
         deltas=jd(i)-jd2(*)
         idx=where(deltas eq 0.0)
         if (idx(0) eq -1) then begin
             array=[[array],[data(*,i)]]
             endif
         endfor
     endif
 data=array
 return
 end
 
 PRO findoutsiders,jd_in,x_in,y_in,yupper_in,ylower_in
 jd=jd_in
 x=x_in
 y=y_in
 ylower=ylower_in
 yupper=yupper_in
 fmt='(a,f15.7,a,f9.3,a,f6.2)'
 ;-----------------------------------------
 idx=where(y gt yupper)
 if (idx(0) ne -1) then begin
     n=n_elements(idx)
     for k=0,n-1,1 do begin
         span=(yupper(idx(k))-ylower(idx(k)))/2.0
         Z=(y(idx(k))-yupper(idx(k)))/span
         print,format=fmt,'Outsider above: ',jd(idx(k)),' at am= ',x(idx(k)),' Z= ',z
         if (abs(z) gt 1) then printf,66,format='(f15.7,1x,f9.2)',jd(idx(k)),z
         endfor
     endif
 ;-----------------------------------------
 idx=where(y lt ylower)
 if (idx(0) ne -1) then begin
     n=n_elements(idx)
     for k=0,n-1,1 do begin
         span=(yupper(idx(k))-ylower(idx(k)))/2.0
         Z=(y(idx(k))-ylower(idx(k)))/span
         print,format=fmt,'Outsider below: ',jd(idx(k)),' at am= ',x(idx(k)),' Z= ',z
         if (abs(z) gt 1) then printf,66,format='(f15.7,1x,f9.2)',jd(idx(k)),z
         endfor
     endif
 ;-----------------------------------------
 return
 end
 
 PRO gettrumpet,x,y,meanslope,SDslope,meanintercept,SDintercept,ylower,yupper
 yupper=y+sqrt(1.0d0*SDintercept^2+x^2*SDslope^2)
 ylower=y-sqrt(1.0d0*SDintercept^2+x^2*SDslope^2)
 return
 end
 
 PRO doMC,x,y,meanslope,SDslope,meanintercept,SDintercept
 nMC=1000
 n=n_elements(x)
 openw,45,'temp.trash'
 for iMC=0,nMC-1,1 do begin
     idx=fix(randomu(seed,n)*n)
     xx=x(idx)
     yy=y(idx)
     res=robust_linefit(xx,yy)
     printf,45,res(0),res(1)
     endfor
 close,45
 data=get_data('temp.trash')
 meanslope=median(data(1,*),/double)
 SDslope=robust_sigma(data(1,*))
 meanintercept=median(data(0,*),/double)
 SDintercept=robust_sigma(data(0,*))
 n=n_elements(data(1,*))
 fmt='(a15,1x,f10.6,a,f10.6,a,3i)'
 print,format=fmt,' ',meanslope,' +/- ',SDslope
 return
 end
 
 PRO find_extinction,jd,am,phase,magn
 common plotran,yran
 maxsig=0.013
 fixJDs=long(jd)
 fixJDs=fixJDs(sort(fixJDs))
 uniqJDs=fixJDs(uniq(fixJDs))
 n=n_elements(uniqJDs)
 openw,44,'k.dat'
 for i=0,n-1,1 do begin
     idx=where(long(jd) eq uniqJDs(i))
     x=am(idx)
     y=magn(idx)
     fmt='(a,1x,f15.7,1x,f10.6,a,f10.6,a,3i)'
     if (n_elements(idx) gt 16 and (max(x)-min(x) gt 1)) then begin
         plot,title=uniqJDs(i),xstyle=3,ystyle=3,x,y,xtitle='Airmass',ytitle='m',psym=7,charsize=1.8
         res=robust_linefit(x,y,yhat,sig,ss)
	print,'sig is: ',sig
         qflag=' '
         if (sig lt maxsig) then qflag='*'
         ; if (abs(res(1)) lt 1) then begin
         printf,44,qflag,uniqJDs(i),res(1),' +/- ',ss(1),' n= ',n_elements(x)
         print,format=fmt,qflag,uniqJDs(i),res(1),' +/- ',ss(1),' n= ',n_elements(x)
         oplot,x,yhat,color=fsc_color('red')
         doMC,x,y,meanslope,SDslope,meanintercept,SDintercept
         gettrumpet,x,yhat,meanslope,SDslope,meanintercept,SDintercept,ylower,yupper
         oplot,x,ylower,color=fsc_color('red'),linestyle=2	
         oplot,x,yupper,color=fsc_color('red'),linestyle=2	
         findoutsiders,jd(idx),x,y,yupper,ylower
         ;   endif
         endif
     endfor
 close,44
 return
 end
 
 ;=========================================================
 ; Version 2 of code that finds k for each night 
 common plotran,yran
 openw,66,'outsiders.jd'
 ;filename='fluxcurve_B.dat'
 ;filename='fluxcurve_IRCUT.dat'
 ;filename='fluxcurve_V.dat'
 ;filename='fluxcurve_VE1.dat'
 ;filename='fluxcurve_VE2.dat'
 filterstring='IRCUT'
 filename=strcompress('fluxcurve_'+filterstring+'.dat',/remove_all)
 
 ;----------
 data=get_data(filename)
 getridofoutsiders,data
 help,data
 jd=reform(data(0,*))
 phase=reform(data(1,*))
 am=reform(data(2,*))
 flux=reform(data(3,*))
 magn=-2.5*alog10(flux)
 yran=[min(magn),max(magn)]
 find_extinction,jd,am,phase,magn
 close,66
 end
