PRO gogetregression2,jd,x,y,xx,yy
 fscolor=['red','blue','orange','black','green','brown']
 ; get unique JDs
 jdl=long(jd)
 uniqJD=jdl(uniq(jdl,sort(jdl)))
 for k=0,n_elements(uniqJD)-1,1 do begin
     ldx=where(jdl eq uniqJD(k))
     if (n_elements(ldx) ge 5) then begin
         Rxx=x(ldx) 
         Ryy=y(ldx)
         ;res=ladfit(Rxx,Ryy)
         res=robust_linefit(Rxx,Ryy,yhat,sig,sigs)
         oplot,Rxx,Ryy,psym=6,color=fsc_color(fscolor(k mod 6))
         Rxx=findgen(101)/float(100)*(max(x(ldx) )-min(x(ldx) ))+min(x(ldx) )
         yhat=res(0)+res(1)*Rxx
         print,'one-day slope: ',uniqJD(k),' is ',res(1),' albd./day. N=',n_elements(ldx),' colour: ',fscolor(k mod 6)
         oplot,Rxx,yhat,color=fsc_color(fscolor(k mod 6))
         endif
     endfor
 return
 end
 
 PRO gogetregression,jd,x,y,xx,yy,iband
 ; get unique JDs
 jdl=long(jd)
 uniqJD=jdl(uniq(jdl,sort(jdl)))
 fscolor=['red','blue','orange','black','green','brown']
 for k=0,n_elements(uniqJD)-1,1 do begin
     ldx=where(jdl eq uniqJD(k))
     if (n_elements(ldx) ge 5) then begin
         Rxx=x(ldx)
         Ryy=y(ldx)
         ;res=ladfit(Rxx,Ryy)
         res=robust_linefit(Rxx,Ryy,yhat,sig,sigs)
         oplot,Rxx,Ryy,psym=6,color=fsc_color(fscolor(k mod 6))
         Rxx=findgen(101)/float(100)*(max(x(ldx))-min(x(ldx)))+min(x(ldx))
         yhat=res(0)+res(1)*Rxx
	 printf,56,format='(i10,4(1x,f9.5),2(1x,i4))',uniqJD(k),res(0),sigs(0),res(1),sigs(1),n_elements(ldx),iband
         print,'Zero ext alb.: ',res(0),' slope: ',uniqJD(k),' ',res(1),' alb./airmass. N=',n_elements(ldx),' colour: ',fscolor(k mod 6)
         oplot,Rxx,yhat,color=fsc_color(fscolor(k mod 6))
         endif
     endfor
 return
 end
 
 PRO get_am_fromJD,JD,am
 obsname='mlo'
 observatory,obsname,obs_struct
 lat=obs_struct.latitude
 lon=obs_struct.longitude
 ; get the phase and azimuth
 ; get the airmass
 moonpos, JD, RAmoon, DECmoon
 am = airmass(JD, RAmoon*!dtor, DECmoon*!dtor, lat*!dtor, lon*!dtor)
 return
 end
 
 PRO get_filter_from_JD,JD,filterstr,filternumber
 filternames=['B','V','VE1','VE2','IRCUT'] 
 filternumbers=indgen(n_elements(filternames))
 file='JD_and_filter.txt'
 spawn,"grep "+string(JD,format='(f15.7)')+" "+file+" > hkjgvghjkv"
 openr,22,'hkjgvghjkv'
 str=''
 readf,22,str
 close,22
 bits=strsplit(str,' ',/extract)
 JDfound=double(bits(0))
 filterstr=bits(1)
 if (abs(JD - JDfound) gt 1e-6) then stop
 filternumber=filternumbers(where(filternames eq filterstr))
 return
 end
 
 
 ;---------------------------------------------------
 ;
 ;
 filternames=['B','V','VE1','VE2','IRCUT'] 
 print,'-------------------------------------------------------------------'
 openw,56,'albedo_extinctions.dat'
 for iband=0,4,1 do begin
     print,'Band: ',filternames(iband)
     data=get_data('JDandalbedos.dat')
     alb1=reform(data(1,*))
     alb2=reform(data(2,*))
     pct=(alb1-alb2)/(0.5*(alb1+alb2))*100.
     idx=where(abs(pct) lt 2 and alb1 ne 0 and alb2 ne 0)
     data=data(*,idx)
     datanew=[]
     for k=0,n_elements(data(0,*))-1,1 do begin
         get_am_fromJD,reform(data(0,k)),amitem
         get_filter_from_JD,reform(data(0,k)),filtername,filternum
         datanew=[[datanew],[data(*,k),amitem,filternum]]
         endfor
     filterstr=filternames(iband)
     jdx=where(datanew(4,*) eq iband)
     if(n_elements(jdx) ge 2) then begin
     data=datanew(*,jdx)
     JD=reform(data(0,*))
     alb1=reform(data(1,*))
     alb2=reform(data(2,*))
     am=reform(data(3,*))
     pct=(alb1-alb2)/(0.5*(alb1+alb2))*100.
 ;-------------------------------
     pcolor=!P.color
     set_plot,'ps'
     device,/color
     decomposed=0
     device,filename='pct_vs_frJD_'+filterstr+'.ps'
     plot,JD mod 1,pct,psym=7,xtitle='Fractional JD',ytitle='% change in albedo',xstyle=3,ystyle=3,title='Change due to yes/no ZL+SL'
     oplot,[!X.crange],[0,0],linestyle=1
     idx=where((jd mod 1) lt 0.5)
     if (n_elements(idx) gt 2) then begin
         oplot,jd(idx) mod 1,pct(idx),psym=7,color=fsc_color('red')
         print,'SD of morning: ',stddev(pct(idx))
         endif
     idx=where((JD  mod 1) ge 0.5)
     if (n_elements(idx) gt 2) then begin
         oplot,jd mod 1,pct,psym=7,color=fsc_color('blue')
         print,'SD of evening: ',stddev(pct(idx))
         endif
     device,/close
 ;.....................
     set_plot,'ps'
     device,/color
     decomposed=0
     device,filename='pct_histo_'+filterstr+'.ps'
     !P.color=pcolor
     cgHistoplot,thick=3, pct, BINSIZE=0.096543,/line_fill,orientation=45,polycolor='black',xtitle='!7D!3 Albedo [%]'
     idx=where((jd mod 1) gt 0.5)
     cgHistoplot,pct(idx),BINSIZE=0.051543,/oplot,/fill,polycolor='blue'
     idx=where((JD mod 1) lt 0.5)
     cgHistoplot,pct(idx),BINSIZE=0.065543,/oplot,/fill,polycolor='red'
     oplot,[0,0],[!Y.crange],linestyle=2
     print,'Number of duplicates: ',n_elements(pct)
     print,float(n_elements(where(pct gt 0)))/n_elements(pct)*100.,' % have positive change'
     print,'Median change: ',median(pct)
     print,'SD           : ',stddev(pct)
     print,float(n_elements(where(pct gt 0.2)))/n_elements(pct)*100.,' % have change gt 0.2%'
     xyouts,0.6,30,'Median : '+string(median(pct),format='(f5.2)'),charsize=1.4
     xyouts,0.6,28,'SD : '+string(stddev(pct),format='(f5.1)'),charsize=1.4
     signature,pos=[0.6,-0.7],'made with /SCI/EARTHSHINE/make_histo.pro'
     device,/close
 ;.....................
     set_plot,'ps'
     device,/color
     decomposed=0
     device,filename='pct_vs_am_'+filterstr+'.ps'
     ; morning
     idx=where((JD mod 1) lt 0.5)
     plot,/nodata,yrange=[-2,2],xstyle=3,ystyle=3,xrange=[1,8.5],am(idx),pct(idx),psym=7,xtitle='Airmass',ytitle='% albedo change',title='Change due to yes/no ZL+SL'
     oplot,color=fsc_color('red'),am(idx),pct(idx),psym=7
     res=ladfit(am(idx),pct(idx))
     yhat=res(0)+res(1)*am(idx)
     oplot,am(idx),yhat,color=fsc_color('red')
     ; evening
     idx=where((JD mod 1) gt 0.5)
     oplot,color=fsc_color('blue'),am(idx),pct(idx),psym=7
     res=ladfit(am(idx),pct(idx))
     yhat=res(0)+res(1)*am(idx)
     oplot,am(idx),yhat,color=fsc_color('blue')
     device,/close
 ;..................
     set_plot,'ps'
     device,/color,filename='albedo_vs_fracJD_'+filterstr+'.ps'
     decomposed=0
     plot,xstyle=3,ystyle=3,JD mod 1,(alb1+alb2)/2.,psym=7,xtitle='Fractional JD',ytitle='Albedo',title=filterstr,yrange=[0.18,0.5]
     gogetregression2,jd,jd mod 1,((alb1+alb2)/2.),xx,yy
     device,/close
 ;.....................
     device,/color,filename='albedo_vs_am_'+filterstr+'.ps'
     decomposed=0
     plot,xstyle=3,ystyle=3,am,(alb1+alb2)/2.,psym=7,xtitle='Airmass',ytitle='Albedo',title=filterstr,yrange=[0.18,0.5]
     gogetregression,jd,am,((alb1+alb2)/2.),xx,yy,iband
     yyy=(!Y.crange(1)-!Y.crange(0))*0.8+!Y.crange(0)
     device,/close
     print,'-------------------------------------------------------------------'
     endif
     endfor
 close,56
 end
