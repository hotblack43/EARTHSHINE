data=get_data('guessANDtheirquality.dat')
x0_1=reform(data(0,*))
y0_1=reform(data(1,*))
ra_1=reform(data(2,*))
x0_2=reform(data(3,*))
y0_2=reform(data(4,*))
ra_2=reform(data(5,*))
; get rid of time drift in x and y
mnx01=mean(x0_1)
mnx02=mean(x0_2)
mny01=mean(y0_1)
mny02=mean(y0_2)
res=linfit(findgen(n_elements(x0_1)),x0_1,yfit=yhat) & x0_1=x0_1-yhat
res=linfit(findgen(n_elements(x0_1)),x0_2,yfit=yhat) & x0_2=x0_2-yhat
res=linfit(findgen(n_elements(x0_1)),y0_1,yfit=yhat) & y0_1=y0_1-yhat
res=linfit(findgen(n_elements(x0_1)),y0_2,yfit=yhat) & y0_2=y0_2-yhat
print,'x0 start guess: ',mnx01,' +/- ',stddev(x0_1)
print,'x0 final guess: ',mnx02,' +/- ',stddev(x0_2)
print,'y0 start guess: ',mny01,' +/- ',stddev(y0_1)
print,'y0 final guess: ',mny02,' +/- ',stddev(y0_2)
print,'radius start guess: ',mean(ra_1),' +/- ',stddev(ra_1)
print,'radius final guess: ',mean(ra_2),' +/- ',stddev(ra_2)
end
