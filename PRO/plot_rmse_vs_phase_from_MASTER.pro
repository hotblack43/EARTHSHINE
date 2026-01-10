!P.MULTI=[0,1,5]
for ifilter=0,4,1 do begin
filtername=['B','V','VE1','VE2','IRCUT']
spawn,"awk '$12 == "+string(ifilter+1)+" {print $13,$3,$10}' MASTERlist_results_preliminary_v1.txt > p"
data=get_data('p')                                                                  
;idx=where(erralbedo le median(erralbedo))
plot,data(0,*),data(2,*),psym=7,title=filtername(ifilter),ytitle='Phase',xtitle='RMSE',xstyle=3,ystyle=3
endfor
end
