close,/all
filter='*';'IRCUT'
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
	    print,format=fmt,data1(0,i),(data1(1,i)-data2(1,j))/data2(1,j)*100.,$
(data1(2,i)-data2(2,j))/data2(2,j)*100.,$
(data1(3,i)-data2(3,j))/data2(3,j)*100.,$
(data1(4,i)-data2(4,j))/data2(4,j)*100.,$
(data1(5,i)-data2(5,j))/data2(5,j)*100.,$
(data1(8,i)-data2(8,j))/data2(8,j)*100.,$
(data1(9,i)-data2(9,j))/data2(9,j)*100.,$
(data1(10,i)-data2(10,j))/data2(10,j)*100.,$
(data1(11,i)-data2(11,j))/data2(11,j)*100.
	    printf,12,format=fmt,data1(0,i),(data1(1,i)-data2(1,j))/data2(1,j)*100.,$
(data1(2,i)-data2(2,j))/data2(2,j)*100.,$
(data1(3,i)-data2(3,j))/data2(3,j)*100.,$
(data1(4,i)-data2(4,j))/data2(4,j)*100.,$
(data1(5,i)-data2(5,j))/data2(5,j)*100.,$
(data1(8,i)-data2(8,j))/data2(8,j)*100.,$
(data1(9,i)-data2(9,j))/data2(9,j)*100.,$
(data1(10,i)-data2(10,j))/data2(10,j)*100.,$
(data1(11,i)-data2(11,j))/data2(11,j)*100.
	endif
	endfor
endfor
close,12
data=get_data('data.dat')
difflist=[]
jd=reform(data(0,*))
difflist=[[difflist],[reform(data(1,*))]]
difflist=[[difflist],[reform(data(2,*))]]
difflist=[[difflist],[reform(data(3,*))]]
difflist=[[difflist],[reform(data(4,*))]]
difflist=[[difflist],[reform(data(5,*))]]
difflist=[[difflist],[reform(data(6,*))]]
difflist=[[difflist],[reform(data(7,*))]]
difflist=[[difflist],[reform(data(8,*))]]
difflist=[[difflist],[reform(data(9,*))]]
diffname=['Albedo','!7D!3Albedo','!7a!3','!7b!3','pedestal','!7D!3x','!7D!3y','A!dcoeff!n','lamda!d0!n']
varlist=[0,2,3,4,7]
!P.charsize=2
!P.MULTI=[0,2,3]
for i=0,n_elements(varlist)-1,1 do begin
for j=i,n_elements(varlist)-1,1 do begin
if (i ne j) then begin
plot_oo,abs(difflist(*,varlist(i))),abs(difflist(*,varlist(j))),xtitle='!7D!3'+diffname(varlist(i)),ytitle='!7D!3'+diffname(varlist(j)),psym=1,xstyle=3,ystyle=3
endif
endfor
endfor
; other plots
!P.MULTI=[0,2,3]
plot_oo,xrange=[1,10],yrange=[1e-4,3],title='Synthetic halo images',data1(3,*)*data1(4,*),data1(8,*),psym=1,xtitle='!7a!3*!7b!3',ytitle='A!dcoeff!n'
plot_oo,xrange=[1,10],yrange=[1e-4,3],title='Observed images',data2(3,*)*data2(4,*),data2(8,*),psym=1,xtitle='!7a!3*!7b!3',ytitle='A!dcoeff!n'
;plot_oo,xrange=[1e-4,1e2],yrange=[1e-4,1e2],title='Observed vs Model',data2(3,*)*data2(4,*)/data2(8,*)^10,data1(3,*)*data1(4,*)/data1(8,*)^10,psym=1,xtitle='!7a!3*!7b!3 Obs',ytitle='!7a!3*!7b!3 Mod'
end
