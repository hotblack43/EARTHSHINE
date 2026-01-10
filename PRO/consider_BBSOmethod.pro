@stuff83.pro
 PRO godosomeMC,array,medval,SDmedval
 n=n_elements(array)
 nMC=1000
 liste=[]
 for iMC=0,nMC-1,1 do begin
   idx=long(randomu(seed,n)*n)
   liste=[liste,median(array(idx))]
 endfor
 medval=median(liste)
 SDmedval=stddev(liste)
 return
 end

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
 common tandg,t,hapkeG
 ; alll angles are in radians
 value=BtimesS(phase,t,hapkeG)/(1.+cos(oangle)/cos(iangle))
 return,value
 end
 
 PRO finddiametric,i,j,x0,y0,radius,iout,jout
 common pixels,iDS,jDS,iBS,jBS
 ; Finds points  on the lunar disc that are diammetrically opposed to the input i,j wrt the centre of the disc
 dx=x0-i
 dy=y0-j
 iout=x0+dx
 jout=y0+dy
 iDS=i
 jDS=j
 iBS=iout
 jBS=jout
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
 lat=readfits('/home/pth/SCI/EARTHSHINE/clementinelat.fits',/silent)
 lon=readfits('/home/pth/SCI/EARTHSHINE/clementinelon.fits',/silent)
;atlas=readfits('clementineatlas.fits',/silent)
 atlas=readfits('/home/pth/SCI/EARTHSHINE/ClemScaledWildeyatlas.fits',/silent)
 lat=double(lat)
 lon=double(lon)
 atlas=double(atlas)
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
 
 PRO getimages,imfile,cubefile,im,cube,lonim,latim,inangleim,outangleim,obsangleim,exptime,jd,x0,y0,radius,phase,ephaseangle
 common grimaldi,grimx,grimy
 im=double(readfits(imfile,imheader,/silent))
 print,imfile
 print,cubefile
 get_EXPOSURE,imheader,exptime
 get_info_from_header,imheader,'FRAME',JD
 getcoordsfromheader,imheader,x0,y0,radius,discra
 cube=double(readfits(cubefile,cubeheader,/silent))
 get_info_from_header,cubeheader,'PHSAN_E',ephaseangle
 getphasefromJD,JD,phase	; phase is in degrees as seen from Moon
 lonim=reform(cube(*,*,5))
 latim=reform(cube(*,*,6))
 inangleim=reform(cube(*,*,7))
 outangleim=reform(cube(*,*,8))
 obsangleim=reform(cube(*,*,9))
 ; find the Grimaldi pixel
 d=((-(5.+12./60.)-latim)^2+(-68.-36./60.-lonim)^2)
 idx=where(d eq min(d))
 coords=array_indices(lonim,idx)
 grimx=coords(0)
 grimy=coords(1)
 return
 end
 
 PRO getalbedopixelforpixel,im,phase,pstar,ephaseangle
 common distances,Rem,Re,Res,Rms,ph,fL
 common albedomap,albedomap,maplon,maplat,albedoonsphere
 common discinfo,x0,y0,radius
 common imshere,lonim,latim,inangleim,outangleim,obsangleim,fboverfaim,brdfim
 common grimaldi,grimx,grimy
 common tandg,t,hapkeG
 ; Note that DS and BS must be transmission-correctdd before sue
 pstar=im*0.0
 fboverfaim=im*0.0
 brdfim=im*0.0
 albedoonsphere=im*0.0
                 pboverpa_image=im*0.0
                 fboverfa_image=im*0.0
                 fb_image=im*0.0
                 fa_image=im*0.0
                 DSoverBS_image=im*0.0
 
;ph=abs(ephaseangle*!dtor); abs((180-abs(phase))*!dtor)	; Earth's abs phase in radians
 ph=abs((180-abs(phase))*!dtor)	; Earth's abs phase in radians
 ; Earths phase law (Lambert's)
 tvalue=0.1
 fL=(((!dpi-abs(ph))*cos(ph)+sin(abs(ph)))/!dpi)
 geomfactor=(Rem/Re)^2*(Res/Rms)^2/!dpi
 for i=0,512-1,1 do begin
     for j=0,512-1,1 do begin
         r=sqrt((i-x0)^2+(j-y0)^2)
         if (r le (1.-4./512.)*radius) then begin
         finddiametric,i,j,x0,y0,radius,iout,jout
         if (inangleim(iout,jout) lt !dpi/2. and inangleim(iout,jout) ne 0.0 and inangleim(i,j) gt !dpi/2.) then begin
             antilon=lonim(iout,jout)
             antilat=latim(iout,jout)
             if (antilon ne -999 and antilat ne -999) then begin
                 pDS=albmapint(lonim(i,j),latim(i,j))
                 pBS=albmapint(antilon(0),antilat(0))
                 albedoonsphere(i,j)=pDS
                 albedoonsphere(iout,jout)=pBS
                 pboverpa=(pBS/pDS)	; ratio of lunar albedos in the pixel-pair 
                 DSa=im(i,j)
                 BSb=im(iout,jout)
                 fangles=cos(outangleim(i,j))*(cos(inangleim(iout,jout))+cos(obsangleim(i,j)))/$
                   (cos(inangleim(iout,jout))*(cos(obsangleim(i,j))+cos(outangleim(i,j))))
	         pboverpa_image(i,j)=pboverpa
                 fb_image(i,j)=fb
                 fa_image(i,j)=fa
                 DSoverBS_image(i,j)=(DSa/BSb)
                 mystery=1./(2.*0.2372)
                 pstar(i,j)=(2./3./!dpi/fL)*DSa/BSb*pboverpa*mystery*BtimesS(phase*!dtor,t,hapkeG)/fangles*geomfactor
	; Grimaldi
	if (i eq grimx and j eq grimy) then begin
        albedoonsphere(i,*)=max(im)
        albedoonsphere(*,j)=max(im)
        albedoonsphere(iout,*)=max(im)
        albedoonsphere(*,jout)=max(im)
	endif
                 endif
             endif
             endif
         endfor
     endfor
 return
 end
 
 
 
 ;=====================================================================
 ; Version 6 of code that evaluates the BBSO method - formula 28 in Qiu et al
 ;=====================================================================
 common distances,Rem,Re,Res,Rms,ph,fL
 common imshere,lonim,latim,inangleim,outangleim,obsangleim,fboverfaim,brdfim
 common albedomap,albedomap,maplon,maplat,albedoonsphere
 common discinfo,x0,y0,radius
 common pixels,iDS,jDS,iBS,jBS
 common tandg,t,hapkeG
     common visualization,ifviz
 ifviz=0	; if want plots etc -- needs access to X display
 hapkeG=0.6	; as per Wann Jensen
 t=0.1	; as per Wann Jensen
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
     if (exist1 ne '' and exist2 ne '') then begin
	imfile=exist1
	cubefile=exist2
     getClemmap,albedomap,maplon,maplat
     getimages,imfile,cubefile,im,cube,lonim,latim,inangleim,outangleim,obsangleim,exptime,jd,x0,y0,radius,phase,ephaseangle
     textstr='observed'
  ;  writefits,'DUMP/im_observed.fits',im
     ideal=reform(cube(*,*,4))
     cubeobs=reform(cube(*,*,0))
  ;  writefits,'DUMP/im_ideal.fits',ideal
     im=ideal     ; as a test
     textstr='ideal'
     getdistances,jd,Rem,Re,Res,Rms
     getalbedopixelforpixel,im,phase,pstar,ephaseangle
     ; plot
     !P.MULTI=[0,1,2]
     imtoshow=pstar
     imtoshow(*,y0)=max(pstar)*2
    
     idx=where(pstar gt 0)
     if (ifviz eq 1) then begin
     contour,/isotropic,hist_equal(imtoshow),/cell_fill,nlevels=91,min=0.00001
     plot,pstar(*,y0),/ylog,yrange=[0.01,1.0]
	kdx=where(pstar gt 0)
     oplot,[!X.crange],[median(pstar(kdx)),median(pstar(kdx))],color=fsc_color('red')
     endif
     
     ; save
     writefits,'DUMP/pstar_'+jdstr+'_'+textstr+'_.fits',pstar
  ;  writefits,'DUMP/albedoonsphere_'+jdstr+'.fits',albedoonsphere
     idx=where(pstar gt 0)
     if (idx(0) ne -1) then begin
	godosomeMC,pstar(idx),medval,SDmedval
	printf,11,format='(f15.7,5(1x,f12.7))',jd,phase,medval,SDmedval,ph,fL
	endif
	endif
     endwhile
 close,55
 close,11
 close,44
 end
