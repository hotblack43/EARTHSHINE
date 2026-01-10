filter='*'
;spawn,"~/GET CLEM.halotrials_June_3_2016_synthimages.txt"
str="cat CLEM.halotrials_June_3_2016_synthimages.txt | grep '_"+filter+".' | awk '{print $1,$2,$3}' > list1"
print,str
spawn,str
spawn,"cat CLEM.halotrials_May_23_2016.txt | grep '_"+filter+".' | awk '{print $1,$2,$3}' > list2"
spawn,"cat list1 | sort | uniq > hej"
spawn,"mv hej list1"
spawn,"cat list2 | sort | uniq > hej"
spawn,"mv hej list2"
data1=get_data('list1')
data2=get_data('list2')
n1=n_elements(data1(0,*))
n2=n_elements(data2(0,*))
fmt='(f15.7,4(1x,f11.6))'
openw,12,'data.dat'
for i=0,n1-1,1 do begin
	for j=0,n2-1,1 do begin
	if (data1(0,i) eq data2(0,j)) then begin
	    print,format=fmt,data1(0,i),data1(1,i)-data2(1,j),(data1(1,i)-data2(1,j))/data2(1,j)*100.,data1(1,i),data2(2,j)
	printf,12,format=fmt,data1(0,i),data1(1,i)-data2(1,j),(data1(1,i)-data2(1,j))/data2(1,j)*100.,data1(1,i),data2(2,j)

	endif
	endfor
endfor
close,12
data=get_data('data.dat')
jd=reform(data(0,*))
diff=reform(data(1,*))
pct=reform(data(2,*))
alb=reform(data(3,*))
alberr=reform(data(4,*))
mphase,jd,illfrac
window,xsize=1200*1.25,ysize=400*1.25
!P.MULTI=[0,3,1]
!P.charsize=3
!P.charthick=2
!P.THICK=3
plot_io,yrange=[1e-3,1e3],illfrac,abs(pct),psym=7,xtitle='Illuminated fract.',ytitle='| Error | [% pts]',xstyle=3,ystyle=3,title='Forward method on synthetic omages'
plot,illfrac,alb,psym=7,xtitle='Illuminated fract.',ytitle='Albedo',title='Forward method on synthetic omages'
oploterr,illfrac,alb,diff;,alberr*10
;plot_io,jd mod 1,abs(pct),psym=7,xtitle='JD mod 1',ytitle='| Error | [% pts]'
!X.style=3
histo,/abs,pct,-0.3,0.3,0.007,xtitle='Error in % pts',title='Forward method on synthetic omages'
print,'Errors:'
print,'Median   : ',median(pct),' % points'
print,'Robust SD: ',robust_sigma(pct),' % points'
print,'N: ',n_elements(pct)
end
