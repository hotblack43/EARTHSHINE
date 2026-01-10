JDs=get_data('FORHANS/Chris_list_of_good_observations_after_tunelling.justJDs')
delta=JDs-shift(JDs,-1)
print,delta
end
