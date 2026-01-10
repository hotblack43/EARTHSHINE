PRO setup_list_of_stars_and_mags,Vmin,Vmax
 openw,2,'out.cat'
 openr,1,'/home/pth/Desktop/ASTRO/EARTHSHINE/EXTINCTION/BScatalog'
 while not eof(1) do begin
     str=''
     readf,1,str
     RAh=fix(strmid(str,75,2))
     RAm=fix(strmid(str,77,2))
     RAs=float(strmid(str,79,4))
     DEsign=strmid(str,83,1)
     DEd=fix(strmid(str,84,2))
     DEm=fix(strmid(str,86,2))
     DEs=fix(strmid(str,88,2))
     Vmag=float(strmid(str,102,5))
     ;    if (Vmag ge min([Vmax,Vmin]) and Vmag le max([Vmax,Vmin])) then begin
     fmt='(i2,1x,i2,1x,f4.1,1x,i3,1x,i3,1x,i3,1x,f5.2,2(1x,f10.6))'
     if (DEsign eq '+') then begin
         print,format=fmt,RAh,RAm,RAs,DEd,DEm,DEs,Vmag,ten(RAh,RAm,RAs),ten(DEd,DEm,DEs)
         printf,2,format=fmt,RAh,RAm,RAs,DEd,DEm,DEs,Vmag,ten(RAh,RAm,RAs),ten(DEd,DEm,DEs)
         endif
     if (DEsign eq '-') then begin
         dec=-ten(DEd,DEm,DEs)
         out=sixty(dec)
         DEd=out(0)
         DEm=out(1)
         DEs=out(2)
         print,format=fmt,RAh,RAm,RAs,DEd,DEm,DEs,Vmag,ten(RAh,RAm,RAs),ten(DEd,DEm,DEs)
         printf,2,format=fmt,RAh,RAm,RAs,DEd,DEm,DEs,Vmag,ten(RAh,RAm,RAs),ten(DEd,DEm,DEs)
         endif
     ;        endif
     endwhile
 close,1
 close,2
 return
 end
 
 ; generate the list of stars to use
 Vmax=4.
 Vmin=-10.
 setup_list_of_stars_and_mags,Vmax,Vmin
 ;
 fmt2='(i5,1x,i2,1x,i2,1x,f4.1,1x,i3,1x,i3,1x,i3,1x,f5.2,1x,f5.1,1x,f6.2,1x,i2,1x,i2,1x,i4,1x,i2,1x,i2,1x,i2,1x,f14.5,1x,f9.1,1x,f4.2)'
 data=get_data('out.cat')
 Vmag=reform(data(6,*))
 ra=reform(data(7,*))
 dec=reform(data(8,*))
 nstars=n_elements(vmag)
 altsun_min=0.0	; never observe if SUn is above this Alt
 obsname='mlo'
 observatory, obsname, obs
 obslon = obs.longitude
 obslat = obs.latitude
 obsalt = obs.altitude
 print,'Observatory lon,lat,alt:',obslon,obslat,obsalt
 wave=0.56
 ; generate list of sun and moon positions of rthe chosen interval
 openw,66,'list_o_stuff.dat'
 for jd=systime(/julian),systime(/julian)+31.,5./60./24. do begin
 ;for jd=julday(07,11,2011,0,0,0),julday(08,11,2011,0,0,0),5./60./24. do begin
     sunpos, JD, RAsun, DECsun
     eq2hor, RAsun, DECsun, jd, altsun, az, ha,  OBSNAME=obsname
     MOONpos, JD, RAmoon, DECmoon
     ramoon=ramoon/15.	; convert to decimal hours
     caldat,jd,a,b,c,d,e,f
     printf,66,format='(8(1x,f20.10),1x,f20.7,1x,f6.1)',RAmoon, DECmoon,a,b,c,d,e,f,double(jd),altsun
     endfor	; loop jd
 close,66
 data=get_data('list_o_stuff.dat')
 decmoon_arr=reform(data(1,*))
 ramoon_arr=reform(data(0,*))
 decmoon_arr=reform(data(1,*))
 a_arr=reform(data(2,*))
 b_arr=reform(data(3,*))
 c_arr=reform(data(4,*))
 d_arr=reform(data(5,*))
 e_arr=reform(data(6,*))
 f_arr=reform(data(7,*))
 jd_arr=reform(data(8,*))
 altsun_arr=reform(data(9,*))
 npos=n_elements(ramoon_arr)
 minDEC=min(DECmoon_arr)
 maxDEC=max(DECmoon_arr)
 print,'Min,Max DEC for Moon:',minDEC,maxDEC
 ; loop over stars
 openw,5,'occultations_mlo.dat'
 printf,5,'----------------------------------------------------------------------------------------------------'
 printf,5,'Times selcetd for Sun below horizon'
 printf,5,'istar  RA         DEC         Vmag  altM  azM   mm dd yyyy hh mi se  JD                dis   %'
 printf,5,'----------------------------------------------------------------------------------------------------'
 for istar=0,nstars-1,1 do begin
     print,'star ',istar,' ...'
     ; loop over time, i.e. Moon positons
     min_dis=1e30
     for ipos=0,npos-1,1 do begin
         if (dec(istar) ge minDEC-1. and dec(istar) le maxDEC+1.) then begin
             RAmoon=ramoon_arr(ipos)
             DECmoon=decMoon_arr(ipos)
             a=a_arr(ipos)
             b=b_arr(ipos)
             c=c_arr(ipos)
             d=d_arr(ipos)
             e=e_arr(ipos)
             f=f_arr(ipos)
             jd=jd_arr(ipos)
	     altsun=altsun_arr(ipos)
             eq2hor, RAmoon, DECmoon, jd, altmoon, azmoon, ha,  OBSNAME=obsname
             airm=airmass(jd,ra(istar)*!dtor,dec(istar)*!dtor,obslat*!dtor,obslon*!dtor,wave)
	    	if (airm lt 2.0 and altsun le altsun_min) then begin 
             eq2hor, ra(istar), dec(istar), jd, altstar, az, ha,  OBSNAME=obsname
             U=1 & GCIRC, U,  RAmoon, DECmoon,ra(istar), dec(istar), DIS
             if (dis le 1000) then begin
	         mphase,jd,illum
                 print,format='(6(1x,f9.1))',sixty(ra(istar)),sixty(dec(istar))
                 print,format='(6(1x,f9.1))',sixty(RAmoon),sixty(DECmoon)
                 print,format=fmt2,istar,sixty(ra(istar)),sixty(dec(istar)),Vmag(istar),altmoon,azmoon,a,b,c,d,e,f,double(jd),dis,illum
                 printf,5,format=fmt2,istar,sixty(ra(istar)),sixty(dec(istar)),Vmag(istar),altmoon,azmoon,a,b,c,d,e,f,double(jd),dis,illum
                 if (dis lt min_dis) then min_dis=dis
                 endif
             endif
             endif
         endfor	; loop ipos
     print,'Minimum distance found:',min_dis
     endfor	; loop istar
 printf,5,'----------------------------------------------------------------------------------------------------'
 close,5
 end
