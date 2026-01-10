PRO gofindsunglintlongitudes
; will write an output file like the input but with sunglint longitudes too
 openw,55,'australia.plotme'
 data1=get_data('australia_selected.dat')	; jd,dsbsobs,dsbsmod
 l=size(data1,/dimensions)
 data2=get_data('australia.transect_details')	; jd,longitude
 JD2=reform(data2(0,*))
 glon=reform(data2(1,*))
 for i=0,l(1)-1,1 do begin
     jdwant=reform(data1(0,i))
     delta=abs(JD2-jdwant(0))
     if (min(delta) lt 1./24./4.) then begin
     idx=where(delta eq min(delta))
     print,format='(i3,1x,f15.7,4(1x,e15.7))',i,data1(*,i),glon(idx(0)),min(delta)
     printf,55,format='(4(1x,e15.7))',data1(*,i),glon(idx(0))
	endif
     endfor
 close,55
 return
 end
 
 ;-------------------------------------------------------------------------------
 ; Will plot DS/BS against sunglint longitude
 ;-------------------------------------------------------------------------------
 observed_data='australia_Uniform.data'
 observed_data='australia_Non-Uniform.data'
 ; get all data
 filters=['_B_','_V_','_VE1_','_IRCUT_','_VE2_']
 !P.MULTI=[0,3,5]
 for ifLOGLINtyp=0,3,1 do begin
 for ityp=1,2,1 do begin
 if (ityp eq 1) then observed_data='australia_Non-Uniform.data'
 if (ityp eq 2) then observed_data='australia_Uniform.data'
 for i=0,4,1 do begin
 filter=filters(i)
 selectstr="  awk '{print $1,$10/$14,$15/$19}'  > "        ; to awk phase,am,mags,filename
;...................
 if (ifLOGLINtyp eq 0) then begin
 spawn,'grep '+filter+' '+observed_data+' | grep SELECTED_1 | grep -v BBSO | grep -v EFM | '+selectstr+'australia_selected.dat'
 if (ityp eq 1) then usestring='Uniform Lambert model, RAW'
 if (ityp eq 2) then usestring='Non-Uniform Lambert model, RAW'
 endif
;...................
 if (ifLOGLINtyp eq 1) then begin
 spawn,'grep '+filter+' '+observed_data+' | grep BBSO_CLEANED | grep -v LOG | '+selectstr+'australia_selected.dat'
 if (ityp eq 1) then usestring='Uniform Lambert model, BBSO_LIN'
 if (ityp eq 2) then usestring='Non-Uniform Lambert model, BBSO_LIN'
 endif
;...................
 if (ifLOGLINtyp eq 2) then begin
 spawn,'grep '+filter+' '+observed_data+' | grep BBSO_CLEANED_LOG | '+selectstr+'australia_selected.dat'
 if (ityp eq 1) then usestring='Uniform Lambert model, BBSO_LOG'
 if (ityp eq 2) then usestring='Non-Uniform Lambert model, BBSO_LOG'
 endif
;...................
 if (ifLOGLINtyp eq 3) then begin
 spawn,'grep '+filter+' '+observed_data+' | grep EFMCLEANED | '+selectstr+'australia_selected.dat'
 if (ityp eq 1) then usestring='Uniform Lambert model, EFM'
 if (ityp eq 2) then usestring='Non-Uniform Lambert model, EFM'
 endif
;...................
 ; get corresponding sunglint longitudes
 gofindsunglintlongitudes
 ; plot DS/BS against longitude, for all filters
 data=get_data('australia.plotme')
 idx=where(data(1,*) gt 0) & data=data(*,idx)
 glon=reform(data(3,*))
 DStot_obs=reform(data(1,*))
 DStot_mod=reform(data(2,*))
 !P.CHARSIZE=1.7
 plot,title=filter,glon,DStot_obs,psym=1,xtitle='Longitude East',ytitle='DS/BS!dobs!n'
 plot,glon,DStot_mod,psym=1,xtitle='Longitude East',ytitle='DS/BS!dmod!n'
 plot,glon,DStot_obs/DStot_mod,psym=1,xtitle='Longitude East',ytitle='[DS/BS!dobs!n]/[DS/BS!dmod!n]'
 xyouts,/normal,0.3,1.02,usestring,charsize=1.3
 endfor
 endfor
 endfor
; other plots
 !P.MULTI=[0,2,5]
 for ifLOGLINtyp=0,3,1 do begin
 for ityp=1,2,1 do begin
 if (ityp eq 1) then observed_data='australia_Non-Uniform.data'
 if (ityp eq 2) then observed_data='australia_Uniform.data'
 for i=0,4,1 do begin
 filter=filters(i)
 selectstr="  awk '{print $1,$10/$14,$15/$19}'  > "        ; to awk phase,am,mags,filename
;...................
 if (ifLOGLINtyp eq 0) then begin
 spawn,'grep '+filter+' '+observed_data+' | grep SELECTED_1 | grep -v BBSO | grep -v EFM | '+selectstr+'australia_selected.dat'
 if (ityp eq 1) then usestring='Uniform Lambert model, RAW'
 if (ityp eq 2) then usestring='Non-Uniform Lambert model, RAW'
 endif
;...................
 if (ifLOGLINtyp eq 1) then begin
 spawn,'grep '+filter+' '+observed_data+' | grep BBSO_CLEANED | grep -v LOG | '+selectstr+'australia_selected.dat'
 if (ityp eq 1) then usestring='Uniform Lambert model, BBSO_LIN'
 if (ityp eq 2) then usestring='Non-Uniform Lambert model, BBSO_LIN'
 endif
;...................
 if (ifLOGLINtyp eq 2) then begin
 spawn,'grep '+filter+' '+observed_data+' | grep BBSO_CLEANED_LOG | '+selectstr+'australia_selected.dat'
 if (ityp eq 1) then usestring='Uniform Lambert model, BBSO_LOG'
 if (ityp eq 2) then usestring='Non-Uniform Lambert model, BBSO_LOG'
 endif
;...................
 if (ifLOGLINtyp eq 3) then begin
 spawn,'grep '+filter+' '+observed_data+' | grep EFMCLEANED | '+selectstr+'australia_selected.dat'
 if (ityp eq 1) then usestring='Uniform Lambert model, EFM'
 if (ityp eq 2) then usestring='Non-Uniform Lambert model, EFM'
 endif
;...................
 ; get corresponding sunglint longitudes
 gofindsunglintlongitudes
 ; plot DS/BS against longitude, for all filters
 data=get_data('australia.plotme')
 idx=where(data(1,*) gt 0) & data=data(*,idx)
 glon=reform(data(3,*))
 DStot_obs=reform(data(1,*))
 DStot_mod=reform(data(2,*))
 !P.CHARSIZE=1.7
 plot,psym=7,title=filter,DStot_obs,xstyle=3,xtitle='Obs. seq. no.',ytitle='DS/BS!dobs!n'
 plot,psym=7,title=filter,DStot_mod,xstyle=3,xtitle='Obs. seq. no.',ytitle='DS/BS!dmod!n'
 xyouts,/normal,0.3,1.02,usestring,charsize=1.3
 endfor
 endfor
 endfor
 end
