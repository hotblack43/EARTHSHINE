 common zodiacal,iflag,zoddata,delta_lon,delta_lat
 common otherstuff,lon,lat,phase
 !P.MULTI=[0,1,2]
 !P.CHARSIZE=2
 iflag=1
 ;
 allJD=get_data('Chris_list_good_images.txt')
 openw,33,'zodi.dat'
 for i=0,n_elements(allJD)-1,1 do begin
     get_zodiacal,allJD(i),zd
     print,format='(f15.7,1x,f9.5,3(1x,f9.3))',allJD(i),zd,lon,lat,phase
     printf,33,format='(f15.7,1x,f9.5,3(1x,f9.3))',allJD(i),zd,lon,lat,phase
     endfor
 close,33
 data=get_data('zodi.dat')
 plot,data(2,*),data(3,*),psym=7,xtitle='lamda - lamda_Sun',ytitle='ecliptic lat',title='All Moon Observations'
 !P.MULTI=[0,1,2]
 plot_io,data(4,*),data(1,*),psym=7,xtitle='Moon illuminated fraction',ytitle='V-band counts/second',title='All Moon Observations'
 histo,xtitle='V-band counts/s',data(1,*),0,1,0.01,/abs
 end
