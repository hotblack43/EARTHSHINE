spawn,"cat CLEM.profiles_fitted_results_SELECTED_4_multipatch_100_smoo_B.txt | awk '{print $2}' > p"                
data=get_data('p')
histo,data,0.33,0.37,0.0014654,/abs,xtitle='B albedo'                                                                                 
print,mean(data),stddev(data)/mean(data)*100.,stddev(data)/mean(data)*100./sqrt(n_elements(data)-1),n_elements(data)
end

