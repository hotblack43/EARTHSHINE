@stuff613.pro
PRO printlegend,i,colnames,type,listy
xyouts,/data,90,0.9-i*0.05,type
oplot,[80,88],[0.9-i*0.05,0.9-i*0.05],color=fsc_color(colnames),linestyle=listy,thick=18
return
end

type=['H-X_HIRESscaled_LA', 'H-X_HIRESscaled_LS', 'H-X_LRO_LA', 'H-X_LRO_LS', 'newH-63_HIRESscaled_LA', 'newH-63_HIRESscaled_LS', 'newH-63_LRO_LA', 'newH-63_LRO_LS']
colnames=['red','blue','green','olive','red','blue','green','olive']
ntyp=n_elements(type)
!P.charsize=2
!P.THICK=3
spawn,"wc CLEM_justtesting.txt"
for i=0,ntyp-1,1 do begin
str="cat CLEM_justtesting.txt | grep "+type(i)+" | awk '{print $1,$2}' > p"
spawn,str
data=get_data('p')
jd=reform(data(0,*))
albedo=reform(data(1,*))
phase=[]
for k=0,n_elements(jd)-1,1 do begin
get_everything_fromJD,JD(k),ph,azimuth,am
phase=[phase,abs(ph)]
endfor
idx=sort(phase)
phase=phase(idx)
albedo=albedo(idx)
if (i eq 0) then begin
	plot,phase,albedo,/nodata,psym=7,xstyle=3,ystyle=3,xtitle='Phase [FM = 0]',ytitle='Albedo',yrange=[0.3,1.0]
	oplot,phase,albedo,color=fsc_color(colnames(i)),psym=7
	res=robust_poly_fit(phase,albedo,2,yhat)
	listy=0
	if (strpos(type(i),'H-X') ne -1) then listy=2
	oplot,phase,yhat,color=fsc_color(colnames(i)),linestyle=listy,thick=8
endif
if (i gt 0) then begin
	oplot,phase,albedo,color=fsc_color(colnames(i)),psym=7
	res=poly_fit(phase,albedo,2,yhat)
	listy=0
	if (strpos(type(i),'H-X') ne -1) then listy=2
	oplot,phase,yhat,color=fsc_color(colnames(i)),linestyle=listy,thick=8
endif
	listy=0
	if (strpos(type(i),'H-X') ne -1) then listy=2
printlegend,i,colnames(i),type(i),listy
endfor
end
