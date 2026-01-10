@stuff83.pro
 
 FUNCTION BtimesS,phi_in,t,hapkeG
 ; all angles are in radians
 phi=abs(phi_in)
 g = hapkeG
 if (phi EQ 0.0D) then begin
     B = 2.0
     endif else if (phi GT 0.0D AND phi LT (!DPI/2.0-0.00001)) then begin
     B = 2.0 - (tan(phi)/(2*g)) * (1.0 - exp(-1.0*g/tan(phi))) * (3.0 - exp(-1.0*g/tan(phi)))
     endif else if (phi GE (!DPI/2.0-0.00001)) then begin
     B = 1.0
     endif
 S = (2.0/(3*!DPI)) * ( (sin(phi) + (!DPI-phi)*cos(phi))/!DPI + t*(1.0 - 0.5*cos(phi))^2 )
 fphHapke63 = B*S
 return, fphHapke63
 end
 
 FUNCTION H63W,phase,iangle,oangle
 ; alll angles are in radians
 hapkeG=0.6	; as per Wann Jensen
 t=0.1	; as per Wann Jensen
 value=BtimesS(phase,t,hapkeG)/(1.+cos(oangle)/cos(iangle))
 return,value
 end
 
 PRO finddiametric,i,j,x0,y0,radius,iout,jout
 ; Finds points  on the lunar disc that are diammetrically opposed to the input i,j wrt the centre of the disc
 dx=x0-i
 dy=y0-j
 iout=x0+dx
 jout=y0+dy
 return
 end
 
 FUNCTION albmapint,lon,lat
 common albedomap,albedomap,maplon,maplat,albedoonsphere
 dlon=maplon-lon
 dlat=maplat-lat
 ilon=max(where(dlon lt 0))
 jlat=max(where(dlat lt 0))
 value=albedomap(ilon,jlat)
 return,value
 end
 
 PRO getClemmap,atlas,lon,lat
 lat=readfits('clementinelat.fits')
 lon=readfits('clementinelon.fits')
 atlas=readfits('clementineatlas.fits')
 return
 end
 
 
 PRO getdistances,jd,Rem,Re,Res,Rms
 ; given JD specify all radiaa and distances of interest
 ; Notethat Rem should be distances between surfaces, not centres
 MOONPOS, jd(0), ra, dec, Rem, geolong, geolat
 Re=6371.0	;km
 Res=1.49598e8	; make this JD-dependent
 Rms=1.49598e8   ; make this JD-dependent
 return
 end
 
 PRO getimages,imfile,cubefile,im,cube,lonim,latim,inangleim,outangleim,exptime,jd,x0,y0,radius,phase,ephaseangle
 im=readfits(imfile,imheader)
 print,imfile
 print,cubefile
 get_EXPOSURE,imheader,exptime
 get_info_from_header,imheader,'FRAME',JD
 getcoordsfromheader,imheader,x0,y0,radius,discra
 cube=readfits(cubefile,cubeheader)
 get_info_from_header,cubeheader,'PHSAN_E',ephaseangle
 getphasefromJD,JD,phase	; phase is in degrees as seen from Moon
 lonim=reform(cube(*,*,5))
 latim=reform(cube(*,*,6))
 inangleim=reform(cube(*,*,7))
 outangleim=reform(cube(*,*,8))
 return
 end
 
 PRO getalbedopixelforpixel,im,phase,pstar,ephaseangle
 common distances,Rem,Re,Res,Rms,ph,fL
 common albedomap,albedomap,maplon,maplat,albedoonsphere
 common discinfo,x0,y0,radius
 common imshere,lonim,latim,inangleim,outangleim,fboverfaim,brdfim
 ; Note that DS and BS must be transmission-correctdd before sue
 pstar=im*0.0
 fboverfaim=im*0.0
 brdfim=im*0.0
 albedoonsphere=im*0.0
 
 ph=abs(ephaseangle*!dtor); abs((180-abs(phase))*!dtor)	; Earth's abs phase in radians
 ; Earths phase law (Lambert's)
 fL=(((!pi-ph)*cos(ph)+sin(ph))/!pi)
 geomfactor=(Rem/Re)^2*(Res/Rms)^2/!dpi
 for i=0,512-1,1 do begin
     for j=0,512-1,1 do begin
         r=sqrt((i-x0)^2+(j-y0)^2)
         finddiametric,i,j,x0,y0,radius,iout,jout
         if (r le (1.-4./512.)*radius and inangleim(iout,jout) lt !Pi/2. and inangleim(i,j) gt !Pi/2.) then begin
             antilon=lonim(iout,jout)
             antilat=latim(iout,jout)
             if (antilon ne -999 and antilat ne -999) then begin
                 pBS=albmapint(antilon(0),antilat(0))
                 pDS=albmapint(lonim(i,j),latim(i,j))
                 albedoonsphere(i,j)=pDS
                 albedoonsphere(iout,jout)=pBS
                 pboverpa=(pBS/pDS)	; ratio of lunar albedos in two patches
                 DSa=im(i,j)
                 BSb=im(iout,jout)
                 ;            if (BSb ne 0.0) then begin
                 fboverfa=H63W(phase*!dtor,inangleim(iout,jout),outangleim(i,j))$
;                        /H63W(phase*!dtor,0.0,0.0) 
                         /H63W(phase*!dtor,outangleim(i,j),outangleim(i,j)) 
                 pstar(i,j)=(3./2./fL)*pboverpa*fboverfa*(DSa/BSb)*geomfactor
                 endif
             endif
         endfor
     endfor
 return
 end
 
 
 
 ;=====================================================================
 ; Version 4 of code that evaluates the BBSO method - formula 28 in Qiu et al
 ;=====================================================================
 common distances,Rem,Re,Res,Rms,ph,fL
 common imshere,lonim,latim,inangleim,outangleim,fboverfaim,brdfim
 common albedomap,albedomap,maplon,maplat,albedoonsphere
 common discinfo,x0,y0,radius
 close,/all
 openw,11,'BBSOmethod_pstar.dat'
 openr,55,'Vjds.list'
 openw,44,'plotme.dat'
 while not eof(55) do begin
     jdstr=''
     readf,55,jdstr
	if (jdstr eq 'stop') then stop
     imfile='/data/pth/DARKCURRENTREDUCED/SELECTED_4/'+jdstr+'*.fits*'
;    cubefile='CUBES/cube_Mk*'+jdstr+'*.fits'
     cubefile='CUBES/cube_MkV*'+jdstr+'*.fits*'
;    cubefile='/media/thejll/4678e436-066d-41b4-a961-b2da4651c2b7/data/pth/CUBESnew//cube_Mk*'+jdstr+'*.fits'
     ;getalbedomap,albedomap
     exist1=file_search(imfile)
     exist2=file_search(cubefile)
	print,'Existence of files: ',imfile,cubefile
	help,exist1,exist2
     if (exist1 ne '' and exist2 ne '') then begin
	imfile=exist1
	cubefile=exist2
     getClemmap,albedomap,maplon,maplat
     getimages,imfile,cubefile,im,cube,lonim,latim,inangleim,outangleim,exptime,jd,x0,y0,radius,phase,ephaseangle
     textstr='observed'
     writefits,'im_observed.fits',im
     ideal=reform(cube(*,*,4))
     cubeobs=reform(cube(*,*,0))
     writefits,'im_ideal.fits',ideal
     im=ideal     ; as a test
;    textstr='ideal'
     getdistances,jd,Rem,Re,Res,Rms
     getalbedopixelforpixel,im,phase,pstar,ephaseangle
     ; plot
     !P.MULTI=[0,1,2]
     imtoshow=pstar
     imtoshow(*,y0)=max(pstar)*2
     idx=where(pstar gt 0)
	contour,/isotropic,hist_equal(imtoshow),/cell_fill,nlevels=91,min=0.00001
     plot,pstar(*,y0),yrange=[0,1]
     
     ; save
     writefits,'pstar_'+jdstr+'_'+textstr+'_.fits',pstar
     writefits,'albedoonsphere.fits',albedoonsphere
     idx=where(pstar gt 0)
     if (idx(0) ne -1) then begin
	print,format='(f15.7,2(1x,f12.7))',jd,median(pstar(idx)),robust_sigma(pstar(idx))
	printf,11,format='(f15.7,5(1x,f12.7))',jd,phase,median(pstar(idx)),robust_sigma(pstar(idx)),ph,fL
	endif
	endif
     endwhile
 close,55
 close,11
 close,44
 end
