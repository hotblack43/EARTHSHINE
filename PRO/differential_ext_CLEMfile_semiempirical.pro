@stuff117b.pro 
 
;=======================================================================
; 
 close,/all
 
 JDstr='2456045'
 CLEMfile1='CLEM.profiles_fitted_results_SEP_2014_semiempirical.txt'
 spawn,"cat "+CLEMfile1+" | grep "+JDstr+" |  grep _B_ | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14}' > B_data"
 spawn,"cat "+CLEMfile1+" | grep "+JDstr+" |  grep _V_ | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14}' > V_data"
 spawn,"cat "+CLEMfile1+" | grep "+JDstr+" |  grep _IRCUT_ | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14}' > IRCUT_data"
 spawn,"cat "+CLEMfile1+" | grep "+JDstr+" |  grep _VE2_ | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14}' > VE2_data"
 spawn,"cat "+CLEMfile1+" | grep "+JDstr+" |  grep _VE1_ | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14}' > VE1_data"
 
 getstuff,'B_data','JD',JD_B
 getstuff,'V_data','JD',JD_V
 getstuff,'IRCUT_data','JD',JD_IRCUT
 getstuff,'VE2_data','JD',JD_VE2
 getstuff,'VE1_data','JD',JD_VE1
 ;----------------------------------------------------------; 
 am_B=[] & am_V=[] & AM_IRCUT=[] & AM_VE2=[] & AM_VE1=[]
 if (n_elements(JD_B) gt 4) then getAM,JD_B,am_B,lg_B
 if (n_elements(JD_V) gt 4) then getAM,JD_V,am_V,lg_V
 if (n_elements(JD_IRCUT) gt 4) then getAM,JD_IRCUT,am_IRCUT,lg_IRCUT
 if (n_elements(JD_VE2) gt 4) then getAM,JD_VE2,am_VE2,lg_VE2
 if (n_elements(JD_VE1) gt 4) then getAM,JD_VE1,am_VE1,lg_VE1
 print,'-------------------------------------------'
 ;----------------------------------------------------------; 
 !P.MULTI=[0,1,1]
 !P.CHARSIZE=2
 getstuff,'B_data','Albedo',albedo_B
 getstuff,'V_data','Albedo',albedo_V
 getstuff,'IRCUT_data','Albedo',albedo_IRCUT
 getstuff,'VE2_data','Albedo',albedo_VE2
 getstuff,'VE1_data','Albedo',albedo_VE1
;getstuff,'B_data','flux',flux_B
;getstuff,'V_data','flux',flux_V
;getstuff,'IRCUT_data','flux',flux_IRCUT
;getstuff,'VE2_data','flux',flux_VE2
;getstuff,'VE1_data','flux',flux_VE1
;getstuff,'B_data','lamda0',lamda0_B
;getstuff,'V_data','lamda0',lamda0_V
;getstuff,'IRCUT_data','lamda0',lamda0_IRCUT
;getstuff,'VE2_data','lamda0',lamda0_VE2
;getstuff,'VE1_data','lamda0',lamda0_VE1
 print,'-------------------------------------------'
 ; go print and fit against airmass
 zz=[am_B,am_V,AM_IRCUT,AM_VE2,AM_VE1]
;zzflu=[flux_B,flux_V,flux_IRCUT,flux_VE2,flux_VE1]
 zzz=[albedo_B,albedo_V,albedo_IRCUT,albedo_VE2,albedo_VE1]
 zzalb=zzz
;zzlamda0=[lamda0_B,lamda0_V,lamda0_IRCUT,lamda0_VE2,lamda0_VE1]
 if_diagnosticplots=0
 if (if_diagnosticplots eq 1) then begin
     plot,zzalb,zzflu,psym=7,xtitle='Terrestrial Albedo',ytitle='Flux [cts/s]',title=JDstr
     oplot,albedo_B,flux_B,psym=7,color=fsc_color('blue')
     oplot,albedo_V,flux_V,psym=7,color=fsc_color('green')
     oplot,albedo_IRCUT,flux_IRCUT,psym=7,color=fsc_color('orange')
     oplot,albedo_VE2,flux_VE2,psym=7,color=fsc_color('brown')
     oplot,albedo_VE1,flux_VE1,psym=7,color=fsc_color('red')
     a=get_kbrd()
     plot,zzlamda0,zzflu,psym=7,xtitle='Lamda0',ytitle='Flux [cts/s]',title=JDstr
     oplot,lamda0_B,flux_B,psym=7,color=fsc_color('blue')
     oplot,lamda0_V,flux_V,psym=7,color=fsc_color('green')
     oplot,lamda0_IRCUT,flux_IRCUT,psym=7,color=fsc_color('orange')
     oplot,lamda0_VE2,flux_VE2,psym=7,color=fsc_color('brown')
     oplot,lamda0_VE1,flux_VE1,psym=7,color=fsc_color('red')
     a=get_kbrd()
     endif
 plot,xtitle='Airmass',ytitle='-2.5*alog10(Albedo)',zz,-2.5*alog10(zzz),psym=7,ystyle=3,yrange=[0.95,1.71],title=JDstr
 print,'B:'
 strB=' -- '
 if (n_elements(JD_B) gt 4) then gooplot,am_B,-2.5*alog10(albedo_B),'blue',strB
 print,n_elements(albedo_B)
 print,'-------------------------------------------'
 print,'V:'
 strV=' -- '
 if (n_elements(JD_V) gt 4) then gooplot,am_V,-2.5*alog10(albedo_V),'green',strV
 print,n_elements(albedo_V)
 print,'-------------------------------------------'
 print,'IRCUT:'
 strIRCUT=' -- '
 if (n_elements(JD_IRCUT) gt 4) then gooplot,am_IRCUT,-2.5*alog10(albedo_IRCUT),'orange',strIRCUT
 print,n_elements(albedo_IRCUT)
 print,'-------------------------------------------'
 print,'VE1:'
 strVE1=' -- '
 if (n_elements(JD_VE1) gt 4) then gooplot,am_VE1,-2.5*alog10(albedo_VE1),'brown',strVE1
 print,n_elements(albedo_VE1)
 print,'-------------------------------------------'
 print,'VE2:'
 strVE2=' -- '
 if (n_elements(JD_VE2) gt 4) then gooplot,am_VE2,-2.5*alog10(albedo_VE2),'red',strVE2
 print,n_elements(albedo_VE2)
 print,'-------------------------------------------'
 print,'JD    &   B    &                   V   &                          IRCUT   &                     VE1 & VE2 \\ '
 print,JDstr+'&'+strB+'&'+strV+'&'+strIRCUT+'&'+strVE1+'&'+strVE2+'& \\' 
 ;
 end
