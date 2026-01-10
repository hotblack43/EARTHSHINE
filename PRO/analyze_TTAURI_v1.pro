@stuff1.pro
 PRO     get_mediansquares,im,sqAmed,sqBmed,sqCmed,sqDmed
 sqAmed=median(im(0:24,0:24),/double)
 sqBmed=median(im(0:24,511-24:511),/double)
 sqCmed=median(im(511-24:511,0:24),/double)
 sqDmed=median(im(511-24:511,511-24:511),/double)
 return
 end

 PRO     get_meansquares,im,sqA,sqB,sqC,sqD
 sqA=mean(im(0:24,0:24),/double)
 sqB=mean(im(0:24,511-24:511),/double)
 sqC=mean(im(511-24:511,0:24),/double)
 sqD=mean(im(511-24:511,511-24:511),/double)
 return
 end

 PRO fitcircle3points,x1,y1,x2,y2,x3,y3,x0,y0,radius
 ; Fits a circle that passes through the three designated coordinates
 a=[[x1,y1,1.0],[x2,y2,1.0],[x3,y3,1.0]]
 d=[[x1*x1+y1*y1,y1,1.0],[x2*x2+y2*y2,y2,1.0],[x3*x3+y3*y3,y3,1.0]]
 e=[[x1*x1+y1*y1,x1,1.0],[x2*x2+y2*y2,x2,1.0],[x3*x3+y3*y3,x3,1.0]]
 f=[[x1*x1+y1*y1,x1,y1],[x2*x2+y2*y2,x2,y2],[x3*x3+y3*y3,x3,y3]]
 a=determ(a,/check,/double)
 d=-determ(d,/check,/double)
 e=determ(e,/check,/double)
 f=-determ(f,/check,/double)
 ;
 x0=-d/2./a
 y0=-e/2./a
 radius=sqrt((d*d+e*e)/4./a/a-f/a)
 return
 end
 
 PRO make_ellipse,x0,y0,r1,r2,x,y
 angle=findgen(2000)/2000.*360.0
 x=fix(x0+r1*cos(angle*!dtor))
 y=fix(y0+r2*sin(angle*!dtor))
 return
 end
 
 FUNCTION evaluate2,image,x0,y0,r1,r2
 make_ellipse,x0,y0,r1,r2,x,y
 image2=image
 image2(x,y)=max(image)
 ;
 image3=image*0.0
 image3(x,y)=1.0
 number=total(image3*image)
 corr=abs(1d3/number)
 contour,image+image2,/isotropic,xstyle=3,ystyle=3
 return,corr
 end
 
 FUNCTION petersfunc2,a
 ;
 ;       An ellipse is fitted
 ;
 common moon,image
 common keep,bestcorr
 x0=a(0)
 y0=a(1)
 r1=a(2)
 r2=a(3)
 corr=evaluate2(image,x0,y0,r1,r2)
 if (corr lt bestcorr) then begin
     print,format='(4(1x,f8.3),1x,f8.3)',a,corr
     bestcorr=corr
     endif
 ;print,corr,bestcorr
 return,corr
 end
 
 PRO fit_moon2,orgimage,x0_in,y0_in,r1_in,r2_in,x0,y0,r1,r2
 common moon,image
 common keep,bestcorr
 ; PURPOSE   - to find the center and radii of the Moon in the image orgimage
 ; INPUTS    - x0_in,y0_in,r1_in,r2_in: initial guesses of center and radii
 ; OUTPUTS   - x0,y0,r1,r2
 ;----------------------------------------------------
 ;       Note - fits an ellipse
 ;----------------------------------------------------
 x0=x0_in
 y0=y0_in
 r1=r1_in
 r2=r2_in
 image=orgimage
 ;
 a=[x0,y0,r1,r2]
 xi=[[0,0,1,0],[0,0,0,1],[1,0,0,0],[0,1,0,0]]
 ftol=1.e-9
 POWELL,a,xi,ftol,fmin,'petersfunc2'
 ;print,xi
 ;
 x0=a(0)
 y0=a(1)
 r1=a(2)
 r2=a(3)
 ;
 return
 end
 
 PRO findmoonpos,im,x00,y00,radius
 print,'Click on three points on the lunar rim:'
 his=bytarr(256)
 lookat=histomatch(bytscl(im),his*0+1)
 contour,lookat,xstyle=3,ystyle=3,/isotropic
 cursor,x1,y1 
 wait,1
 cursor,x2,y2 
 wait,1
 cursor,x3,y3 
 wait,1
 fitcircle3points,x1,y1,x2,y2,x3,y3,x00,y00,radius
 make_ellipse,x00,y00,radius,radius,x,y
 lookat(x,y)=max(lookat)
 contour,lookat,/isotropic,xstyle=1,ystyle=1
 plots,[x00,x00],[y00,y00],psym=7
 return
 end

 FUNCTION doboostrap,im_in
 im=im_in
 ; will return median and uncertainty (S.D.) of median for im
 ; the two values are returned as an array through the function name
 ; uncertainty is estimated using 'Bootstrap with replacement'
 l=size(im)
 if (l(0) eq 1) then begin
     ny=long(l(1))
     nx=1
     endif
 if (l(0) eq 2) then begin
     l=size(im,/dimensions)
     nx=long(l(0))
     ny=long(l(1))
     endif
 nboot=100
 for iboot=0,nboot-1,1 do begin
     idx=randomu(seed,nx*ny)*long(nx*ny)
     if (iboot eq 0) then list=median(im(idx))
     if (iboot gt 0) then list=[list,median(im(idx))]
     endfor
 array=fltarr(2)
 array(0)=median(im)
 array(1)=stddev(list)
 return,array
 end
 
 PRO model_position,x,y,yy,tstr
 ;--------------------------------------------------
 ; will read prepared files of polynomial fits for 
 ; the position of the Moon and a Star in a special set of CCD images
 ;--------------------------------------------------
 ; x - the JD
 ; y - not used
 ; yy - the output - i.e. the fitted coordinate (X or Y)
 ; tstr - the name to be used for building the filename: tstr= 'Xstar' etc.
 ;--------------------------------------------------
 openr,1,strcompress(tstr+'.fit')
 readf,1,order
 jdoffset=0.0d0
 readf,1,jdoffset
 for i=0,order,1 do begin
     xx=0.0d0
     readf,1,xx
     if (i eq 0) then yy=xx*(x-jdoffset)^i
     if (i gt 0) then yy=yy+xx*(x-jdoffset)^i
     endfor
 close,1
 ; special for Star
 if (tstr eq 'Xstar') then yy=365.0d0+(390.0d0-365.0d0)/(.148709d0-.05050d0)*(x-2455769.05050d0)
 if (tstr eq 'Ystar') then yy=223.0d0+(214.0d0-223.0d0)/(.148709d0-.05050d0)*(x-2455769.05050d0)
 return
 end
 
 PRO detailsonmoon,refim_in,x0DS,y0DS,x0BS,y0BS,wDS,hDS,wBS,hBS
 refim=refim_in
 ; get some surface details on the Moon in the refimage
 ; first DS
 offset=0
 lhs=34+offset
 rhs=85+offset
 upper=265
 lower=171
 contour,histomatch(refim,fltarr(256)*0+1),/isotropic
 print,'Define DS box with two clicks - upper,left and lower,right:'
 cursor,lhs,upper
 wait,1
 cursor,rhs,lower
 wait,1
 wDS=rhs-lhs
 hDS=upper-lower
 x0DS=(rhs+lhs)/2.
 y0DS=(upper+lower)/2.
 ; in future, get lhs,rhs,upper, and lower from cursor
 ; then BS
 lhs=273+offset
 rhs=286+offset
 upper=226
 lower=196
 contour,refim,/isotropic
 print,'Define BS box with two clicks - upper,left and lower,right:'
 cursor,lhs,upper
 wait,1
 cursor,rhs,lower
 wait,1
 wBS=rhs-lhs
 hBS=upper-lower
 x0BS=(rhs+lhs)/2.
 y0BS=(upper+lower)/2.
 return
 end
 
 PRO refstarinrefim,refim,x0,y0
 ; get the coords of the reference star in the refimage
 x0=378
 y0=218
 ; note: later get star's coords from cursor
 return
 end
 
 PRO    getmoonstuff,avtime,alt_moon,az_moon,am,lat,lon,obsname
 moonpos, avtime, RAmoon, DECmoon, Dem
 eq2hor, RAmoon, DECmoon, avtime, alt_moon, az_moon, ha=ha,  OBSNAME=obsname
 am = airmass(avtime,ramoon*!dtor,decmoon*!dtor,lat,lon,wave,pressure,temp,relhum)
 return
 end
 
 PRO go_clean_lunar_disc,res,theta,theta_step,clean_image,radii,angle,removed_light,flag1
 ; find the cone of the image that can be corrected using the coefficients in 'res'
 ;------------------------------------------------------
 idx=where(angle gt theta and angle le theta+theta_step)
 for i=0L,n_elements(idx)-1,1 do begin
     if (flag1 eq 0) then begin
         ; y=a-b*x
         correction=radii(idx(i))*res(1)+res(0)
         clean_image(idx(i))=clean_image(idx(i))-correction
         removed_light(idx(i))=correction
         endif
     if (flag1 eq 1) then begin
         ; y=-b*log10(x)
         correction=alog10(radii(idx(i)))*res(1)+res(0)
         clean_image(idx(i))=clean_image(idx(i))-correction
         removed_light(idx(i))=correction
         endif
     endfor
 return
 end
 
 PRO go_fit_line,filename,intercept,slope,res,p,flag1
 common fittype,if_ladfit
 common refstuff,x00ref,y00ref,radius,x0DS,y0DS,x0BS,y0BS,wDS,hDS,wBS,hBS,x0ref,y0ref,x00,Y00
 flag1=0
 ; will fit a straight line to the data in
 p=-911
 data=get_data(filename)
 number=reform(data(0,*))
 theta=reform(data(1,*))
 x=reform(data(2,*))
 y=reform(data(3,*))
 sigs=reform(data(4,*))
 idx=where(x gt 1.05*radius)
 if (n_elements(idx) ge 3) then begin
     res=linfit(x(idx),y(idx),sigma=par_sigs,/double,yfit=yfit,measure_errors=sigs(idx),prob=p)
     if (if_ladfit eq 1) then res=linfit(x(idx),y(idx),/double)
     window,1,xsize=400,ysize=300
     plot,x(idx),y(idx),psym=7,ystyle=1,title='Angle='+string(theta(0)),xtitle='Distance from Moon ctr.'
     errplot,x(idx),y(idx)-sigs(idx),y(idx)+sigs(idx)
     oplot,x(idx),yfit
     if (p gt 0.1) then print,p,' a probable good fit'
     if (p le 0.1) then begin
         print,p,' NOT a good fit'
         ;	gospecial,x(idx),y(idx),sigs(idx)
         ;	print,'Am gonna try a log fit!'
         ;        res=linfit(alog10(x(idx)),(y(idx)),sigma=par_sigs,/double,yfit=yfit,measure_errors=(sigs(idx)),prob=p)
         ;        if (p gt 0.1) then begin
         ;	print,'Wow, actually, a log fit was better!'
         ;    plot,alog10(x(idx)),(y(idx)),psym=7,ystyle=1,title='Angle='+string(theta(0)),xtitle='alog10(Distance from Moon ctr.)';,ytitle='log!d10!n'
         ;    errplot,alog10(x(idx)),(y(idx)-sigs(idx)),(y(idx)+sigs(idx))
         ;    oplot,alog10(x(idx)),yfit
         ;	flag1=1
         ;    endif
         endif
     endif
 return
 end
 
 FUNCTION vinkel,dy,dx
 ; calculates the angle between vector (dx,dy) and 
 ; the positive y axis (like azimuth) in degrees
 ;.......................................................
 if (n_elements(dx) gt 1) then begin
     l=size(dx,/dimensions)
     hejsa=fltarr(l(0),l(1))*0.0
     endif
 if (n_elements(dx) eq 1) then begin
     hejsa=fltarr(1)*0.0
     endif
 ; 1st quadrant positive dx positive dy
 idx=where(dy ge 0 and dx ge 0)
 if (idx(0) ne -1) then begin
     grundhejsa=90.-atan(abs(dy(idx)),abs(dx(idx)))/!dtor
     hejsa(idx)=grundhejsa
     endif
 ; 2nd quadrant negative dx positive dy
 idx=where(dy ge 0 and dx lt 0)
 if (idx(0) ne -1) then begin
     grundhejsa=90.-atan(abs(dy(idx)),abs(dx(idx)))/!dtor
     hejsa(idx)=360.-grundhejsa
     endif
 ; 3rd quadrant negative dx negative dy
 idx=where(dy lt 0 and dx lt 0)
 if (idx(0) ne -1) then begin
     grundhejsa=90.-atan(abs(dy(idx)),abs(dx(idx)))/!dtor
     hejsa(idx)=180.+grundhejsa
     endif
 ; 4th quadrant positive dx negative dy
 idx=where(dy lt 0 and dx ge 0)
 if (idx(0) ne -1) then begin
     grundhejsa=90.-atan(abs(dy(idx)),abs(dx(idx)))/!dtor
     hejsa(idx)=180.-grundhejsa
     endif
 return,hejsa
 end
 
 
 PRO remove_scattered_light_linear_method,observed_image_in,clean_image,inside,outside
 common logs,yes_log
 common moonres,im1,im2,im3
 common uselater,im4,difference
 common fitedresults,P
 common type,typeflag
 common circleSTUFF,circle,moon_coords
 common vizualise,if_vizualise
 common paths,path
 ; BBSO - i.e. sky extrapolation - method
 ; take the image observed_image and generate a correction for the scattered light
 ; place the corrected image in clean_image
 ;----------------------------------------------------
 if (yes_log eq 1) then observed_image=alog10(observed_image_in)
 if (yes_log ne 1) then observed_image=observed_image_in
 clean_image=observed_image
 removed_light=clean_image*0.0d0
 l=size(observed_image,/dimensions)
 x0=moon_coords(0)
 y0=moon_coords(1)
 rtod=180.0d0/!pi
 ; fill the fields radius and angle with the values
 x=findgen(l(0))
 y=findgen(l(1))
 xx=rebin(x,[l(0),l(1)])
 yy=transpose(rebin(y,[l(1),l(0)]))
 radii=sqrt((xx-x0)^2+(yy-y0)^2)
 angle=vinkel((yy-y0),(xx-x0))
 ; loop over angle and radii
 nbins=100
 binsize=7.
 p_lim=0.01
 radbins=indgen(nbins)*binsize
 theta_step=10.
 fstr='(f8.3,1x,f9.2,1x,f8.3,1x,i5,1x,i2)'
 for theta=180.0d0,360.0d0-theta_step,theta_step do begin
     openw,44,path+'bins.dat'
     print,'Theta=',theta
     yesser=0
     for ibin=0,nbins-2,1 do begin
         showimage=observed_image
         idx=where(radii ge radbins(ibin) and radii lt radbins(ibin+1) and angle ge theta and angle lt theta+theta_step)
         if (idx(0) ne -1 and n_elements(idx) ge 4) then begin
             if (if_vizualise eq 1) then begin	
                 showimage(idx)=max(showimage)
                 contour,showimage,xstyle=3,ystyle=3,/isotropic
                 endif
             dummy=doboostrap(observed_image(idx))
             medi=dummy(0)
             sig=dummy(1)*4.
             printf,44,ibin,theta,median(radii(idx)),medi,sig
             yesser=1
             endif
         endfor	; end ibin
     close,44
     if (yesser ne 0) then begin
         go_fit_line,path+'bins.dat',intercept,slope,res,p,flag1
         if (p gt p_lim and p ne -911) then go_clean_lunar_disc,res,theta,theta_step,clean_image,radii,angle,removed_light,flag1
         endif
     endfor	; end theta
 if (yes_log eq 1) then clean_image=10^(clean_image)
 return
 end
 
 PRO make_ellipse,x0,y0,r1,r2,x,y
 angle=findgen(2000)/2000.*360.0
 x=fix(x0+r1*cos(angle*!dtor))
 y=fix(y0+r2*sin(angle*!dtor))
 return
 end

 PRO remove_scattered_light_pedstal_method,im,clean_image,inside,outside
 get_meansquares,im,sqA,sqB,sqC,sqD
 pedestal=median([sqA,sqB,sqC,sqD])
 clean_image=im-pedestal
 return
 end
 
 PRO     get_DS_BS,im,avtime,DS,BS,delta_DS,delta_BS,offX,offY
 common circleSTUFF,circle,moon_coords
 common refstuff,x00ref,y00ref,radius,x0DS,y0DS,x0BS,y0BS,wDS,hDS,wBS,hBS,x0ref,y0ref,x00,Y00
 ; x00ref,y00ref,radius - center and radius of Moon in reference image
 ; x0ref,y0ref - coords of star in reference image
 ; x0DS,y0DS,wDS,hDS - x,y,width,height of DS patch, in reference image
 ; x0BS,y0BS,wBS,hBS - x,y,width,height of BS patch, in reference image
 delta_DS=-911
 delta_BS=-911
 l=size(im,/dimensions)
 x=indgen(l(0))
 y=indgen(l(1))
 ; Moon disc center of any offset image is at
 x00=x00ref+offX
 Y00=y00ref+offY
 moon_coords=[X00,Y00]
 print,'In this image I think Moon ctr. is at : ',x00,y00
 ; DS box relative to moon centre of any offset image is at
 DSx0=x0DS-wDS/2.-x00ref+x00
 DSx1=x0DS+wDS/2.-x00ref+x00
 DSy0=y0DS-hDS/2.-y00ref+y00
 DSy1=y0DS+hDS/2.-y00ref+y00
 ; BS box relative to moon centre of any offset image is at
 BSx0=x0BS-wBS/2.-x00ref+x00
 BSx1=x0BS+wBS/2.-x00ref+x00
 BSy0=y0BS-hBS/2.-y00ref+y00
 BSy1=y0BS+hBS/2.-y00ref+y00
 ; In-frame coords of DS and BS:
 DSxran=where((x ge DSx0) and (x lt DSx1))
 DSyran=where((y ge DSy0) and (y lt DSy1))
 BSxran=where((x ge BSx0) and (x lt BSx1))
 BSyran=where((y ge BSy0) and (y lt BSy1))
 ;
 DS=-911
 delta_DS=-911
 BS=-911
 delta_BS=-911
 print,'Coords for DS: ',min(DSxran),max(DSxran),min(DSyran),max(DSyran)
 print,'Coords for BS: ',min(BSxran),max(BSxran),min(BSYRAN),max(BSYRAN)
 ; DS box inside 
 xvals=[min(DSxran),max(DSxran)]
 yvals=[min(DSyran),max(DSyran)]
 ;
 if (min(xvals) ge 0 and max(xvals) le l(0)-1 and min(yvals) ge 0 and max(yvals) le l(1)-1) then begin
     print,'DS 1:',ds
     dummy=doboostrap(im(min(DSxran):max(DSxran),min(DSyran):max(DSyran)))
     DS=dummy(0)
     delta_DS=dummy(1)
     ;
     im(min(DSxran):max(DSxran),min(DSyran):max(DSyran))=max(im)
     endif
 xvals=[min(BSxran),max(BSxran)]
 yvals=[min(BSyran),max(BSyran)]
 ;
 if (min(xvals) ge 0 and max(xvals) le l(0)-1 and min(yvals) ge 0 and max(yvals) le l(1)-1) then begin
     dummy=doboostrap(im(min(BSxran):max(BSxran),min(BSYRAN):max(BSYRAN)))
     BS=dummy(0)
     delta_BS=dummy(1)
     ;
     im(min(BSxran):max(BSxran),min(BSYRAN):max(BSYRAN))=max(im)
     endif
 ; show circle rim 
 make_ellipse,x00,y00,radius,radius,x,y
 im(x,y)=max(im)
 print,'Found DS,BS: ',DS,' +/- ',delta_DS,BS,' +/- ',delta_BS
 return
 end
 
 PRO	get_time_of_average,header,avtime
 ;AV_TIME =        2455769.04997 /Mean time of capture (JD) 
 idx=where(strpos(header, 'AV_TIME') eq 0)
 str='999'
 if (idx(0) ne -1) then str=header(idx)
 avtime=double(strmid(str,15,16))
 if (avtime lt 2e5) then stop
 ;print,str
 ;print,format='(f20.10)',avtime
 ;stop
 return
 end
 
 
 
 PRO get_inner_circle,im,x0,y0,inner_radius,star_and_sky,ninner
 common radius,r
 star_and_sky=-911
 idx=where(r le inner_radius)
 if (idx(0) ne -1) then begin
     ninner=n_elements(idx)
     print,ninner,' pixels inside inner circle.'
     print,'Circle: min and max',min(im(idx)),max(im(idx))
     star_and_sky=total(im(idx))
     endif
 print,'star_and_sky counts from inner circle: ',star_and_sky
 return
 end
 
 PRO get_sky_2,im_in,x0,y0,xmoon,ymoon,medianval
 im=im_in
 ; distance to strar from lunar disc ctr.
 d=sqrt((x0-xmoon(0))^2+(y0-ymoon(0))^2)
 ; fill the fields radius and angle with the values
 l=size(im,/dimensions)
 l=size(im,/dimensions)
 x=findgen(l(0))
 y=findgen(l(1))
 xx=rebin(x,[l(0),l(1)])
 yy=transpose(rebin(y,[l(1),l(0)]))
 ; radius from moon ctr to point
 radii=sqrt((xx-xmoon(0))^2+(yy-ymoon(0))^2)
 angle=vinkel((yy-ymoon(0)),(xx-xmoon(0)))
 ; angle (as Azimuth) Moon ctr. to star:
 dy=fltarr(1)
 dx=fltarr(1)
 dy(0)=(y0-ymoon(0))
 dx(0)=(x0-xmoon(0))
 theta=vinkel(dy,dx)
 delta_r=10.
 ;find all points in the two annulus patches on either side of the star
 idx=where((radii ge d(0)-delta_r/2. and radii le d(0)+delta_r/2.) and (angle ge theta(0)+5. and angle le theta(0)+15.))
 patch1=median(im(idx))
 im(idx)=max(im)
 idx=where((radii ge d(0)-delta_r/2. and radii le d(0)+delta_r/2.) and (angle le theta(0)-5. and angle ge theta(0)-15.))
 patch2=median(im(idx))
 im(idx)=max(im)
 print,'Mean sky value from annulus patches:',(patch1+patch2)/2.0
 medianval=(patch1+patch2)/2.0
 window,3
 contour,histomatch(im,findgen(256)*0+1),/isotropic,xstyle=3,ystyle=3
 window,1
 ;stop
 return
 end
 
 PRO get_sky_1,im,x0,y0,outer_radius,inner_radius,medianval
 ; Method 1 for finding sky brightness - annulus
 common radius,r
 medianval=-911
 idx=where(r gt inner_radius and r le outer_radius)
 if (idx(0) ne -1) then begin
     print,n_elements(idx),' pixels inside anulus.'
     print,'Anulus: min and max',min(im(idx)),max(im(idx))
     medianval=median(im(idx))
     endif
 print,'Median value of pixels inside anulus: ',medianval
 return
 end
 
 
 
 ;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 common radius,r
 common logs,yes_log
 common paths,path
 common fittype,if_ladfit
 common vizualise,if_vizualise
 common refstuff,x00ref,y00ref,radius,x0DS,y0DS,x0BS,y0BS,wDS,hDS,wBS,hBS,x0ref,y0ref,x00,Y00
 ;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 skymethod=2	; =1 (use annulus), =2 (use 'annulus panels')
 yes_remove_light=2	; =1 removing sc. light w. linear approx on DS.
 ;                        =2 remove scattered light with 'just remove the pedestal' idea.
 yes_log=0	; if =1 work on log10 of image
 if_vizualise=0	; whether or not to show lots of animated graphs
 path=''
 if_ladfit=1	; using LINFIT or LADFIT (=1)
 ; give ra and dec of the star tau Tauri (in radians)
 ra=ten(4,42,14)*15.0/180.0d0*!pi
 dec=ten(22,57,25)/180.0d0*!pi
 ; lon,lat of MLO
 obsname='mlo'
 wave=0.56
 pressure=550.0
 temp=5.0
 relhum=20.0
 bias=double(readfits('DAVE_BIAS.fits'))
 flat=readfits('../Flattened_FF_nolinsubtracted.fits')
 flat=flat*0+1.0
 ;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 openw,92,'positions.dat'
 observatory,obsname,obs_struct
 lat=obs_struct.latitude
 lat=lat*!dtor
 ; note the minus sign - lon follows observatory.pro and -lon what zensun expects (USA is neg lon)
 lon=-obs_struct.longitude
 lon=2.*!pi-lon*!dtor
 print,'MLO: lon,lat: ',lon,lat
 ;
 r=dblarr(512,512)
 l=size(bias,/dimensions)
 ncols=l(0)
 nrows=l(1)
 ; first find and detail a good reference image
 ; Note: Image should show whole rim, a bit fo sky ona ll sides and a star
 refim=readfits('USINGFLAT/AVG_tau_TAURI0058.fits',h)/flat
 ;refim=readfits('TEMP/AVG_tau_TAURI0058.fits',h)/flat
 get_time_of_average,h,avtime0
 model_position,avtime0,avtime0*0,x00refim,'Xmoon'
 model_position,avtime0,avtime0*0,Y00refim,'Ymoon'
 findmoonpos,refim,x00ref,y00ref,radius
 ; get some surface details on the Moon in the refimage
 detailsonmoon,refim,x0DS,y0DS,x0BS,y0BS,wDS,hDS,wBS,hBS
 ; get the coords of the reference star in the refimage
 refstarinrefim,refim,x0ref,y0ref
 files=file_search('TEMP/*TAURI*',count=n)
 ;files=file_search('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455769/*TAURI*',count=n)
 b=[19.088867,      6251.6837,     0.71439064,     0.71972779,      373.09177,      218.99225, 0.0]
 x0=b(4)
 y0=b(5)
 for i=0,ncols-1,1 do begin
     for j=0,nrows-1,1 do begin
         r(i,j)=sqrt(float(i-x0)^2+float(j-y0)^2)
         endfor
     endfor
 outer_radius=25.*1
 inner_radius=12.*1
 reference=refim
 shifted_stack=reference
 openw,2,strcompress('photometry_TTAURI.dat',/remove_all)
 for ibild=0,n-1,1 do begin
     print,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
     if (ibild le 9) then numstr='000'+string(ibild)
     if (ibild gt 9 and ibild le 99) then numstr='00'+string(ibild)
     if (ibild gt 99 and ibild le 999) then numstr='0'+string(ibild)
     if (ibild gt 990) then numstr=+string(ibild)
     print,'Image # ',ibild,' of ',n
     im=double(readfits(files(ibild),h))/flat
     get_time_of_average,h,avtime
     ; calculate azimuth and altitude for the Moon
     getmoonstuff,avtime,alt_moon,az_moon,am,lat,lon,obsname
     jdx=where(r gt 1.*outer_radius)
     mask=im*0.0+1.0
     mask(jdx)=0.0
     ; estimate position of star given previously prepared model 
     ; of the motion of the star across the image plane
     model_position,avtime,avtime*0.0,X0,'Xstar'
     model_position,avtime,avtime*0.0,Y0,'Ystar'
     print,'Think star is at : ',x0,y0
     for i=0,ncols-1,1 do begin
         for j=0,nrows-1,1 do begin
             r(i,j)=sqrt(float(i-x0)^2+float(j-y0)^2)
             endfor
         endfor
     if (skymethod eq 1) then begin
         get_sky_1,im,x0,y0,outer_radius,inner_radius,medianval
         get_inner_circle,im,x0,y0,inner_radius,star_and_sky,ninner
         sky1=medianval*!pi*inner_radius^2
         sky2=medianval*ninner
         print,'Two evaluations of sky contrib:',sky1,sky2
         sky=sky2
         star=star_and_sky-sky
         endif
     ;  use model of positions:
     model_position,avtime,avtime*0,x00,'Xmoon'
     model_position,avtime,avtime*0,Y00,'Ymoon'
     xOFFSET=x00-x00refim
     yOFFSET=y00-y00refim
     offset=[xOFFSET,yOFFSET,0.0]
     if (skymethod eq 2) then begin
         get_sky_2,im,x0,y0,x00,y00,medianval
         get_inner_circle,im,x0,y0,inner_radius,star_and_sky,ninner
         sky1=medianval*!pi*inner_radius^2
         sky2=medianval*ninner
         print,'Two evaluations of sky contrib:',sky1,sky2
         sky=sky2
         star=star_and_sky-sky
         endif
     ; get DS and BS
     im_touse=im
     ;----------------------------
     window,0,xsize=512,ysize=512,title='Image being analyzed'
     get_DS_BS,im_touse,avtime,DS,BS,delta_DS,delta_BS,offset(0),offset(1)
     ;----------------------------
     printf,92,format='(f15.7,4(1x,f9.4))',avtime,x00,y00,x0,y0
     ;----------------------------
     DSsub=-911
     BSsub=-911 
     delta_DSsub=-911
     delta_BSsub=-911
     if (yes_remove_light eq 1) then begin ; and (DS ne -911 and BS ne -911)) then begin
         remove_scattered_light_linear_method,im,clean_image,inside,outside
         writefits,strcompress('TEMP/cleaned_image'+numstr+'.fits',/remove_all),clean_image
         ;----- Redo DS/BS analysis after cleaning of image
         im_touse=clean_image
         get_DS_BS,im_touse,avtime,DSsub,BSsub,delta_DSsub,delta_BSsub,offset(0),offset(1)
         endif
     if (yes_remove_light eq 2) then begin 
         remove_scattered_light_pedstal_method,im,clean_image,inside,outside
         writefits,strcompress('TEMP/cleaned_image'+numstr+'.fits',/remove_all),clean_image
         ;----- Redo DS/BS analysis after cleaning of image
         im_touse=clean_image
         get_DS_BS,im_touse,avtime,DSsub,BSsub,delta_DSsub,delta_BSsub,offset(0),offset(1)
         endif
     ;----------------------------
     printf,2,format='(f15.7,1x,f6.2,2(1x,f14.5),8(1x,f14.5))',avtime,am,star,star_and_sky,DS,BS,DSsub,BSsub,delta_DS,delta_BS,delta_DSsub,delta_BSsub
     ; also display stretched image
     output_image = HistoMatch(im, bytarr(256)*0+1)
     output_image(min([511,x0]),0:nrows-1)=max(output_image)
     output_image(0:ncols-1,y0)=max(output_image)
     shifted_im=shift_sub(im,-offset(0),-offset(1))
     shifted_stack=[[[shifted_stack]],[[shifted_im]]]
     ;....
     window,0,xsize=512,ysize=512,title='Shifted image'
     ;tvscl,shifted_im
     contour,shifted_im,xstyle=3,ystyle=3
     ;....
     window,1,xsize=512,ysize=512,title='Image DS and BS analysed'
     ;tvscl,output_image
     contour,im_touse,xstyle=3,ystyle=3
     ;....
     window,2,xsize=512,ysize=512,title='Star in image'
     ;tvscl,output_image*mask
     contour,output_image*mask,xstyle=3,ystyle=3
     endfor
 print,'+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++'
 close,2
 shifted_stack_avg=avg(shifted_stack,2)
 writefits,'shifted_stack_avg.fits',shifted_stack_avg
 close,92
 end
 
