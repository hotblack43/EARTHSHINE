data=get_data('diff_new_newer.collected_Lap_signature_results.txt')
!P.charsize=1.9
histo,title='!7D!3Albedo when shifting !7a!3 from 1.8 to 1.9',xtitle='Relative difference, in %',/abs,data(1,*),min(data(1,*)),max(data(1,*)),5e-5
end
