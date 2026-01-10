!P.MULTI=[0,2,5]
for ifilter=0,4,1 do begin
filtername=['B','V','VE1','VE2','IRCUT']
spawn,"awk '$12 == "+string(ifilter+1)+" {print $13,$2}' MASTERlist_results_preliminary_v1.txt > p"
data=get_data('p')                                                                  
plot,(data(0,*)),data(1,*),psym=7,title=filtername(ifilter),ytitle='Albedo',xtitle='Phase',xstyle=3,ystyle=3
spawn,"awk '$12 == "+string(ifilter+1)+" {print $1,$2}' MASTERlist_results_preliminary_v1.txt > p"
data=get_data('p')                                                                  
plot,(data(0,*)-long(data(0,*))),data(1,*),psym=7,title=filtername(ifilter),ytitle='Albedo',xtitle='JD fraction',xstyle=3,ystyle=3
endfor
end
