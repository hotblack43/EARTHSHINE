PRO gofindBScat_matches,ra_deg,dec_deg,U,B,V,minDISTyale
; INPUT
; ra_deg,dec_deg : RA,DEC of star wanted UBV for
; UBV	: UBV for the star found by comparing positions to precessed Yale cat
; minDISTyale	:	smallest distance found between RA,DEC and anys tar in Yale
;-------------------------------------------------
 file='~/ASTRO/EXTINCTION/bscatalogue_UBV.dat'
 data=get_data(file)
 l=size(data,/dimensions)
 nrows=l(1)
 ra_deg_yale=data(9,*)
 dec_deg_yale=data(10,*)
;.............................
 ; Precess the epoch 1900 coordinates from Yale to something like what we have (near 2000)
; Yale has decimal hours for RA, so multiply it by 15 to get degrees
 ra=ra_deg_yale*15.0
 dec=dec_deg_yale
 precess,ra,dec,1900,2000
 ra_deg_yale=ra
 dec_deg_yale=dec
;.............................
 d=reform(sqrt(((ra_deg_yale-ra_deg))^2+(dec_deg_yale-dec_deg)^2))
 idx=where(d eq min(d))
 minDISTyale=min(d)
; print,'Minimum distance in degrees: ',minDISTyale
 U=reform(data(6,idx(0)))
 B=reform(data(7,idx(0)))
 V=reform(data(8,idx(0)))
 return
 end
 
 ;-------------------------------------------------------
 ; Code to match stars found via sextractor to stars in teh BScat.
 ;
 magerrlim=0.05
 openw,88,'UBV_vs_RGB.dat'
;==============================
 openr,1,'R_4.cat'
 openw,2,'outR.dat'
 str=''
 for i=1,10 do readf,1,str
 while not eof(1) do begin
     readf,1,str
     printf,2,str
     endwhile
 close,1
 close,2
 dataR=get_data('outR.dat')
 idx=where(dataR(9,*) eq 0 and dataR(2,*) lt magerrlim)
 dataR=dataR(*,idx)
 lR=size(dataR,/dimensions)
 plot,xstyle=3,ystyle=3,/nodata,reform(dataR(7,*)),reform(dataR(8,*)),psym=7
 oplot,reform(dataR(7,*)),reform(dataR(8,*)),psym=7,color=fsc_color('red')
;==============================
 openr,1,'G_4.cat'
 openw,2,'outG.dat'
 str=''
 for i=1,10 do readf,1,str
 while not eof(1) do begin
     readf,1,str
     printf,2,str
     endwhile
 close,1
 close,2
 dataG=get_data('outG.dat')
 idx=where(dataG(9,*) eq 0 and dataG(2,*) lt magerrlim)
 dataG=dataG(*,idx)
 lG=size(dataG,/dimensions)
 oplot,reform(dataG(7,*)),reform(dataG(8,*)),psym=7,color=fsc_color('green')
;==============================
 openr,1,'B_4.cat'
 openw,2,'outB.dat'
 str=''
 for i=1,10 do readf,1,str
 while not eof(1) do begin
     readf,1,str
     printf,2,str
     endwhile
 close,1
 close,2
 dataB=get_data('outB.dat')
 idx=where(dataB(9,*) eq 0 and dataB(2,*) lt magerrlim)
 dataB=dataB(*,idx)
 lB=size(dataB,/dimensions)
 oplot,reform(dataB(7,*)),reform(dataB(8,*)),psym=7,color=fsc_color('blue')
;==============================
 ; find matching stars
 limdist=1.5/60.	; arc minutes per pixel
 print,'Limiting distance: ',limdist,' degrees.'
 fmt='(i3,1(1x,f9.4),3(1x,f6.2),1x,a,1x,a)'
 fmt2='(i3,6(1x,f7.2))'
 fmt3='(f9.5,6(1x,f7.2))'
 print,'  i    d_err     R      G      B   RA         DEC'
 for i=0,lR(1)-1,1 do begin
     ra=dataR(7,i)
     dec=dataR(8,i)
     rastr, ra, 1, RAstr, carry,/degrees
     decstr, dec, 1, DECstr,/degrees
; NOte RA,DEC are in J2000
     d_RG=sqrt((ra-dataG(7,*))^2+(dec-dataG(8,*))^2)
     d_RB=sqrt((ra-dataB(7,*))^2+(dec-dataB(8,*))^2)
     idx=where(d_RG eq min(d_RG))
     jdx=where(d_RB eq min(d_RB))
     if (d_RG(idx(0)) lt limdist and d_RB(jdx(0)) lt limdist) then begin
         print,format=fmt,i,sqrt(d_RG(idx(0))^2+d_RB(jdx(0))^2),dataR(1,i),dataG(1,idx(0)),dataB(1,jdx(0)),RAstr,DECstr
         ;precess, dataR(7,i),dataR(8,i),2013,2010, /PRINT
         gofindBScat_matches,ra,dec,U,B,V,minDISTyale
         m=n_elements(U)
         for k=0,m-1,1 do begin
             print,format=fmt3,minDISTyale,U(k),B(k),V(K),dataR(1,i),dataG(1,idx(0)),dataB(1,jdx(0))
             printf,88,format=fmt2,k,U(k),B(k),V(K),dataR(1,i),dataG(1,idx(0)),dataB(1,jdx(0))
             print,'-----------------------------------------------------------'
             endfor
         endif
     endfor
 close,88
 end
