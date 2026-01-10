data=get_data('out.cat')
 V=reform(data(6,*))
 ra=reform(data(7,*))
 dec=reform(data(8,*))
 l=size(V,/dimensions)
 n=l(0)
 Vlim=4.0
 jd=systime(/julian)
 openw,44,'Close_Bright_stars.dat'
		print,'----------------------------------------'
 for i=0,n-1,1 do begin
     ra1=ra(i)
     dec1=dec(i)
     V1=V(i)
     eq2hor, ra1, dec1, jd, alt, az, ha,  OBSNAME='lund'
     if ((alt gt 10 and (az gt 0 and az le 180)) or (alt gt 30 and (az gt 180))) then begin
         for j=i+1,n-1,1 do begin
             ra2=ra(j)
             dec2=dec(j)
             V2=V(j)
             diffV=abs(v1-v2)
             u=0     ; radians
             gcirc,u,ra1*!dtor, dec1*!dtor,ra2*!dtor, dec2*!dtor,dis
             angle=dis/!pi*180.
             fmt='(f6.2,1(1x,f9.2),1x,a)'
             if (angle le 0.8 and angle gt 0.1 and v1 lt Vlim and v2 lt Vlim and diffV le 0.65 and diffV ge 0.1) then begin
                 print,format=fmt,angle,v1,adstring(ra1,dec1,1)
                 print,format=fmt,angle,v2,adstring(ra2,dec2,1)
                 printf,44,format=fmt,angle,v1,adstring(ra1,dec1,1)
                 printf,44,format=fmt,angle,v2,adstring(ra2,dec2,1)
;		info = QueryGSC([ra1,dec1])
		;print,info.GSCID2
		print,'----------------------------------------'
                 endif
             endfor
         endif
     endfor
 close,44
 end
 
