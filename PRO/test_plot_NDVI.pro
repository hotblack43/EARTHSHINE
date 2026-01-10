file='profiles_fitted_results.txt'
spawn,'grep VE1 '+file+" | awk '{print $1,$2}' > VE1"
spawn,'grep VE2 '+file+" | awk '{print $1,$2}' > VE2"
spawn,'grep _B_ '+file+" | awk '{print $1,$2}' > B"
spawn,'grep _V_ '+file+" | awk '{print $1,$2}' > V"
data=get_data('B')
plot,data(0,*),color=fsc_color('blue')
data=get_data('VE1')
oplot,data(0,*)
data=get_data('VE2')
oplot,data(0,*),color=fsc_color('red')
data=get_data('V')
oplot,data(0,*),color=fsc_color('green')
end
