; plot the lot
 !P.CHARSIZE=2
 !P.CHARthick=2
 !P.thick=2
 !x.thick=2
 !y.thick=2
 filters=['_V_','_B_','_VE1_','_VE2_','_IRCUT_']
 !P.MULTI=[0,2,3]
     for i=0,4,1 do begin
         fname=strcompress(filters(i)+'.dat',/remove_all)
         str='grep '+filters(i)+" MOON_extinctions.dat  | awk '{print $2}' > "+fname
         spawn,str
             k=[-10.0,reform(get_data(fname))]
             histo,xtitle='Extinction coefficient [mags/airmass]',k,0,1,0.05,title=filters(i)
	print,filters(i),median(k)
 	oplot,[median(k),median(k)],[!Y.crange],linestyle=1
         endfor
 end
