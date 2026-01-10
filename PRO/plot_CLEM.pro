PRO oplotit,x,y
oplot,x,y,psym=7,color=fsc_color('green')
return
end

PRO plotit,x,y,xtit,ytit,tit,Xes,Ys,switch_str
xra=[min([Xes]),max([Xes])]
yra=[min([Ys]),max([Ys])]
!P.CHARSIZE=1.7
if (switch_str eq 'liny') then begin
if (tit ne '') then plot,x,y,xtitle=xtit,ytitle=ytit,psym=7,xstyle=3,ystyle=3,xrange=xra,yrange=yra,title=tit
if (tit eq '') then plot,x,y,xtitle=xtit,ytitle=ytit,psym=7,xstyle=3,ystyle=3,xrange=xra,yrange=yra
endif else begin
if (tit ne '') then plot_io,x,y,xtitle=xtit,ytitle=ytit,psym=7,xstyle=3,ystyle=3,xrange=xra,yrange=yra,title=tit
if (tit eq '') then plot_io,x,y,xtitle=xtit,ytitle=ytit,psym=7,xstyle=3,ystyle=3,xrange=xra,yrange=yra
endelse
return
end

PRO MCmeansandSD,array,mn,sd
n=n_elements(array)
ntrials=n*500
for itrial=0,ntrials-1,1 do begin
idx=randomu(seed,n)*n
if (itrial eq 0) then begin
	mn=mean(array(idx))
endif
if (itrial gt 0) then begin
	mn=[mn,mean(array(idx))]
endif
endfor
;histo,mn,0.36,0.38,0.0002
;histo,array,0.36,0.38,0.0009,/overplot
;stop
sd=stddev(mn)
mn=mean(mn)
return
end

file='CLEM.profiles_fitted_results_3treatments_multipatch.txt'
file='CLEM.profiles_fitted_results_3treatments_multipatch_rlim_fixed_smoo.txt'
file='CLEM.profiles_fitted_results_SELECTED_5_multipatch_100_smoo_SINGLES.txt'
spawn,"cat "+file+" | grep fits | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12}'  > pBV.dat"
spawn,"cat "+file+" | grep _VE1_ | grep fits | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12}'  > pV.dat"
spawn,"cat "+file+" | grep _VE2_ | grep fits | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12}'  > pB.dat"
!P.MULTI=[0,1,3]
data=get_data('pBV.dat')
xra=[min(data(0,*)),max(data(0,*))]
yra=[min(data(1,*)),max(data(1,*))]
data=get_data('pV.dat')
idx=where(data(9,*) lt 0.99)
data=data(*,idx)
l=size(data,/dimensions)
plot,title='V images on one night, 3 data treatments',xrange=xra,data(0,*),data(1,*),ytitle='V Albedo',xstyle=3,ystyle=3,psym=7
oploterr,data(0,*),data(1,*),data(2,*)
medianV=median(data(1,*))
print,'V Albedo: ',mean(data(1,*)),' +/- ',stddev(data(1,*)),' Z: ',stddev(data(1,*))/mean(data(1,*))*100.,' %.'
; B
data=get_data('pB.dat')
idx=where(data(9,*) lt 5.09)
data=data(*,idx)
plot,title='B images on one night, 3 data treatments',xrange=xra,data(0,*),data(1,*),ytitle='B Albedo',xstyle=3,ystyle=3,psym=7
oploterr,data(0,*),data(1,*),data(2,*)
print,'B Albedo: ',mean(data(1,*)),' +/- ',stddev(data(1,*)),' Z: ',stddev(data(1,*))/mean(data(1,*))*100.,' %.'
print,'B Albedo: ',median(data(1,*)),' +/- ',stddev(data(1,*)),' Z: ',stddev(data(1,*))/median(data(1,*))*100.,' %.'
; B and V
data=get_data('pV.dat')
idx=where(data(9,*) lt 5.09)
data=data(*,idx)
plot,/nodata,title='B and V images on one night, 3 data treatments',yrange=yra,xrange=xra,data(0,*),data(1,*),ytitle='B and V Albedo',xstyle=3,ystyle=3,psym=7
oplot,data(0,*),data(1,*),color=fsc_color('green'),psym=7
data=get_data('pB.dat')
idx=where(data(9,*) lt 5.09)
data=data(*,idx)
oplot,data(0,*),data(1,*),color=fsc_color('blue'),psym=7
oplot,[!x.crange],[median(data(1,*)),median(data(1,*))],linestyle=2,color=fsc_color('blue')
oplot,[!x.crange],[medianV,medianV],linestyle=2,color=fsc_color('green')

;
Bdata=get_data('pB.dat')
;JD,albedo,erralbedo,alfa1,rlimit,pedestal,xshift,corefactor,contrast,RMSE,totfl
; 2456045.8117188   0.3816   0.0002   2.1028   2.0000   0.1504  -0.1441   0.2681   0.7705      0.132   406144419.292
Bjd=reform(Bdata(0,*))
Balbedo=reform(Bdata(1,*))
Berralbedo=reform(Bdata(2,*))
Balfa1=reform(Bdata(3,*))
Brlimit=reform(Bdata(4,*))
Bpedestal=reform(Bdata(5,*))
Bxshift=reform(Bdata(6,*))
Byshift=reform(Bdata(7,*))
Bcorefactor=reform(Bdata(8,*))
Bcontrast=reform(Bdata(9,*))
BRMSE=reform(Bdata(10,*))
Btotfl=reform(Bdata(11,*))
Vdata=get_data('pV.dat')
;JD,albedo,erralbedo,alfa1,rlimit,pedestal,xshift,corefactor,contrast,RMSE,totfl
Vjd=reform(Vdata(0,*))
Valbedo=reform(Vdata(1,*))
Verralbedo=reform(Vdata(2,*))
Valfa1=reform(Vdata(3,*))
Vrlimit=reform(Vdata(4,*))
Vpedestal=reform(Vdata(5,*))
Vxshift=reform(Vdata(6,*))
Vyshift=reform(Vdata(7,*))
Vcorefactor=reform(Vdata(8,*))
Vcontrast=reform(Vdata(9,*))
VRMSE=reform(Vdata(10,*))
Vtotfl=reform(Vdata(11,*))
!P.MULTI=[0,2,4]
x0=long(min([Bjd,Vjd]))
plotit,Bjd-x0,Balbedo,'JD','Albedo','B',[Bjd-x0,Vjd-x0],[Balbedo,Valbedo],'liny'
oplotit,Vjd-x0,Valbedo
;plotit,Bjd,Berralbedo,'JD','Albedo error','',[Bjd,Vjd],[Berralbedo,Verralbedo],'logy'
;oplotit,Vjd,Verralbedo
plotit,Bjd-x0,Balfa1,'JD','PSF wing alfa','',[Bjd-x0,Vjd-x0],[Balfa1,Valfa1],'liny'
oplotit,Vjd-x0,Valfa1
plotit,Bjd-x0,Brlimit,'JD','PSF core radius','',[Bjd-x0,Vjd-x0],[Brlimit,Vrlimit],'logy'
oplotit,Vjd-x0,Vrlimit
oplot,[!x.crange],[2,2],linestyle=2
oplot,[!x.crange],[10,10],linestyle=2
plotit,Bjd-x0,Bpedestal,'JD','pedestal','',[Bjd-x0,Vjd-x0],[Bpedestal,Vpedestal],'liny'
oplotit,Vjd-x0,Vpedestal

;plotit,Bjd-x0,Bxshift,'JD','X-shift','',[Bjd-x0,Vjd-x0],[Bxshift,Vxshift],'liny'
;oplotit,Vjd-x0,Vxshift
plotit,Bxshift,Byshift,'X-shift','Y-shift','',[Bxshift,Vxshift],[Byshift,Vyshift],'liny'
oplotit,Vxshift,Vyshift

plotit,Bjd-x0,Bcontrast,'JD','Lunar albedo contrast','',[Bjd-x0,Vjd-x0],[Bcontrast,Vcontrast],'liny'
oplotit,Vjd-x0,Vcontrast
plotit,Bjd-x0,Bcorefactor,'JD','PSF core factor','',[Bjd-x0,Vjd-x0],[Bcorefactor,Vcorefactor],'logy'
oplotit,Vjd-x0,Vcorefactor
plotit,Bjd-x0,BRMSE,'JD','RMSE','',[Bjd-x0,Vjd-x0],[BRMSE,VRMSE],'liny'
oplotit,Vjd-x0,VRMSE
end

