!P.MULTI=[0,2,3]
!P.CHARSIZE=1.2
for n=10,30,10 do begin
data=get_data(strcompress('slopes_'+string(n)+'.dat',/remove_all))
err1=reform(data(0,*))
err2=reform(data(1,*))
histo,err1,-2,2,0.06,xtitle='% error on '+string(n)+' years using daily data',yrange=[0,0.2],/zeroline
sd=stddev(err1)
print,'Z1: ',mean(err1)/sd
xyouts,/data,-0.5,0.17,string('S.D='+string(sd,format='(f7.3)')+' %')
histo,err2,-2,2,0.06,xtitle='% error on '+string(n)+' years using 100 annual samples data',yrange=[0,0.2],/zeroline
sd=stddev(err2)
print,'Z2: ',mean(err1)/sd
xyouts,/data,-0.5,0.17,string('S.D='+string(sd,format='(f7.3)')+' %')
endfor
end
