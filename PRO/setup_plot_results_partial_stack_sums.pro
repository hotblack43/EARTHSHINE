;------------------------------------------------------
; SETUP code for later plotting of results from CLEM files with 3 sorts 
; of data: unaligned, aligned with integer shiufts and aligned with subpixel shifts
 
     file='CLEM.testing_OCT4_2014.txt'
;
     spawn,"awk '{print $1}' "+file+" | sort | uniq > CLEM_JDnumber"
     spawn,"grep sum_of "+file+" |  grep UNaligned | awk '{print $2,$3,$11,$15}' > aha"
     spawn,"awk '{print $4}' aha | sed 's/_/ /g' | awk '{print $7}' > oho"
     spawn,"awk '{print $1,$2,$3}' aha > jaja"
     spawn,"paste jaja oho > data_unaligned.dat"
     data=get_data('data_unaligned.dat')
     albedo=reform(data(0,*))
     delta_albedo=(reform(data(1,*)))
     RMSE=(reform(data(2,*)))
     nframes=(reform(data(3,*)))

     
     spawn,"grep sum_of "+file+" | grep aligned | grep integershift |  awk '{print $2,$3,$11,$15}' > aha"
     spawn,"awk '{print $4}' aha | sed 's/_/ /g' | awk '{print $(NF-3)}'  > oho"
     spawn,"awk '{print $1,$2,$3}' aha > jaja"
     spawn,"paste jaja oho > data_aligned_intshift.dat"
     intshift_data=get_data('data_aligned_intshift.dat')
     intshift_albedo=reform(intshift_data(0,*))
     intshift_delta_albedo=(reform(intshift_data(1,*)))
     intshift_RMSE=(reform(intshift_data(2,*)))
     intshift_nframes=(reform(intshift_data(3,*)))
     
     spawn,"grep sum_of "+file+" | grep aligned | grep subpixelshift| awk '{print $2,$3,$11,$15}' > aha"
     spawn,"awk '{print $4}' aha | sed 's/_/ /g' | awk '{print $(NF-3)}'  > oho"
     spawn,"awk '{print $1,$2,$3}' aha > jaja"
     spawn,"paste jaja oho > data_aligned_subpixelshift.dat"
     aligned_subpixelshift_data=get_data('data_aligned_subpixelshift.dat')
     subpixel_albedo=reform(aligned_subpixelshift_data(0,*))
     subpixel_delta_albedo=(reform(aligned_subpixelshift_data(1,*)))
     subpixel_RMSE=(reform(aligned_subpixelshift_data(2,*)))
     subpixel_nframes=(reform(aligned_subpixelshift_data(3,*)))
     ;
end
