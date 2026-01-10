@stuff117a.pro 
 ; 
;---------------------------------------------------
 common flags,smallAMansr
 common flags_meteoro,mlo_flag,jdmetcorr,meteo_pressure,temp_at_10m
 common ifwantmeteocorr,if_meteo_correct
 mlo_flag=-911
 if_meteo_correct=1
 close,/all
 if_diagnosticplots=1
 
;JDstr='2456016'
;CLEMfile1='CLEM.testing_NOV02_2014_JD2456016.txt'
;JDstr='2456017'
;CLEMfile1='CLEM.testing_NOV06_2014_JD2456017.txt'
 JDstr='2456073'
 CLEMfile1='CLEM.testing_NOV14_2014_JD2456073.txt'
 JDstr='2456074'
 CLEMfile1='CLEM.testing_NOV18_2014_JD2456074.txt'
 JDstr='2456075'
 CLEMfile1='CLEM.testing_NOV19_2014_JD2456075.txt'
 JDstr='2456076'
 CLEMfile1='CLEM.testing_NOV27_2014_JD2456076.txt'
;read,ansr,prompt='Do you want the special selection for albedo<2 ?' 
 ansr=0
 smallAMansr=0
 if_want_RMSE_selection=1
;read,smallAMansr,prompt='Do you want to select for airmass < 2 ?'
 if (smallAMansr eq 1) then begin
 gomakefilewithJDsforairmasslessthan2,CLEMfile1
 spawn,"grep -f JDsforAMlessthan2 "+CLEMfile1+" > aha17"
 CLEMfile1='aha17'
 endif
 spawn,'rm B_data V_data IRCUT_data VE2_data VE1_data'
 if (if_want_RMSE_selection eq 0) then begin
 spawn,"cat "+CLEMfile1+" | grep "+JDstr+" | grep sum_of_100 | grep _B_ | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15}' > B_data"
 spawn,"cat "+CLEMfile1+" | grep "+JDstr+" | grep sum_of_100 | grep _V_ | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15}' > V_data"
 spawn,"cat "+CLEMfile1+" | grep "+JDstr+" | grep sum_of_100 | grep _IRCUT_ | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15}' > IRCUT_data"
 spawn,"cat "+CLEMfile1+" | grep "+JDstr+" | grep sum_of_100 | grep _VE2_ | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15}' > VE2_data"
 spawn,"cat "+CLEMfile1+" | grep "+JDstr+" | grep sum_of_100 | grep _VE1_ | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15}' > VE1_data"
 endif
 if (if_want_RMSE_selection eq 1) then begin
 RMSE_limit='0.1'
 spawn,"cat "+CLEMfile1+" | grep "+JDstr+" | grep sum_of_100 | grep _B_ | awk '$11 < "+RMSE_limit+"{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15}' > B_data"
 spawn,"cat "+CLEMfile1+" | grep "+JDstr+" | grep sum_of_100 | grep _V_ | awk '$11 < "+RMSE_limit+"{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15}' > V_data"
 spawn,"cat "+CLEMfile1+" | grep "+JDstr+" | grep sum_of_100 | grep _IRCUT_ | awk '$11 < "+RMSE_limit+"{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15}' > IRCUT_data"
 spawn,"cat "+CLEMfile1+" | grep "+JDstr+" | grep sum_of_100 | grep _VE2_ | awk '$11 < "+RMSE_limit+"{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15}' > VE2_data"
 spawn,"cat "+CLEMfile1+" | grep "+JDstr+" | grep sum_of_100 | grep _VE1_ | awk '$11 < "+RMSE_limit+"{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15}' > VE1_data"
 endif

openw,22,strcompress('extinction_JD'+JDstr+'.dat',/remove_all)
printf,22,JDstr+' & '

 t_B=((file_info('B_data')).(1) eq 1)*((file_info('B_data')).(20) ne 0)
 t_V=((file_info('V_data')).(1) eq 1)*((file_info('V_data')).(20) ne 0)
 t_VE1=((file_info('VE1_data')).(1) eq 1)*((file_info('VE1_data')).(20) ne 0)
 t_VE2=((file_info('VE2_data')).(1) eq 1)*((file_info('VE2_data')).(20) ne 0)
 t_IRCUT=((file_info('IRCUT_data')).(1) eq 1)*((file_info('IRCUT_data')).(20) ne 0)
 ;t_IRCUT=0
 print,'File tests: ',t_b,t_v,t_VE1,t_VE2,t_IRCUT
 
 am_B=[] & am_V=[] & AM_IRCUT=[] & AM_VE2=[] & AM_VE1=[]
 contrast_B=[] & contrast_V=[] & contrast_IRCUT=[] & contrast_VE2=[] & contrast_VE1=[]
 flux_B=[] & flux_V=[] & flux_IRCUT=[] & flux_VE2=[] & flux_VE1=[]
 albedo_B=[] & albedo_V=[] & albedo_IRCUT=[] & albedo_VE2=[] & albedo_VE1=[]
 d_albedo_B=[] & d_albedo_V=[] & d_albedo_IRCUT=[] & d_albedo_VE2=[] & d_albedo_VE1=[]
 
 spawn,"awk '{print $16}' "+CLEMfile1+" > namefil"
 ;----------------------------------------------------------; 
 
 print,'-------------------------------------------'
 ;----------------------------------------------------------; 
 !P.MULTI=[0,1,3]
 !P.CHARSIZE=2
 m0=26
 if (t_B eq 1) then begin
     print,'reading B_data'
     getstuff,'B_data','JD',JD_B
     n_B=n_elements(JD_B)
     getstuff,'B_data','Albedo',albedo_B
     getstuff,'B_data','Delta Albedo',d_albedo_B
     getstuff,'B_data','flux',flux_B
     getstuff,'B_data','contrast',contrast_B
     if (n_B gt 4) then begin
	getAM,JD_B,am_B,lg_B
     	m_B=-2.5*alog10(flux_b)+m0
     endif
     endif
 if (t_IRCUT eq 1) then begin
     print,'reading IRCUT_data'
     getstuff,'IRCUT_data','JD',JD_IRCUT
     n_IRCUT=n_elements(JD_IRCUT)
     getstuff,'IRCUT_data','Albedo',albedo_IRCUT
     getstuff,'IRCUT_data','Delta Albedo',d_albedo_IRCUT
     getstuff,'IRCUT_data','flux',flux_IRCUT
     getstuff,'IRCUT_data','contrast',contrast_IRCUT
     if (n_IRCUT gt 4) then begin
	 getAM,JD_IRCUT,am_IRCUT,lg_IRCUT
     	m_ircut=-2.5*alog10(flux_ircut)+m0
     endif
     endif
 if (t_V eq 1) then begin
     print,'reading V_data'
     getstuff,'V_data','JD',JD_V
     n_V=n_elements(JD_V)
     getstuff,'V_data','Albedo',albedo_V
     getstuff,'V_data','Delta Albedo',d_albedo_V
     getstuff,'V_data','flux',flux_V
     getstuff,'V_data','contrast',contrast_V
     if (n_V gt 4) then getAM,JD_V,am_V,lg_V
     m_v=-2.5*alog10(flux_v)+m0
     endif
 if (t_VE1 eq 1) then begin
     print,'reading VE1_data'
     getstuff,'VE1_data','JD',JD_VE1
     n_VE1=n_elements(JD_VE1)
     getstuff,'VE1_data','Albedo',albedo_VE1
     getstuff,'VE1_data','Delta Albedo',d_albedo_VE1
     getstuff,'VE1_data','flux',flux_VE1
     getstuff,'VE1_data','contrast',contrast_VE1
     if (n_VE1 gt 4) then getAM,JD_VE1,am_VE1,lg_VE1
     m_ve1=-2.5*alog10(flux_ve1)+m0
     endif
 if (t_VE2 eq 1) then begin
     print,'reading VE2_data'
     getstuff,'VE2_data','JD',JD_VE2
     n_VE2=n_elements(JD_VE2)
     getstuff,'VE2_data','Albedo',albedo_VE2
     getstuff,'VE2_data','Delta Albedo',d_albedo_VE2
     getstuff,'VE2_data','flux',flux_VE2
     getstuff,'VE2_data','contrast',contrast_VE2
     if (n_VE2 gt 4) then getAM,JD_VE2,am_VE2,lg_VE2
     m_ve2=-2.5*alog10(flux_ve2)+m0
     endif
 if (t_B eq 1) then print,'n_B : ',n_B
 if (t_V eq 1) then print,'n_V : ',n_V
 if (t_VE1 eq 1) then print,'n_VE1 : ',n_VE1
 if (t_VE2 eq 1) then print,'n_VE2 : ',n_VE2
 if (t_IRCUT eq 1) then print,'n_IRCUT : ',n_IRCUT
 
 print,'-------------------------------------------'
 ; go print and fit against airmass
 zz=[am_B,am_V,AM_IRCUT,AM_VE2,AM_VE1]
 zzflu=[flux_B,flux_V,flux_IRCUT,flux_VE2,flux_VE1]
 zzz=[albedo_B,albedo_V,albedo_IRCUT,albedo_VE2,albedo_VE1]
 dzzz=[d_albedo_B,d_albedo_V,d_albedo_IRCUT,d_albedo_VE2,d_albedo_VE1]
 zzalb=zzz
 zzcontrast=[contrast_B,contrast_V,contrast_IRCUT,contrast_VE2,contrast_VE1]
 if (if_diagnosticplots eq 1) then begin
     plot,zzalb,zzflu,psym=3,xtitle='Terrestrial Albedo',ytitle='Flux [cts/s]',title=JDstr,ystyle=3
     if (t_b eq 1) then oplot,albedo_B,flux_B,psym=7,color=fsc_color('blue')
     if (t_v eq 1) then oplot,albedo_V,flux_V,psym=7,color=fsc_color('green')
     if (t_ircut eq 1) then oplot,albedo_IRCUT,flux_IRCUT,psym=1,color=fsc_color('red')
     if (t_ve1 eq 1) then oplot,albedo_VE1,flux_VE1,psym=7,color=fsc_color('orange')
     if (t_ve2 eq 1) then oplot,albedo_VE2,flux_VE2,psym=7,color=fsc_color('brown')
     ;    a=get_kbrd()
          plot,/nodata,zz,[randomu(seed,n_elements(zz))],yrange=[-0.2,0.2],psym=3,xtitle='Airmass',ytitle='-2.5*alog10(flux)',title=JDstr,ystyle=3
          if (t_b eq 1) then gooplot2,am_b,m_B,'blue',' B ',7
          if (t_v eq 1) then gooplot2,am_v,m_V,'green',' V ',7
          if (t_ircut eq 1) then gooplot2,am_IRCUT,m_IRCUT,'red',' IRCUT ',7
          if (t_ve1 eq 1) then gooplot2,am_VE1,m_VE1,'orange',' VE1 ',1
          if (t_ve2 eq 1) then gooplot2,am_VE2,m_VE2,'brown',' VE2 ',7
          print,'---------------------------------------------------'
     ;    a=get_kbrd()
     endif
 plot,xrange=[0,max(zz)],xtitle='Airmass',ytitle='-2.5*alog10(Albedo)',zz,-2.5*alog10(zzz),psym=3,ystyle=3,title=JDstr,yrange=[0.5,1.71]
 print,'B: blue'
 strB=' -- '
 if (n_elements(JD_B) gt 4) then gooplot,am_B,-2.5*alog10(albedo_B),'blue',strB,7
 print,n_elements(albedo_B)
 print,'-------------------------------------------'
 print,'IRCUT: red'
 strIRCUT=' -- '
 if (n_elements(JD_IRCUT) gt 4) then gooplot,am_IRCUT,-2.5*alog10(albedo_IRCUT),'red',strIRCUT,7
 print,n_elements(albedo_IRCUT)
 print,'-------------------------------------------'
 print,'VE1: orange'
 strVE1=' -- '
 if (n_elements(JD_VE1) gt 4) then gooplot,am_VE1,-2.5*alog10(albedo_VE1),'orange',strVE1,1
 print,n_elements(albedo_VE1)
 print,'-------------------------------------------'
 print,'VE2: brown'
 strVE2=' -- '
 if (n_elements(JD_VE2) gt 4) then gooplot,am_VE2,-2.5*alog10(albedo_VE2),'brown',strVE2,7
 print,n_elements(albedo_VE2)
 print,'-------------------------------------------'
 print,'V: green'
 strV=' -- '
 if (n_elements(JD_V) gt 4) then gooplot,am_V,-2.5*alog10(albedo_V),'green',strV,7
 print,n_elements(albedo_V)
 print,'-------------------------------------------'
 print,'JD    &   B    &                   V   &                          IRCUT   &                     VE1 & VE2 \\ '
 print,JDstr+'&'+strB+'&'+strV+'&'+strIRCUT+'&'+strVE1+'&'+strVE2+'& \\' 
 printf,22,'\\'
 close,22
 ;
 end
