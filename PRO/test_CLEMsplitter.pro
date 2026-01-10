 PRO makecleanlist,file
 print,'Sectioning the CLEM list'
 str="cat "+file+" | awk '{print $1}' | sort > liste.JD"
 spawn,str
 data=get_data('liste.JD')
 n=n_elements(data)
 t1=long(data(0))-0.5
 t2=long(data(n-1))+1.5
 print,format='(a,2(1x,f15.7))','t1,t2 = ',t1,t2
 ;
 get_lun,fdrftse
 openw,fdrftse,'list_of_CLEMforonenight.txt'
 get_lun,jhgkhguy
 openw,jhgkhguy,'willberemoved.txt'
 for t=t1,t2-1.0d0,1.0d0 do begin
     listname=strcompress('liste.'+string(t,format='(f15.7)')+'-'+string(t+1,format='(f15.7)'))
     str="awk '$1 > "+string(t,format='(f15.7)')+" && $1 < "+string(t+1,format='(f15.7)')+"  ''' "+file+" > "+listname
     spawn,str
     printf,fdrftse,listname
     endfor
 close,fdrftse
 free_lun,fdrftse
 openr,fdrftse,'list_of_CLEMforonenight.txt'
 ; get ridof empty files
 while not eof(fdrftse) do begin
     str=''
     readf,fdrftse,str
     if (file_test(str,/ZERO_LENGTH) eq 0) then begin
         print,str,' is nonzero'
         printf,jhgkhguy,str
         endif
     endwhile
 close,fdrftse
 close,jhgkhguy
 free_lun,fdrftse
 free_lun,jhgkhguy
 spawn,'mv willberemoved.txt list_of_CLEMforonenight.txt'
 print,'Sectioned, clean list of filenames is in file list_of_CLEMforonenight.txt'
 return
 end
 file='CLEM.profiles_fitted_results_SELECTED_5_multipatch_100_smoo_SINGLES.txt'
 makecleanlist,file
 end
