spawn,"cat CLEM.profiles_fitted_results_SELECTED_4_multipatch_100_smoo_B.txt | awk '{print $2}' > p"                
data=get_data('p')                           
n=n_elements(data)
m=mean(data)                                 
sd=stddev(data)
!P.MULTI=[0,1,2]
histo,data,min(data)-0.002,max(data)+0.002,0.001,/abs,xtitle='B Albedo',title='One 100-image stack'
xyouts,/normal,0.21,0.9,strcompress('Mean = '+string(m,format='(f9.4)'))
xyouts,/normal,0.21,0.85,strcompress('SD   = '+string(sd,format='(f9.4)'))
xyouts,/normal,0.2,0.82,strcompress(' ('+string(sd/m*100.,format='(f4.1)')+' % of mean).')
oplot,[data(n-1),data(n-1)],[0,10],linestyle=2
end

