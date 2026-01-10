PRO getmedian,x,y,xxx,yyy
; by binning along x axis get a histogram returned in xxx,yyy
listen=[]
w=0.05
for xx=-2.*w,1.-w,w do begin
idx=where(x gt xx and x le xx+w)
n=n_elements(idx)
if (n gt 2) then begin
	listen=[[listen],[xx+w/2.,median(y(idx))]]
endif
endfor
xxx=listen(0,*)
yyy=listen(1,*)
return
end

filter='*';'IRCUT'
;spawn,"~/GET CLEM.halotrials_June_3_2016_synthimages.txt"
str="cat CLEM.halotrials_June_3_2016_synthimages.txt | grep '_"+filter+".' | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$13,$14}' > list1"
print,str
spawn,str
spawn,"cat CLEM.halotrials_May_23_2016.txt | grep '_"+filter+".' | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$13,$14}' > list2"
spawn,"cat list1 | sort | uniq > hej"
spawn,"mv hej list1"
spawn,"cat list2 | sort | uniq > hej"
spawn,"mv hej list2"
data1=get_data('list1')
data2=get_data('list2')
n1=n_elements(data1(0,*))
n2=n_elements(data2(0,*))
fmt='(f15.7,14(1x,f11.6))'
openw,12,'data.dat'
for i=0,n1-1,1 do begin
	for j=0,n2-1,1 do begin
	if (data1(0,i) eq data2(0,j)) then begin
	    print,format=fmt,data1(0,i),data1(1,i)-data2(1,j),(data1(1,i)-data2(1,j))/data2(1,j)*100.,data1(1,i),data2(2,j),data1(3:11,i)
	printf,12,format=fmt,data1(0,i),data1(1,i)-data2(1,j),(data1(1,i)-data2(1,j))/data2(1,j)*100.,data1(1,i),data2(2,j),data1(3:11,i)

	endif
	endfor
endfor
close,12
data=get_data('data.dat')
alb=reform(data(3,*))
idx=where(alb gt 0.2)
data=data(*,idx)
jd=reform(data(0,*))
diff=reform(data(1,*))
pct=reform(data(2,*))
alb=reform(data(3,*))
alberr=reform(data(4,*))
alfa=reform(data(5,*))
beta=reform(data(6,*))
ped=reform(data(7,*))
deltax=reform(data(8,*))
deltay=reform(data(9,*))
acoeff=reform(data(10,*))
lamda0=reform(data(11,*))
mphase,jd,illfrac
;window,xsize=0.6*1200*1.25,ysize=0.6*400*1.25*2
!P.MULTI=[0,2,4]
!P.charsize=2
!P.charthick=2
!P.THICK=3
plot_io,yrange=[1e-3,2e2],illfrac,abs(pct),psym=1,xtitle='Illuminated fract.',ytitle='| Error | [% pts]',xstyle=3,ystyle=3,title='Forward method on synthetic images'
getmedian,illfrac,abs(pct),xxx,yyy
oplot,xxx,yyy,psym=10,color=fsc_color('red')
plot,illfrac,alb,psym=1,xtitle='Illuminated fract.',ytitle='Albedo',title='Forward method on synthetic images',ystyle=3
oploterr,illfrac,alb,diff;,alberr*10
;plot_io,jd mod 1,abs(pct),psym=1,xtitle='JD mod 1',ytitle='| Error | [% pts]'
!X.style=3
histo,/abs,pct,-0.3,0.3,0.007,xtitle='Error in % pts',title='Forward method on synthetic images'
;---
plot_oi,xrange=[1e-4,1e3],abs(pct),alfa,psym=1,xtitle='| Error | [% pts]',ytitle='!7a!3',ystyle=3
plot_oi,xrange=[1e-4,1e3],abs(pct),beta,psym=1,xtitle='| Error | [% pts]',ytitle='!7b!3',ystyle=3
plot_oi,xrange=[1e-4,1e3],abs(pct),ped,psym=1,xtitle='| Error | [% pts]',ytitle='Pedestal',ystyle=3
oplot,[0.0001,2000],[0,0],linestyle=1
plot_oo,yrange=[1e-4,1e1],xrange=[1e-4,1e3],abs(pct),acoeff,psym=1,xtitle='| Error | [% pts]',ytitle='A!dcoeff!n',ystyle=3
plot_io,alb,abs(diff),psym=1,xtitle='Albedo',ytitle='| Error | [% pts]',title='Forward method on synthetic images',ystyle=3,yrange=[1e-6,200]
;---------------- page 2 o fplots
plot,alfa,beta,psym=1,xtitle='!7a!3',ytitle='!7b!3',ystyle=3,xstyle=3
plot,alfa,Acoeff,psym=1,xtitle='!7a!3',ytitle='A!dcoeff!n',ystyle=3,xstyle=3
plot,beta,Acoeff,psym=1,xtitle='!7b!3',ytitle='A!dcoeff!n',ystyle=3,xstyle=3
plot_oo,xrange=[1,10],yrange=[1e-2,3],alfa*beta,Acoeff,psym=1,xtitle='!7a!3*!7b!3',ytitle='A!dcoeff!n',ystyle=3,xstyle=3
xx=findgen(100)/10.
yy=0.000002*xx^(10.)
oplot,xx,yy,color=fsc_color('red')

;------
print,'Errors:'
print,'Median   : ',median(pct),' % points'
print,'       SD: ',stddev(pct),' % points'
print,'Robust SD: ',robust_sigma(pct),' % points'
print,'N: ',n_elements(pct)
;
signature,'compare_list1_list2.pro'
end
