PRO goprintstats,array,str
print,format='(a18,1x,a,g10.4,a,g10.4)',str,'Mean: ',mean(array),' SD: ',stddev(array)
return
end

file1='results_FFM_onrealimages_2456003.dat'
spawn,"awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15}' "+file1+" > aha.dat"
;jd,alfa,a,BS,total(observed,/double),total(observed-a,/double),DS23,DS45,act,exptime,am,x0,y0,radius,albedo
dat1=get_data('aha.dat')
jd1=reform(dat1(0,*))
alfa=reform(dat1(1,*))
a=reform(dat1(2,*))
BS=reform(dat1(3,*))
tot1=reform(dat1(4,*))
tot2=reform(dat1(5,*))
ds23=reform(dat1(6,*))
ds45=reform(dat1(7,*))
act=reform(dat1(8,*))
exptim=reform(dat1(9,*))
am=reform(dat1(10,*))
x0=reform(dat1(11,*))
y0=reform(dat1(12,*))
radius=reform(dat1(13,*))
albedo=reform(dat1(14,*))
eshine=ds45/tot2
n1=n_elements(jd1)
file2='collected_output_EFM_realimages_2456003.txt'
spawn,"awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14}' "+file2+" > aha.dat"
;jd,alfa,a,BS,total(observed,/double),total(observed-a,/double),DS23,DS45,act,exptime,am,x0,y0,radius
dat2=get_data('aha.dat')
jd2=reform(dat2(0,*))
alfa2=reform(dat2(1,*))
a2=reform(dat2(2,*))
BS2=reform(dat2(3,*))
tot12=reform(dat2(4,*))
tot22=reform(dat2(5,*))
ds232=reform(dat2(6,*))
ds452=reform(dat2(7,*))
act2=reform(dat2(8,*))
exptim2=reform(dat2(9,*))
am2=reform(dat2(10,*))
x02=reform(dat2(11,*))
y02=reform(dat2(12,*))
radius2=reform(dat2(13,*))
n2=n_elements(jd2)
eshine2=ds452/tot22
delta=fltarr(n2)
openw,44,'deltas.dat'
for i=0,n1-1,1 do begin
for j=0,n2-1,1 do begin
delta(j)=abs(jd1(i)-jd2(j))
endfor
idx=where(delta eq min(delta))
print,'Smallest jd delta:',delta(idx),idx
print,(dat1(0:13,i)-dat2(0:13,idx))/(0.5*(dat1(0:13,i)+dat2(0:13,idx)))*100.
printf,44,format='(4(1x,f10.4),2(1x,f20.5),8(1x,f10.6))',(dat1(0:13,i)-dat2(0:13,idx))/(0.5*(dat1(0:13,i)+dat2(0:13,idx)))*100.
endfor
close,44
data=get_data('deltas.dat')
;
l=size(data,/dimensions)
for i=0,l(0)-1,1 do begin
names=['jd','alfa','a','BS','TOTall','TOTnoPed','DS23','DS45','act','exptime','am','x0','y0','radius']
; get rid of 4 last lines 
;goprintstats,reform(data(i,0:l(1)-1-4)),names(i)
; for all lines
goprintstats,reform(data(i,*)),names(i)
endfor
;
!P.MULTI=[0,1,1]
!P.CHARSIZE=2
!P.THICK=2
!x.THICK=2
!y.THICK=2
plot,xstyle=3,ystyle=3,jd1-long(jd1),eshine/mean(eshine)*100.,psym=7,xtitle='Fractional JD',title='DS/total (symbols) and albedo (line)',ytitle='Arb. Units'
oplot,jd2-long(jd2),eshine2/mean(eshine)*100.,psym=6
oplot,jd1-long(jd1),albedo/mean(albedo)*100.
;
end
