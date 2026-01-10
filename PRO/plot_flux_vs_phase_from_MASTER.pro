spawn,"awk '$12 == 5 {print $13,$21/$11,$14}' MASTERlist_results_preliminary_v1.txt > p"
for k=0.01,0.30,0.003 do begin
data=get_data('p')                                                                  
plot,abs(data(0,*)),-2.5*alog10(data(1,*))-0.14*data(2,*),psym=3,title='V',xtitle='Phase'
idx=where(data(0,*) lt 0)
oplot,abs(data(0,idx)),-2.5*alog10(data(1,idx))-0.14*data(2,idx),psym=3,color=fsc_color('red')
x=abs(data(0,*))
jdx=sort(x)
x=x(jdx)
y=-2.5*alog10(data(1,*))-k*data(2,*)
y=y(jdx)
plot,x,y,psym=7
Result = POLY_FIT( X, Y, 3, CHISQ=chi2,yfit=yhat) 
oplot,x,yhat,color=fsc_color('green')
print,k,chi2
endfor
end
