PRO gohisto,x,tit
histo,/abs,x,min(x),max(x),(max(x)-min(x))/11.,xtitle=tit
oplot,[0,0],[!Y.crange],linestyle=2
return
end



file='CLEM.profiles_fitted_results_fan_TEST.txt'
spawn,"cat "+file+" | grep _B_ | grep fits | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12}'  > pB.dat"
Bdata=get_data('pB.dat')
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
;
gohisto,Balbedo,'B'
gohisto,Berralbedo,'!7D!3B'
gohisto,Bpedestal,'Bped'
gohisto,Bxshift,'x-shift'
gohisto,Bcorefactor,'CF'
gohisto,Bcontrast,'contrast'
gohisto,BRMSE,'RMSE'
plot,Balbedo,BRMSE,psym=7,xtitle='B albedo',ytitle='RMSE'
end
