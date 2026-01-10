PRO getstats,a_in,medval,pctilelow,pctilehi,robSD
 a=a_in
 bins=(max(a)-min(a))/n_elements(a)
 h=histogram(a,binsize=bins,locations=locs)
 cumul = TOTAL(h, /CUMULATIVE)
 tot = TOTAL(FLOAT(h))
 cdf = cumul/tot
 index = VALUE_LOCATE(cdf, 0.45)
 pctilelow=locs(index)
 index = VALUE_LOCATE(cdf, 0.55)
 pctilehi=locs(index)
 index = VALUE_LOCATE(cdf, 0.5)
 medval=locs(index)
 robSD=robust_sigma(a);/sqrt(n_elements(a)-1) ; the robust estimate fo SD of the mean
 return
 end
 
 
 PRO getfilterstr,file,filterstr
 openr,77,file
 filterstr=[]
 while not eof(77) do begin
     str=''
     readf,77,str
     filterstr=[filterstr,str]
     endwhile
 close,77
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
 
 
 PRO gomakehisto,a,xtitstr,binw,xra
 common labels,jdstr,filternames
 histo,xtitle=xtitstr,a,min(a),max(a),binw,/abs,title=jdstr+' '+filternames(0)
 xra=!X.crange
 oplot,[median(a),median(a)],[!Y.crange],linestyle=2
 sd=robust_sigma(a)/sqrt(n_elements(a)-1)
 oplot,[median(a)-sd,median(a)-sd],[!Y.crange],linestyle=1
 oplot,[median(a)+sd,median(a)+sd],[!Y.crange],linestyle=1
 x0=min(!X.crange)+0.15*(max(!x.crange)-min(!x.crange));median(a)-2.*robust_sigma(a)
 y0=!y.crange(0)+0.88*(!Y.crange(1)-!Y.crange(0))
 offset=0.13*(max(!Y.crange)-min(!Y.crange))
 xyouts,/data,x0,y0,'Median: '+string(median(a),format='(f8.5)')
 xyouts,/data,x0,y0-offset,'SD: '+string(robust_sigma(a),format='(f8.4)')
 return
 end
 
 PRO godostats,x,y,xstr,ystr,res_slope
 if (total((y-mean(y))^2) eq 0) then begin
	print,'Y is pinned.'
	stop
 endif
;PRO godostats,y,x,ystr,xstr,res_slope
 common labels,jdstr,filternames
 print,'---------------------------------------------------'
 R=correlate(x,y)
 plot,xstyle=3,ystyle=3,x,y,xtitle=xstr,ytitle=ystr,$
 psym=1,charsize=1.7,thick=3,title=jdstr
 res=robust_linefit(x,y,yhat,sig,sigmas)
 res_slope=res(1)
 oplot,x,yhat,color=fsc_color('red')
 xyouts,/data,median(x)-2.*robust_sigma(x),median(y)+1.5*robust_sigma(y),'Slope: '+string(res(1),format='(f6.3)')
 oplot,[median(x),median(x)],[!Y.crange],linestyle=1
 oplot,[!X.crange],[median(y),median(y)],linestyle=1
 return
 end
 
 PRO MOONPHASE,jd,phase_angle_M,alt_moon,alt_sun,obsname
 ;-----------------------------------------------------------------------
 ; Set various constants.
 ;-----------------------------------------------------------------------
 RADEG  = 180.0/!PI
 DRADEG = 180.0D/!DPI
 AU = 149.6d+6       ; median Sun-Earth distance     [km]
 Rearth = 6365.0D    ; Earth radius                [km]
 Rmoon = 1737.4D     ; Moon radius                 [km]
 Dse = AU            ; default Sun-Earth distance  [km]
 Dem = 384400.0D     ; default Earth-Moon distance [km]
 MOONPOS, jd, ra_moon, DECmoon, dis
 distance=dis/6371.
 eq2hor, ra_moon, DECmoon, jd, alt_moon, az_moon, ha_moon,  OBSNAME='mlo';obsname
 SUNPOS, jd, ra_sun, DECsun
 eq2hor, ra_sun, DECsun, jd, alt_sun, az, ha, OBSNAME=obsname
 RAdiff = ra_moon - ra_sun
 sign = +1
 if (RAdiff GT 180.0) OR (RAdiff LT 0.0 AND RAdiff GT -180.0) then sign = -1
 phase_angle_E = sign*acos( sin(DECsun/DRADEG)*sin(DECmoon/DRADEG) + cos(DECsun/DRADEG)*cos(DECmoon/DRADEG)*cos(RAdiff/DRADEG) ) * DRADEG
 phase_angle_M = -atan( Dse*sin(phase_angle_E/DRADEG), Dem - Dse*cos(phase_angle_E/DRADEG) ) * DRADEG
 return
 end
 
 
 PRO getphasefromJD,JD,phase
 MOONPHASE,jd(0),phase_angle_M,alt_moon,alt_sun,obsname
 phase=phase_angle_M
 return
 end
 
 PRO gofinduniqueJDs,JD,uniqueJDs,nJDs
 JDs=JD(sort(JD))
 JDs=JDs(uniq(JDs))
 uniqueJDs=JDs
 nJDs=n_elements(uniqueJDs)
 return
 end
 
 PRO gomakeselectable,JD,A,dA,alfa,bpwr,ped,dx,dy,ac,rmse,phasarr,uniqueJDs,nJDs
 JDtemp=[]
 Atemp=[]
 dAtemp=[]
 alfatemp=[]
 bpwrtemp=[]
 pedtemp=[]
 dxtemp=[]
 dytemp=[]
 actemp=[]
 rmsetemp=[]
 phasarrtemp=[]
 for iJD=0,nJDs-1,1 do begin
     idx=where(JD eq uniqueJDs(iJD))
     for j=0,n_elements(idx)-1,1 do begin
         JDtemp=[[JDtemp],[iJD,JD(idx(j))]]
         Atemp=[[Atemp],[iJD,A(idx(j))]]
         dAtemp=[[dAtemp],[iJD,dA(idx(j))]]
         alfatemp=[[alfatemp],[iJD,alfa(idx(j))]]
         bpwrtemp=[[bpwrtemp],[iJD,bpwr(idx(j))]]
         pedtemp=[[pedtemp],[iJD,ped(idx(j))]]
         dxtemp=[[dxtemp],[iJD,dx(idx(j))]]
         dytemp=[[dytemp],[iJD,dy(idx(j))]]
         actemp=[[actemp],[iJD,ac(idx(j))]]
         rmsetemp=[[rmsetemp],[iJD,rmse(idx(j))]]
         phasarrtemp=[[phasarrtemp],[iJD,phasarr(idx(j))]]
         endfor 
     endfor 
 JD=JDTemp
 A=Atemp
 dA=dAtemp
 alfa=alfatemp
 bpwr=bpwrtemp
 ped=pedtemp
 dx=dxtemp
 dy=dytemp
 ac=actemp
 rmse=rmsetemp
 phasarr=phasarrtemp
 return
 end
 
 
 PRO getexptimefromjd,jd,exptime
 file=file_search('/data/pth/DARKCURRENTREDUCED/SELECTED_1/*'+string(jd,format='(f15.7)')+'*')
 im=readfits(file(0),h)
 idx=strpos(h,'EXPOSURE')
 jdx=where(idx ne -1)
 if (jdx eq -1) then stop
 exptime=strmid(h(where(idx ne -1)),11,20)*1.0
 return
 end
 
 
 PRO getalldata,file,JD,A,dA,alfa,bpwr,ped,dx,dy,ac,rmse,phasarr,uniqueJDs,nJDs,filterstr
 spawn,"awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$11}' "+file+"  > hejsa"
 spawn,"awk '{print $18}' "+file+"  > filters"
 data=get_data('hejsa')
 rmse=reform(data(9,*))
 dx=reform(data(6,*))
 dy=reform(data(7,*))
 idx=where(rmse le 0.4 and abs(dx) lt 2 and abs(dy) lt 2)	; filter out the junk
 data=data(*,idx)
 getfilterstr,'filters',filterstr
 filterstr=filterstr(idx)
 JD=reform(data(0,*))
 gofinduniqueJDs,JD,uniqueJDs,nJDs
 A=reform(data(1,*))
 dA=reform(data(2,*))
 alfa=reform(data(3,*))
 bpwr=reform(data(4,*))
 ped=reform(data(5,*))
 dx=reform(data(6,*))
 dy=reform(data(7,*))
 ac=reform(data(8,*))
 rmse=reform(data(9,*))
 phasarr=[]
 for k=0,n_elements(jd)-1,1 do begin
     getphasefromJD,JD(k),phase
     phasarr=[phasarr,phase]
     endfor
 return
 end
 
 ;=================================================
 ; Version 3. Like v1 but has more plots and lists as output.
 ; Cod eplots results from the 'bagging' versions of
 ; CLEM output files
 ;=================================================
 close,/all
 !P.charsize=1.0
 common labels,jdstr,filternames
 get_lun,logfile
 openw,logfile,'logfile'
 get_lun,iuygy
 file='LRO.bootstrapperfitting.txt'
 getalldata,file,JD,A,dA,alfa,bpwr,ped,dx,dy,ac,rmse,phasarr,uniqueJDs,nJDs,filterstr
 openw,88,'uniqjds.dat'
 printf,88,uniqueJDs
 close,88
 ; loop over each JD
 spawn,"cat table.beginning > tabular.tex"
 openw,66,'tabular.tex',/append
 openw,99,'slopes.dat'
	alfasigmas=[]
	pedsigmas=[]
	dxsigmas=[]
	dysigmas=[]
 for i=0,nJDs-1,1 do begin
     print,'iJD: ',i
     idx=where(JD eq uniqueJDs(i))
     N=n_elements(idx)
     if (N ge 3) then begin
         filternames=filterstr(idx)
         !P.MULTI=[0,2,4]
         !P.thick=3
         !P.charsize=1.0
         !P.charthick=2
         ;------------
         jdstr=string(uniqueJDs(i),format='(f15.7)')
         godostats,a(idx),alfa(idx),'Albedo','Alfa',alfasigmas
         godostats,a(idx),ped(idx),'Albedo','pedestal',pedsigmas
;        godostats,a(idx),dx(idx),'Albedo','dx',dxsigmas
;        godostats,a(idx),dy(idx),'Albedo','dy',dysigmas
         print,'---------------------------------------------------'
         ;-------------------------
         ;!P.MULTI=[0,1,2]
         !P.MULTI=[0,2,4]
         IQR=interquartilrange(a(idx))
         binw=(max(a(idx))-min(a(idx)))/19.;2.*IQR*n_elements(a(idx))^(-1./3.)
         gomakehisto,ped(idx),'Pedestal',binw/20.,xra
         gomakehisto,dy(idx),'dy',binw*60.,xra
         gomakehisto,dx(idx),'dx',binw*60.,xra
         gomakehisto,rmse(idx),'RMSE',binw,xra
         gomakehisto,alfa(idx),'Alfa',binw,xra
         gomakehisto,a(idx),'Albedo',binw,xra
         gomakehisto,da(idx),'d Albedo',binw/10.,xra
         ;----------------------------------
         getstats,a(idx),medval,pctilelow,pctilehi,robSD
         fmtstr12='(f15.7,1x,a5,1x,i4,1x,f9.4,1x,g9.4,3(1x,f9.4))'
         fmtstr13='(f15.7,a,a5,a,i4,a,f9.4,a,g9.4,a)'
         openw,iuygy,'MASTER_outputlist_from_bagging.txt',/append
         print,format=fmtstr12,uniqueJDs(i),filternames(0),N,medval,robSD,pctilelow,pctilehi,median(rmse(idx))
         printf,iuygy,format=fmtstr12,uniqueJDs(i),filternames(0),N,medval,robSD,pctilelow,pctilehi,median(rmse(idx))
         printf,66,format=fmtstr13,uniqueJDs(i),' & ',filternames(0),' & ',N,' & ',medval,' & ',robSD,' \\'
         close,iuygy
         free_lun,iuygy
         endif else begin
         print,'Too few results for ',uniqueJDs(i),' - skipping for now.',n
         printf,logfile,'Too few results for ',uniqueJDs(i),' - skipping for now.',n
         endelse
     print,'slopes: ',alfasigmas,pedsigmas
     printf,99,alfasigmas,pedsigmas,dxsigmas,dysigmas
     endfor	; end loop over JD
 close,66
 spawn,"cat table.ending >> tabular.tex"
 ;--------------------------
 close,99
 close,logfile
 free_lun,logfile
 end
