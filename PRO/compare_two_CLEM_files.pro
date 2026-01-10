PRO goplothistos,x2,x1,x3,tstr
zz=[x1,x2,x3]
print,tstr+' min,max: ',min(zz),max(zz)
pcol=!P.color
!X.style=3
nbins=27
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
idx=where(dalbedo lt 0.008)
out=out(idx)
return
end



if_want_file_selector=1
CLEMfile1='CLEM.testing_OCT15_2014b.txt'	; LRO contrast free 464 nm
CLEMfile2='CLEM.testing_OCT10_2014.txt'	; empirical
CLEMfile3='CLEM.testing_OCT16_2014.txt';	LRO contrast fixed 464nm
;--------------------------------
CLEMfile1='CLEM.testing_OCT16_2014b.txt'	; LRO contrast free 564 nm
CLEMfile2='CLEM.testing_sep26_2014.txt'	; empirical
CLEMfile3='CLEM.testing_sep21_2014.txt';	empirical
if (if_want_file_selector eq 1) then spawn,"cat "+CLEMfile1+" | grep sum_of_100 | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14}' > hejsafil1"
if (if_want_file_selector eq 1) then spawn,"cat "+CLEMfile2+" | grep sum_of_100 | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14}' > hejsafil2"
if (if_want_file_selector eq 1) then spawn,"cat "+CLEMfile3+" | grep sum_of_100 | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14}' > hejsafil3"

if (if_want_file_selector ne 1) then spawn,"cat "+CLEMfile1+" | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14}' > hejsafil1"
if (if_want_file_selector ne 1) then spawn,"cat "+CLEMfile2+" | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14}' > hejsafil2"
if (if_want_file_selector ne 1) then spawn,"cat "+CLEMfile3+" | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14}' > hejsafil3"

spawn,"awk '{print $15}' "+CLEMfile1+" > namefil1"
spawn,"awk '{print $15}' "+CLEMfile2+" > namefil2"
spawn,"awk '{print $15}' "+CLEMfile3+" > namefil3"
;----------------------------------------------------------; 
!P.MULTI=[0,3,3]
getstuff,'hejsafil1','Albedo',albedo1
getstuff,'hejsafil2','Albedo',albedo2
getstuff,'hejsafil3','Albedo',albedo3
goplothistos,albedo1,albedo2,albedo3,'Albedo'
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
tstr='Emp. (red), LRO, LRO_int (green)'
plot,title=tstr,xstyle=3,ystyle=3,xrange=[0.4,0.5],yrange=[1.6,2],albedo1,alfa1,psym=7,xtitle='Albedo',ytitle='!7a!3'
oplot,albedo2,alfa2,psym=7,color=fsc_color('red')
oplot,albedo3,alfa3,psym=7,color=fsc_color('green')

plot,title=tstr,xstyle=3,ystyle=3,xrange=[0.4,0.5],yrange=[-1.9,0.9],albedo1,dx1,psym=7,xtitle='Albedo',ytitle='!7d!3x'
oplot,albedo2,dx2,psym=7,color=fsc_color('red')
oplot,albedo3,dx3,psym=7,color=fsc_color('green')

plot,title=tstr,xstyle=3,ystyle=3,xrange=[0.4,0.5],yrange=[2.9,10.9],albedo1,cf1,psym=7,xtitle='Albedo',ytitle='Core factor'
oplot,albedo2,cf2,psym=7,color=fsc_color('red')
oplot,albedo3,cf3,psym=7,color=fsc_color('green')

plot,title=tstr,xstyle=3,ystyle=3,xrange=[0.4,0.5],yrange=[0.5,1.1],albedo1,c1,psym=7,xtitle='Albedo',ytitle='Contrast'
oplot,albedo2,c2,psym=7,color=fsc_color('red')
oplot,albedo3,c3,psym=7,color=fsc_color('green')
print,'Median contrast empirical: ',median(c2)
print,'Median contrast LRO      : ',median(c1)
print,'Median contrast LRO_int  : ',median(c3)
print,'OLS guess for best lamda to scale for B: ',(464-415)/(median(c3)-median(c1))*(1.-median(c1))+415
print,'Mean albedo 1 and SD: ',mean(albedo1),stddev(albedo1),' or ',stddev(albedo1)/mean(albedo1)*100.,' %'
print,'Mean albedo 2 and SD: ',mean(albedo2),stddev(albedo2),' or ',stddev(albedo2)/mean(albedo2)*100.,' %'
print,'Mean albedo 3 and SD: ',mean(albedo3),stddev(albedo3),' or ',stddev(albedo3)/mean(albedo3)*100.,' %'

end
