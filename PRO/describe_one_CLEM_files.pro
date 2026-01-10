@test_get_everything_fromJD.pro
 PRO getAM,JD,am,lg
 n=n_elements(JD)
 am=fltarr(n)
 lg=fltarr(n)
 for k=0,n-1,1 do begin
	get_everything_fromJD,JD(k),phase,azimuth,airmass,longlint
	am(k)=airmass
	lg(k)=longlint
 endfor
 return
 end

PRO gooplot,x,y,plcol
print,'x: ',x
print,'y: ',y
 oplot,x,y,psym=7,color=fsc_color(plcol)
;res1=robust_linefit(x,y)
 res1=ladfit(x,y)
 yhat1=res1(0)+res1(1)*x
 print,'Slope: ',res1(1)
 oplot,x,yhat1,color=fsc_color(plcol)
residuals=y-yhat1
print,'SD of small residuals: ',stddev(residuals(where(abs(residuals)) lt 0.005)) 
 return
 end
 
 PRO describewhatwehave,filtername,jdarray
 print,'-------------------------------------------'
 print,filtername,' : ',n_elements(jdarray)
 z=jdarray(sort(jdarray))
 z=z(uniq(z))
 print,format='(a,500(1x,f15.7))','Uniques : ',z
 print,'Deltas [min]:',(z-z(0))*24.*60.
 
 return
 end
 PRO goplothistos,x1,x2,x3,tstr
 zz=[x1,x2,x3]
 print,tstr+' min,max: ',min(zz),max(zz)
 pcol=!P.color
 !X.style=3
 nbins=19
 histo,x1,min(zz),max(zz),(max(zz)-min(zz))/nbins,/abs,xtitle=tstr
 !P.color=fsc_color('red')
 histo,x2,min(zz),max(zz),(max(zz)-min(zz))/nbins*1.0453,/abs,/overplot
 !P.color=fsc_color('green')
 histo,x3,min(zz),max(zz),(max(zz)-min(zz))/nbins/1.06547,/abs,/overplot
 !P.color=pcol
 return
 end
 
 PRO getstuff,filename,cmd,out
 data=get_data(filename)
 ; JD,albedo,erralbedo,alfa1,rlimit,pedestal,xshift,yshift,corefactor,contrast,RMSE,totfl,zodi,SLcounts
 if (cmd eq 'JD') then designator=0
 if (cmd eq 'Albedo') then designator=1
 if (cmd eq 'Delta Albedo') then designator=2
 if (cmd eq 'Alfa') then designator=3
 if (cmd eq 'ped') then designator=5
 if (cmd eq 'xshift') then designator=6
 if (cmd eq 'cf') then designator=8
 if (cmd eq 'contrast') then designator=9
 if (cmd eq 'RMSE') then designator=10
 out=reform(data(designator,*))
 dalbedo=reform(data(2,*))
 albedo=reform(data(1,*))
 alfa=reform(data(3,*))
 contrast=reform(data(9,*))
 idx=where((albedo lt 0.6) and (albedo gt 0.24) and (dalbedo lt 2) and (alfa lt 2) and(contrast lt 1.4))
 if (idx(0) ne -1) then out=reform(data(designator,idx))
 return
 end
 
 
 
 CLEMfile1='CLEM.testing_OCT16_2014c.txt'	
 spawn,"cat "+CLEMfile1+" | grep sum_of_100 | grep _B_ | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14}' > hejsafil1"
 spawn,"cat "+CLEMfile1+" | grep sum_of_100 | grep _V_ | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14}' > hejsafil2"
 spawn,"cat "+CLEMfile1+" | grep sum_of_100 | grep _IRCUT_ | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14}' > hejsafil3"
 
 spawn,"awk '{print $15}' "+CLEMfile1+" > namefil1"
 spawn,"awk '{print $15}' "+CLEMfile1+" > namefil2"
 spawn,"awk '{print $15}' "+CLEMfile1+" > namefil3"
 getstuff,'hejsafil1','JD',JD_B
 getstuff,'hejsafil2','JD',JD_V
 getstuff,'hejsafil3','JD',JD_IRCUT
 ;----------------------------------------------------------; 
 describewhatwehave,'B',JD_B
 describewhatwehave,'V',JD_V
 describewhatwehave,'IRCUT',JD_IRCUT
; get corresponding airmasses
 ;getAM,JD_B,am_B,lg_B
 ;getAM,JD_V,am_V,lg_V
 ;getAM,JD_IRCUT,am_IRCUT,lg_IRCUT
 print,'-------------------------------------------'
 ;----------------------------------------------------------; 
 !P.MULTI=[0,3,3]
 !P.CHARSIZE=2
 getstuff,'hejsafil1','Albedo',albedo1
 getstuff,'hejsafil2','Albedo',albedo2
 getstuff,'hejsafil3','Albedo',albedo3
 goplothistos,albedo1,albedo2,albedo2,'Albedo'
 ;----------------------------------------------------------; 
 getstuff,'hejsafil1','Delta Albedo',Dalbedo1
 getstuff,'hejsafil2','Delta Albedo',Dalbedo2
 getstuff,'hejsafil3','Delta Albedo',Dalbedo3
 goplothistos,Dalbedo1,Dalbedo2,Dalbedo3,'Albedo uncert.'
 ;----------------------------------------------------------; 
 getstuff,'hejsafil1','Alfa',alfa1
 getstuff,'hejsafil2','Alfa',alfa2
 getstuff,'hejsafil3','Alfa',alfa3
 goplothistos,alfa1,alfa2,alfa3,'!7a!3'
 ;----------------------------------------------------------; 
 getstuff,'hejsafil1','xshift',dx1
 getstuff,'hejsafil2','xshift',dx2
 getstuff,'hejsafil3','xshift',dx3
 goplothistos,dx1,dx2,dx3,'!7d!3x'
 ;----------------------------------------------------------; 
 getstuff,'hejsafil1','cf',cf1
 getstuff,'hejsafil2','cf',cf2
 getstuff,'hejsafil3','cf',cf3
 goplothistos,cf1,cf2,cf3,'Core factor'
 ;----------------------------------------------------------; 
 getstuff,'hejsafil1','contrast',c1
 getstuff,'hejsafil2','contrast',c2
 getstuff,'hejsafil3','contrast',c3
 goplothistos,c1,c2,c3,'Lunar Albedo Contrast'
 ;----------------------------------------------------------; 
 getstuff,'hejsafil1','RMSE',r1
 getstuff,'hejsafil2','RMSE',r2
 getstuff,'hejsafil3','RMSE',r3
 goplothistos,r1,r2,r3,'RMSE'
 ;----------------------------------------------------------; 
 getstuff,'hejsafil1','ped',p1
 getstuff,'hejsafil2','ped',p2
 getstuff,'hejsafil3','ped',p3
 goplothistos,p1,p2,p3,'Pedestal'
 ;----------------------------------------------------------; 
 print,'touch a key ...'
 a=get_kbrd()
 !P.MULTI=[0,3,3]
 tstr='FIlters = colours'
 plot,title=tstr,xstyle=3,ystyle=3,albedo1,alfa1,psym=7,xtitle='Albedo',ytitle='!7a!3'
 
 plot,title=tstr,xstyle=3,ystyle=3,albedo1,dx1,psym=7,xtitle='Albedo',ytitle='!7d!3x'
 
 plot,title=tstr,xstyle=3,ystyle=3,albedo1,cf1,psym=7,xtitle='Albedo',ytitle='Core factor'
 
 plot,title=tstr,xstyle=3,ystyle=3,albedo1,c1,psym=7,xtitle='Albedo',ytitle='Contrast'
 print,'Median contrast B    : ',median(c1)
 print,'Median contrast V    : ',median(c2)
 print,'Median contrast IRCUT: ',median(c3)
 print,'Mean albedo 1 and SD: ',mean(albedo1),stddev(albedo1),' or ',stddev(albedo1)/mean(albedo1)*100.,' %'
 print,'Mean albedo 2 and SD: ',mean(albedo2),stddev(albedo2),' or ',stddev(albedo2)/mean(albedo2)*100.,' %'
 print,'Mean albedo 3 and SD: ',mean(albedo3),stddev(albedo3),' or ',stddev(albedo3)/mean(albedo3)*100.,' %'
 print,'touch a key ...'
 a=get_kbrd()
 !P.MULTI=[0,1,1]
zz=[JD_B mod 1,JD_V mod 1,JD_IRCUT mod 1]
zzz=[albedo1,albedo2,albedo3]
 plot,xtitle='Hours since GMT noon',ytitle='Albedo',zz*24,zzz,psym=7,ystyle=3

 gooplot,(jd_B mod 1)*24,albedo1,'blue'
 print,'-------------------------------------------'
 gooplot,(jd_V mod 1)*24,albedo2,'green'
 print,'-------------------------------------------'
 gooplot,(jd_ircut mod 1)*24,albedo3,'orange'
 print,'-------------------------------------------'
 
 end
