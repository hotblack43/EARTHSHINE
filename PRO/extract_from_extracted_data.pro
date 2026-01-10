PRO getFouraday,B_ratio,V_ratio,BVexcess,itype,jd
 ; itype=1 meaqns get B-V
 ; itype=2 means get VE1-VE2
 file='B_V_VE1_VE2_means.dat'
 data=get_data(file)
 jd=long(reform(data(0,*)))
 ratio=reform(data(1,*))
 FFMalbedo=reform(data(2,*))
 type=reform(data(3,*))
 days=jd(uniq(jd(sort(jd))))
 if (itype eq 1) then begin
     ; look for days with 1 and 2 - i.e. B and V data
     for i=0,n_elements(days)-1,1 do begin
         idx=where(jd eq days(i) and type eq 1)
         jdx=where(jd eq days(i) and type eq 2)
         if (idx(0) ne -1 and jdx(0) ne -1) then begin
             bval=B_ratio(idx) & vval=V_ratio(jdx)
             getExcesses,bval,vval,BVexcess
             print,format='(a,i10,1x,f9.3)','    B-V excess :',jd(idx),BVexcess
             endif
         endfor
     endif
 if (itype eq 2) then begin
     ; look for days with 3 and 4 - i.e. VE1 and VE2  data
     for i=0,n_elements(days)-1,1 do begin
         idx=where(jd eq days(i) and type eq 3)
         jdx=where(jd eq days(i) and type eq 4)
         if (idx(0) ne -1 and jdx(0) ne -1) then begin
             bval=B_ratio(idx) & vval=V_ratio(jdx)
             getExcesses,bval,vval,BVexcess
             print,format='(a,i10,1x,f9.3)','VE1-VE2 excess :',jd(idx),BVexcess
             endif
         endfor
     endif
 return
 end
 
 PRO getdailymeans,B_ratio,Balbedo,Bjd
 ; returns the daily menas of the arrays given
 ; find the unique days available
 get_lun,uw
 openw,uw,'tempo.dat'
 longJD=long(Bjd) & longJD=longJD(sort(longJD)) & longJD=longJD(uniq(longJD))
 for i=0,n_elements(longJD)-1,1 do begin
     idx=where(long(Bjd) eq longJD(i))
     if (n_elements(idx) ge 3) then begin
         B_ratio_mean=median(B_ratio(idx))
         helper=Balbedo(idx) & helper=helper(where(helper lt 1))
         if (n_elements(helper) gt 1) then Balbedo_mean=mean(helper)
         if (n_elements(helper) le 1) then Balbedo_mean=911.999
         Bjd_value=long(Bjd(where(B_ratio eq B_ratio_mean)))
         printf,uw,format='(f20.7,2(1x,g20.10))',Bjd_value(0),B_ratio_mean,Balbedo_mean
         endif
     endfor
 close,uw
 free_lun,uw
 data=get_data('tempo.dat')
 Bjd=reform(data(0,*))
 B_ratio=reform(data(1,*))
 Balbedo=reform(data(2,*))
 return
 end
 
 PRO getExcesses,B_ratio,V_ratio,BVexcess
 ; get good robust averages of the data
 BVexcess=-2.5*alog10(B_ratio)-(-2.5*alog10(V_ratio))
 return
 end
 
 
 PRO gettit,data,jd,BSbbsolin,TOTbbsolin,DS45bbsolin,BSbbsolog,TOTbbsolog,DS45bbsolog,BSefm,TOTefm,DS45efm,BSffmTrial,TOTffmTrial,DS45ffmTrial,BSffmResid,TOTffmResid,DS45ffmResid,exptime,am,ratio,FFMalbedo
 jd=reform(data(0,*))
 idx=sort(jd)
 data=data(*,idx)
 jd=reform(data(0,*))
 ;
 BSbbsolin=reform(data(1,*))
 TOTbbsolin=reform(data(2,*))
 DS23bbsolin=reform(data(3,*))
 DS45bbsolin=reform(data(4,*))
 ;
 BSbbsolog=reform(data(5,*))
 TOTbbsolog=reform(data(6,*))
 DS23bbsolog=reform(data(7,*))
 DS45bbsolog=reform(data(8,*))
 ;
 BSefm=reform(data(9,*))
 TOTefm=reform(data(10,*))
 DS23efm=reform(data(11,*))
 DS45efm=reform(data(12,*))
 ;
 BSffmTrial=reform(data(13,*))
 TOTffmTrial=reform(data(14,*))
 DS23ffmTrial=reform(data(15,*))
 DS45ffmTrial=reform(data(16,*))
 ;
 BSffmResid=reform(data(17,*))
 TOTffmResid=reform(data(18,*))
 DS23ffmResid=reform(data(19,*))
 DS45ffmResid=reform(data(20,*))
 ;
 exptime=reform(data(21,*))
 am=reform(data(22,*))
 FFMalbedo=reform(data(23,*))
 ; calculate ratios
 DS=DS45ffmTrial+DS45ffmResid
 BS=TOTffmTrial
 ratio=DS/BS
 ;
 ; select good data
 jdx=where(DS45bbsolin gt 0. and DS45bbsolog gt 0. and DS45efm gt 0. and (DS45ffmTrial+DS45ffmResid) gt 0. and ratio lt 1000)
 ratio=ratio(jdx)
 jd=jd(jdx)
 am=am(jdx)
 exptime=exptime(jdx)
 FFMalbedo=FFMalbedo(jdx)
 help,jdx
 return
 end
 
 
 
 !P.MULTI=[0,2,3]
 !P.THICK=2
 !x.THICK=2
 !y.THICK=2
 filternames=['_B_','_V_','_VE1_','_VE2_','_IRCUT_']
 for ifilter=0,n_elements(filternames)-1,1 do begin
     filtername=filternames(ifilter)
     str="grep "+filtername+" extracted_data_compiled.dat | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24}' > "+strcompress(filtername+'_compileddata.dat',/remove_all)
     spawn,str
     data=get_data(strcompress(filtername+'_compileddata.dat',/remove_all))
     filtername=strmid(filtername,1,strlen(filtername)-2)
     jd=reform(data(0,*))
     idx=sort(jd)
     data=data(*,idx)
     jd=reform(data(0,*))
     ;
     BSbbsolin=reform(data(1,*))
     TOTbbsolin=reform(data(2,*))
     DS23bbsolin=reform(data(3,*))
     DS45bbsolin=reform(data(4,*))
     ;
     BSbbsolog=reform(data(5,*))
     TOTbbsolog=reform(data(6,*))
     DS23bbsolog=reform(data(7,*))
     DS45bbsolog=reform(data(8,*))
     ;
     BSefm=reform(data(9,*))
     TOTefm=reform(data(10,*))
     DS23efm=reform(data(11,*))
     DS45efm=reform(data(12,*))
     ;
     BSffmTrial=reform(data(13,*))
     TOTffmTrial=reform(data(14,*))
     DS23ffmTrial=reform(data(15,*))
     DS45ffmTrial=reform(data(16,*))
     ;
     BSffmResid=reform(data(17,*))
     TOTffmResid=reform(data(18,*))
     DS23ffmResid=reform(data(19,*))
     DS45ffmResid=reform(data(20,*))
     ;
     exptime=reform(data(21,*))
     am=reform(data(22,*))
; and the FFM albedo determined directly from fit
     FFMalbedo=reform(data(23,*))
     ;
     ;
     albedo_LIN=DS45bbsolin/TOTbbsolin
     factor=100./mean(albedo_LIN)
     albedo_LIN=albedo_LIN*factor
     albedo_LOG=DS45bbsolog/TOTbbsolog*factor
     albedo_EFM=DS45efm/TOTefm*factor
     albedo_FFM=(DS45ffmTrial+DS45ffmResid)/TOTffmTrial*factor
     ; select good data
     ratlim=10000
     jdx=where(DS45bbsolin gt 0. and DS45bbsolog gt 0. and DS45efm gt 0. and (DS45ffmTrial+DS45ffmResid) gt 0 and (albedo_LIN lt ratlim and albedo_LOG lt ratlim and albedo_EFM lt ratlim and albedo_FFM lt ratlim))
     albedo_LIN=albedo_LIN(jdx)
     albedo_LOG=albedo_LOG(jdx)
     albedo_EFM=albedo_EFM(jdx)
     albedo_FFM=albedo_FFM(jdx)
     exptime=exptime(jdx)
     am=am(jdx)
     jd=jd(jdx)
     FFMalbedo=FFMalbedo(jdx)
     ;
     fracday=jd-long(jd)
     fracday=jd-long(min(jd))
     ;
     plot,/nodata,title=filtername,fracday,albedo_LIN,xstyle=3,ystyle=3,charsize=2,psym=-7,xtitle='fractional JD',ytitle='DS/tot Arb. Units';,yrange=[10,230],xrange=[0.06,9.18]
     oplot,fracday,albedo_LIN,psym=-7,color=fsc_color('red')
     oplot,fracday,albedo_LOG,psym=-6,color=fsc_color('red')
     oplot,fracday,albedo_EFM,psym=-5,color=fsc_color('blue')
     oplot,fracday,albedo_FFM,psym=-4,color=fsc_color('blue')
     ;oplot,eJD-long(eJD),100.*DSTOTsynt/mean(DSTOTsynt)
     ;
     res=linfit(fracday,albedo_LIN,/double,yfit=yhat) & sd=stddev(albedo_LIN-yhat)/mean(albedo_LIN)*100.
     print,'SD/mean after removing slope LIN :',sd,' % '
     res=linfit(fracday,albedo_LOG,/double,yfit=yhat) & sd=stddev(albedo_LOG-yhat)/mean(albedo_LOG)*100.
     print,'SD/mean after removing slope LOG :',sd,' % '
     res=linfit(fracday,albedo_EFM,/double,yfit=yhat) & sd=stddev(albedo_EFM-yhat)/mean(albedo_EFM)*100.
     print,'SD/mean after removing slope EFM :',sd,' % '
     res=linfit(fracday,albedo_FFM,/double,yfit=yhat) & sd=stddev(albedo_FFM-yhat)/mean(albedo_FFM)*100.
     print,'SD/mean after removing slope FFM :',sd,' % '
     ;
     ifTEX=1
     if (ifTEX ne 1) then begin
         print,'For filter '+filtername+' we get:'
         print,'LINEAR      SD/mean*100 : ',stddev(albedo_LIN)/mean(albedo_LIN)*100.,' % and min/max: ',min(albedo_lin),max(albedo_lin)
         print,'LOGARITHMIC SD/mean*100 : ',stddev(albedo_Log)/mean(albedo_Log)*100.,' % and min/max: ',min(albedo_log),max(albedo_log)
         print,'EFM         SD/mean*100 : ',stddev(albedo_efm)/mean(albedo_efm)*100.,' % and min/max: ',min(albedo_efm),max(albedo_efm)
         print,'FFM         SD/mean*100 : ',stddev(albedo_ffm)/mean(albedo_ffm)*100.,' % and min/max: ',min(albedo_ffm),max(albedo_ffm)
         endif
     ;
     if (ifTEX eq 0) then begin
         if (ifilter eq 0) then begin
             print,'Method  &  B &'
             print,'LINEAR',' & ',string(stddev(albedo_LIN)/mean(albedo_LIN)*100.,format='(f5.2)'),' & '
             print,'LOGARITHMIC',' & ',string(stddev(albedo_Log)/mean(albedo_Log)*100.,format='(f5.2)'),' & '
             print,'EFM',' & ',string(stddev(albedo_efm)/mean(albedo_efm)*100.,format='(f5.2)'),' & '
             print,'FFM',' & ',string(stddev(albedo_ffm)/mean(albedo_ffm)*100.,format='(f5.2)'),' & '
             endif
         if (ifilter gt 0) then begin
             print,'&  '+filtername
             print,string(stddev(albedo_LIN)/mean(albedo_LIN)*100.,format='(f5.2)'),' & '
             print,string(stddev(albedo_Log)/mean(albedo_Log)*100.,format='(f5.2)'),' & '
             print,string(stddev(albedo_efm)/mean(albedo_efm)*100.,format='(f5.2)'),' & '
             print,string(stddev(albedo_ffm)/mean(albedo_ffm)*100.,format='(f5.2)'),' & '
             endif
         endif
     endfor
 plot,fracday,am,ytitle='Airmass',charsize=2,xtitle='JD',psym=-7;,xrange=[0.06,0.18]
 ; now do B-V and VE1-VE2 on DS and TOT or BS
 spawn,"grep _B_ extracted_data_compiled.dat  | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24}'  > Beees.dat"
 spawn,"grep _V_ extracted_data_compiled.dat | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24}'  > Veees.dat"
 spawn,"grep _VE1_ extracted_data_compiled.dat | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24}' > VE1eees.dat"
 spawn,"grep _VE2_ extracted_data_compiled.dat | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23,$24}' > VE2eees.dat"
 ;  B-V DS and BS or TOT
 ; B DS and TOT
 data=get_data('Beees.dat')
 gettit,data,Bjd,BSbbsolin,TOTbbsolin,DS45bbsolin,BSbbsolog,TOTbbsolog,DS45bbsolog,BSefm,TOTefm,DS45efm,BSffmTrial,TOTffmTrial,DS45ffmTrial,BSffmResid,TOTffmResid,DS45ffmResid,exptime,am,B_ratio,FFMalbedoB
 ; V DS and TOT
 data=get_data('Veees.dat')
 gettit,data,Vjd,BSbbsolin,TOTbbsolin,DS45bbsolin,BSbbsolog,TOTbbsolog,DS45bbsolog,BSefm,TOTefm,DS45efm,BSffmTrial,TOTffmTrial,DS45ffmTrial,BSffmResid,TOTffmResid,DS45ffmResid,exptime,am,V_ratio,FFMalbedoV
 ; VE1 DS and TOT
 data=get_data('VE1eees.dat')
 gettit,data,VE1jd,BSbbsolin,TOTbbsolin,DS45bbsolin,BSbbsolog,TOTbbsolog,DS45bbsolog,BSefm,TOTefm,DS45efm,BSffmTrial,TOTffmTrial,DS45ffmTrial,BSffmResid,TOTffmResid,DS45ffmResid,exptime,am,VE1_ratio,FFMalbedoVE1
 ; VE2 DS and TOT
 data=get_data('VE2eees.dat')
 gettit,data,VE2jd,BSbbsolin,TOTbbsolin,DS45bbsolin,BSbbsolog,TOTbbsolog,DS45bbsolog,BSefm,TOTefm,DS45efm,BSffmTrial,TOTffmTrial,DS45ffmTrial,BSffmResid,TOTffmResid,DS45ffmResid,exptime,am,VE2_ratio,FFMalbedoVE2
 ;
 openw,45,'B_V_VE1_VE2_means.dat'
 getdailymeans,B_ratio,FFMalbedoB,Bjd & for k=0,n_elements(Bjd)-1,1 do printf,45,Bjd(k),B_ratio(k),FFMalbedoB(k),1
 getdailymeans,V_ratio,FFMalbedoV,Vjd& for k=0,n_elements(Vjd)-1,1 do printf,45,Vjd(k),V_ratio(k),FFMalbedoV(k),2
 getdailymeans,VE1_ratio,FFMalbedoVE1,VE1jd & for k=0,n_elements(VE1jd)-1,1 do printf,45,VE1jd(k),VE1_ratio(k),FFMalbedoVE1(k),3
 getdailymeans,VE2_ratio,FFMalbedoVE2,VE2jd & for k=0,n_elements(VE2jd)-1,1 do printf,45,VE2jd(k),VE2_ratio(k),FFMalbedoVE2(k),4
 ; Note - above - 1,2,3 and 4 refer to B,V,VE1 and VE2, respectively.
 close,45
 getFouraday,B_ratio,V_ratio,BVexcess,1,jd 
 getFouraday,VE1_ratio,VE2_ratio,VE12excess,2,jd
 end
