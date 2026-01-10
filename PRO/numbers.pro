FUNCTION hej,bmv
value=10^((0.64-bmv)/2.5)
return,value
end

spawn,"grep '945.1' ./CLEM.profiles_fitted_results_SEPT_2013_cubes.txt | grep _B_ | awk '{print $2}' > B"
B=get_data('B')
Bsd=stddev(B)
B=mean(B)
spawn,"grep '945.1' ./CLEM.profiles_fitted_results_SEPT_2013_cubes.txt | grep _V_ | awk '{print $2}' > V"
V=get_data('V')
Vsd=stddev(V)
V=mean(V)
print,'B/V: ',B/V,' +/- ',sqrt((Vsd/V)^2+(Bsd/B)^2)
;
print,'From B-V: ',hej(0.44),' +/- '
end
