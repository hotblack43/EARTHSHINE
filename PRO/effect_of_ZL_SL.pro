PRO histoAlbedochange,filterstr
 !P.CHARSIZE=2.2
 print,'-----------------------------------------------------------'
 openr,1,'data_ZL_SL.'+filterstr
 data2=get_data('data_noZLSLcorr.'+filterstr)
 openw,3,filterstr+'.albedochg'
 while not eof(1) do begin
     str=''
     readf,1,str
     bits=double(strsplit(str,' ',/extract))
     albedo_ZL_SL=bits(1)
     JD=bits(0)
     idx=where(data2(0,*) eq JD)
     if (idx(0) ne -1) then begin
         albedo_none=data2(1,idx(0))
         print,format='(f15.7,3(1x,f9.4))',bits(0),albedo_ZL_SL,albedo_none,(albedo_ZL_SL-albedo_none)/albedo_ZL_SL*100.
         printf,3,(albedo_ZL_SL-albedo_none)/albedo_ZL_SL*100.
         endif
     endwhile
 close,1
 close,3
 name=filterstr+'.albedochg'
 print,name
 dalbedo=get_data(filterstr+'.albedochg')
 histo,dalbedo,min(dalbedo),max(dalbedo),.2,xtitle='% change in '+filterstr+' albedo',/abs
 return
 end
 
 
 ;==================================================================
 fileyesZLSL="CLEM.profiles_fitted_results_multipatch_stacks_25May2014_ZODI_STARL.txt"
 filenoZLSL="CLEM.profiles_fitted_results_SELECTED_5_multipatch_contrFIX_stacks_17May2014.txt"
 ;filenoZLSL="CLEM.profiles_fitted_results_multipatch_stacks_25May2014_ZODIACAL.txt"
 ;
 filterstr='_B_'
 str="grep -f uniqJDs "+fileyesZLSL+" | grep "+filterstr+" | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14}' > data_ZL_SL.B"
 spawn,str
 filterstr='_V_'
 str="grep -f uniqJDs "+fileyesZLSL+" | grep "+filterstr+" | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14}' > data_ZL_SL.V"
 spawn,str
 filterstr='_VE1_'
 str="grep -f uniqJDs "+fileyesZLSL+" | grep "+filterstr+" | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14}' > data_ZL_SL.VE1"
 spawn,str
 filterstr='_VE2_'
 str="grep -f uniqJDs "+fileyesZLSL+" | grep "+filterstr+" | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14}' > data_ZL_SL.VE2"
 spawn,str
 filterstr='_IRCUT_'
 str="grep -f uniqJDs "+fileyesZLSL+" | grep "+filterstr+" | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14}' > data_ZL_SL.IRCUT"
 spawn,str
 ;---------------------------------------------------
 filterstr='_B_'
 str="grep -f uniqJDs "+filenoZLSL+" | grep "+filterstr+" | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12}' > data_noZLSLcorr.B"
 spawn,str
 filterstr='_V_'
 str="grep -f uniqJDs "+filenoZLSL+" | grep "+filterstr+" | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12}' > data_noZLSLcorr.V"
 spawn,str
 filterstr='_VE1_'
 str="grep -f uniqJDs "+filenoZLSL+" | grep "+filterstr+" | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12}' > data_noZLSLcorr.VE1"
 spawn,str
 filterstr='_VE2_'
 str="grep -f uniqJDs "+filenoZLSL+" | grep "+filterstr+" | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12}' > data_noZLSLcorr.VE2"
 spawn,str
 filterstr='_IRCUT_'
 str="grep -f uniqJDs "+filenoZLSL+" | grep "+filterstr+" | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12}' > data_noZLSLcorr.IRCUT"
 spawn,str
 ;---------------------------
 !P.MULTI=[0,2,3]
 histoAlbedochange,'B'
 histoAlbedochange,'V'
 histoAlbedochange,'VE1'
 histoAlbedochange,'VE2'
 histoAlbedochange,'IRCUT'
 print,'-----------------------------------------------------------'
 spawn,'cat B.albedochg > all.albedochg'
 spawn,'cat IRCUT.albedochg >> all.albedochg'  
 spawn,'cat V.albedochg >> all.albedochg'
 spawn,'cat VE1.albedochg >> all.albedochg'
 spawn,'cat VE2.albedochg >> all.albedochg'
 dalbedo=get_data('all.albedochg')
 set_plot,'ps'
 device,filename='effects.eps',/encapsulated
 !P.MULTI=[0,1,1]
 !P.THICK=3
 !x.THICK=4
 !y.THICK=4
 !P.CHARTHICK=3
 histo,dalbedo,min(dalbedo),max(dalbedo),.07654,xtitle='% change, all filters',/abs
 n=n_elements(dalbedo)
 print,'% positive change: ',n_elements(where(dalbedo gt 0))/float(n)*100.
 print,'% larger than 0.26: ',n_elements(where(dalbedo gt 0.26))/float(n)*100.
 oplot,[0.26,0.26],[!Y.crange],linestyle=2
 oplot,[0.,0.],[!Y.crange],linestyle=1
 device,/close
 end
