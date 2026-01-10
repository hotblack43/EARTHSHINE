PRO MOONPHASE,jd,az_moon,phase_angle_M,alt_moon,alt_sun,obsname
;-----------------------------------------------------------------------
; Set various constants.
;-----------------------------------------------------------------------
RADEG  = 180.0/!PI
DRADEG = 180.0D/!DPI
AU = 149.6d+6       ; mean Sun-Earth distance     [km]
Rearth = 6365.0D    ; Earth radius                [km]
Rmoon = 1737.4D     ; Moon radius                 [km]
Dse = AU            ; default Sun-Earth distance  [km]
Dem = 384400.0D     ; default Earth-Moon distance [km]
MOONPOS, jd, ra_moon, DECmoon, dis
distance=dis/6371.
eq2hor, ra_moon, DECmoon, jd, alt_moon, az_moon, ha_moon,  OBSNAME=obsname
SUNPOS, jd, ra_sun, DECsun
eq2hor, ra_sun, DECsun, jd, alt_sun, az, ha, OBSNAME=obsname
RAdiff = ra_moon - ra_sun
sign = +1
if (RAdiff GT 180.0) OR (RAdiff LT 0.0 AND RAdiff GT -180.0) then sign = -1
phase_angle_E = sign*acos( sin(DECsun/DRADEG)*sin(DECmoon/DRADEG) + cos(DECsun/DRADEG)*cos(DECmoon/DRADEG)*cos(RAdiff/DRADEG) ) * DRADEG
phase_angle_M = -atan( Dse*sin(phase_angle_E/DRADEG), Dem - Dse*cos(phase_angle_E/DRADEG) ) * DRADEG
return
end

PRO parsethem,str,filtername,JD_str,alfa
bits=strsplit(str,' ',/extract)
print,bits
nbits=n_elements(bits)
if (bits(nbits-1) ne filtername) then stop
JD_str=bits(0)
alfa=float(bits(1))
return
end

PRO get_airmass,jd,am
 ;
 ; Calculates the airmass of the observed Moon as seen from MLO
 ;
 ; INPUT:
 ;   jd  -   julian day
 ; OUTPUT:
 ;   am  -   the required airmass
 ;
 obsname='mlo'
 observatory,obsname,obs_struct
 lat=obs_struct.latitude
 lon=obs_struct.longitude
 MOONPOS,jd,ra,dec
 eq2hor,ra,dec,jd,alt,az,lon=lon,lat=lat
 ra=degrad(ra)
 dec=degrad(dec)
 lat=degrad(lat)
 lon=degrad(lon)
 am = airmass(jd,ra,dec,lat,lon)
 am = am(0)
 return
 end
 
 PRO getJDfromheader,l,header,JD
 idx=where(strpos(header,'DATE') ne -1)
 line=header(idx)
 line=strmid(line,11,strlen(line)-1)
 line=strmid(line,0,19)
 yyyy=fix(strmid(line,0,4))
 mm=strmid(line,5,2)
 dd=strmid(line,8,2)
 hh=strmid(line,11,2)
 mi=strmid(line,14,2)
 ss=strmid(line,17,2)
 JD=double(julday(mm,dd,yyyy,hh,mi,ss))
 if (l(0) eq 3) then JD=replicate(jd,l(3))
 return
 end
 
 
 PRO goget_B_and_V_calibrated,Bim,Vim,Bam,Vam,kB,kV,B,V,BminusV
 ; find the goodpixels in all images
 idx=where(Vim gt 0 and Bim gt 0)
 ; find the bad pixels in any image
 jdx=where(Vim le 0 or Bim le 0)
 Vinst=dblarr(512,512)+!VALUES.F_NaN
 Vinst(idx) = -2.5*alog10(Vim(idx)) - Vam*kV ; kV=0.1
 ;.
 Binst=dblarr(512,512)+!VALUES.F_NaN
 Binst(idx) = -2.5*alog10(Bim(idx)) - Bam*kB ; kB=0.15
 ;.
 BminusV=Vinst*0.0+0.92d0 ; BminusV is an IMAGE
 for iter=0,10,1 do begin
     V = Vinst + 15.07d0 - 0.05d0*(BminusV)
     B = Binst + 14.75d0 + 0.21d0*(BminusV)
     BminusV(idx)=B(idx)-V(idx)
     print,iter,mean(BminusV(idx),/NaN),mean(B,/NaN),mean(V,/NaN)
     endfor
 ; flag all pixels that are not universally 'good'
 V(jdx) = !VALUES.F_NaN
 B(jdx) = !VALUES.F_NaN
 BminusV(jdx) = !VALUES.F_NaN
 return
 end
 
 PRO get_EXPOSURE,h,exptime
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 return
 end
 
 PRO getcoordsfromheader,header,x0,y0,radius
 idx=strpos(header,'DISCX0')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'DISCX0 not in header. Assigning dummy value'
     x0=256.
     endif else begin
     x0=float(strmid(header(jdx),15,9))
     endelse
 idx=strpos(header,'DISCY0')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'DISCY0 not in header. Assigning dummy value'
     y0=256.
     endif else begin
     y0=float(strmid(header(jdx),15,9))
     endelse
 idx=strpos(header,'RADIUS')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'RADIUS not in header. Assigning dummy value'
     radius=134.327880000
     endif else begin
     radius=float(strmid(header(jdx),15,9))
     endelse
 x0=x0[0]
 y0=y0[0]
 radius=radius[0]
 return
 end
 
;=====================================================
; This code works on observed oairs of B and V images
; Version 1.
;=====================================================
openr,55,'goodBandVimagestouse.txt'
while not eof(55) do begin
str1=''
str2=''
readf,55,str1 
readf,55,str2 
if (str1 eq 'stop' or str2 eq 'stop') then stop
parsethem,str1,'B',B_JD_str,alfaB
parsethem,str2,'V',V_JD_str,alfaV
obsname='mlo'
 openw,4,'slopes.dat'
 openw,47,'BminusVishorisontalonDS.dat',/append
 lowpath='/data/pth/DARKCURRENTREDUCED/SELECTED_2/'
 lowpath='/media/SAMSUNG/EARTHSHINE/DARKCURRENTREDUCED/SELECTED_1/'
 ; get the B image
 Bfile=strcompress(lowpath+B_JD_str+'MOON_B_AIR_DCR.fits',/remove_all)
 B=double(readfits(Bfile,Bheader,/silent))
 ; get the V imag
 Vfile=strcompress(lowpath+V_JD_str+'MOON_V_AIR_DCR.fits',/remove_all)
 V=double(readfits(Vfile,Vheader,/silent))
MOONPHASE,double(B_jd_str),az_moon,phase_angle_M,alt_moon,alt_sun,obsname
 ; get airmasses
 l=size(B,/dimensions)
 getJDfromheader,l,Bheader,B_JD
 B_JD=B_JD(0)
 get_airmass,B_JD,Bam
 getJDfromheader,l,Vheader,V_JD
 V_JD=V_JD(0)
 get_airmass,V_JD,Vam
 print,'Airmasses: B,V: ',Bam,Vam
 ; center one at the other
 ; get x0,y0 
 getcoordsfromheader,Bheader,Bx0,By0,Bradius
 getcoordsfromheader,Vheader,Vx0,Vy0,Vradius
 ; get exposure times
 get_EXPOSURE,Bheader,Bexptime & print,'B exposure time: ',Bexptime
 get_EXPOSURE,Vheader,Vexptime & print,'V exposure time: ',Vexptime
 ; generate fluxes
 V=V/Vexptime[0]
 B=B/Bexptime[0]
 ; shift B to V
 B=shift_sub(B,Vx0-Bx0,Vy0-By0)
 ;
 sxaddpar, Bheader, 'DISCX0', Vx0, 'Disc center x coordinate'
 sxaddpar, Bheader, 'DISCY0', Vy0, 'Disc center y coordinate'
 ; set up the file to hold and the one to fold ...
 if (alfaB gt alfaV) then begin
     print,'B image sharper than V image - fold B'
     writefits,'imagetofold.fits',B
     flucbeforefolding=total(B,/double)
     writefits,'imagetohold.fits',V
     isBfolded=1
     isVfolded=0
     endif
 if (alfaV gt alfaB) then begin
     print,'V image sharper than B image - fold V'
     writefits,'imagetofold.fits',V
     flucbeforefolding=total(V,/double)
     writefits,'imagetohold.fits',B
     isBfolded=0
     isVfolded=1
     endif
 ;
 ; fold the sharper image and look at difference
 alfastart=1.6
 alfastop=2.25
 for alfa=alfastart,alfastop,0.04 do begin
     print,'Trying alfa: ',alfa
     ; convolve one image by the standard PSF raised to alfa
     str='./justconvolve imagetofold.fits out.fits '+string(alfa)
     spawn,str
     out=readfits('out.fits',/silent)
     ; give the folded image the same flux back as before
     totout=total(out,/double)
     out=out/totout*flucbeforefolding
     ; clean up the files
     spawn,'rm diff.fits'
     ; generate the diff image between the less sharp image and trial image generated
     str='/usr/local/astrometry/bin/imarith imagetohold.fits out.fits sub diff.fits'
     spawn,str
     diff=double(readfits('diff.fits',/silent))
     ; we have now two candidate  images one for B and one for V
     if (isBfolded eq 1) then begin
         Bcandidate=out
         Vcandidate=V
         endif else begin
         Bcandidate=B
         Vcandidate=out
         endelse
     ; now go and generate a B minus V (mags) iamge from these, and save it
     kB=0.15d0
     kV=0.10d0
     goget_B_and_V_calibrated,Bcandidate,Vcandidate,Bam,Vam,kB,kV,dummy1,dummy2,BminusV
     namefile=strcompress(string(alfa,format='(f4.2)')+'_BminusV.fits',/remove_all)
     writefits,namefile,BminusV
     ;
     !P.CHARSIZE=2
     !P.THICK=3
     !x.THICK=2
     !y.THICK=2
     w=9
     slice=avg(BminusV(*,By0-w:By0+w),1)
     plot,xtitle='Column #',ytitle='B-V',xstyle=3,yrange=[-1.5,2.0],slice,title=string((B_JD+V_JD)/2.0,format='(f15.7)')+' trial !7a!3 = '+string(alfa,format='(f4.2)')
     oplot,[Bx0-Bradius,Bx0-Bradius],[!Y.crange],linestyle=2
     oplot,[Bx0+Bradius,Bx0+Bradius],[!Y.crange],linestyle=2
     ; find the slope across the DS
     if (alfa eq alfastart) then begin
         print,'click on limits for DS'
         cursor,x1a,bdummy
         wait,0.2
         cursor,x2a,bdymmu
         wait,0.2
         endif
     print,'I have x1,x2: ',x1a,x2a
     xx=findgen(512)
     res=linfit(xx(x1a:x2a),slice(x1a:x2a),/double,sigma=sigs,yfit=yhat)
     oplot,[x1a,x1a],[!Y.crange],linestyle=1
     oplot,[x2a,x2a],[!Y.crange],linestyle=1
     oplot,xx(x1a:x2a),yhat,color=fsc_color('red')
     ; find the slope across the BS
     if (alfa eq alfastart) then begin
         print,'click on limits for DS'
         cursor,x1b,bdymmu
         wait,0.2
         cursor,x2b,bdymmu
         wait,0.2
         endif
     print,'I have x1,x2: ',x1b,x2b
     xx=findgen(512)
     res2=linfit(xx(x1b:x2b),slice(x1b:x2b),/double,sigma=sigs2,yfit=yhat2)
     oplot,[x1b,x1b],[!Y.crange],linestyle=1
     oplot,[x2b,x2b],[!Y.crange],linestyle=1
     oplot,xx(x1b:x2b),yhat2,color=fsc_color('red')
     fmt='(8(1x,f9.4))'
     print,format=fmt,alfa,res(1),sigs(1),res(1)/sigs(1),res2(1),sigs2(1),res2(1)/sigs2(1),mean(yhat2)-mean(yhat)
     printf,4,format=fmt,alfa,res(1),sigs(1),res(1)/sigs(1),res2(1),sigs2(1),res2(1)/sigs2(1),mean(yhat2)-mean(yhat)
     endfor
 ; print info on fluxes in a box
 w=5
idx=where(B eq max(B))
coords=array_indices(B,idx)
x0=coords(0)
y0=coords(1)
 print,'Mean flux in a Mare, B: ',mean(B(x0-w:x0+w,y0-w:y0+w))
 print,'Mean flux in a Mare, V: ',mean(V(x0-w:x0+w,y0-w:y0+w))
 close,4
 print,'Inspect slopes in file slopes.dat'
 ;
 data=get_data('slopes.dat')                                     
 alfas=reform(data(0,*))
 z1=reform(data(3,*))                                            
 isgood=0
 if (min(z1)*max(z1) lt 0) then isgood=1
 delta=reform(data(7,*))                                         
 plot,z1,delta,xtitle='Z',ytitle='!7D!3(B-V)!dBS-DS!n',charsize=2
 oplot,[-3,-3],[!Y.crange],linestyle=2
 oplot,[3,3],[!Y.crange],linestyle=2
 BmV_oneside=interpol(delta,z1,-3)
 BmV_intmiddle3=interpol(delta,z1,0)
 BmV_totherside=interpol(delta,z1,+3)
 upper3=BmV_oneside-BmV_intmiddle3
 lower3=BmV_intmiddle3-BmV_totherside
 BmV_oneside=interpol(delta,z1,-1)
 BmV_intmiddle1=interpol(delta,z1,0)
 BmV_totherside=interpol(delta,z1,+1)
 upper1=BmV_oneside-BmV_intmiddle1
 lower1=BmV_intmiddle1-BmV_totherside
 meanJD=(B_JD+V_JD)/2.0d0
 bestalfa=interpol(alfas,z1,0)
 fmt='(f15.7,1x,a,f5.2,a3,f5.2,a4,f5.2,a1)'
 fmt2='(f15.7,1x,f7.2,1x,f7.4,5(1x,f6.3),1x,i2)'
 print,format=fmt,meanJD,'B-V DS at +/- 3 sigma: ',BmV_intmiddle3,' (+',upper3,',- ',lower3,')'
 print,format=fmt,meanJD,'B-V DS at +/- 1 sigma: ',BmV_intmiddle1,' (+',upper1,',- ',lower1,')'
 printf,47,format=fmt2,meanJD,phase_angle_M,bestalfa,BmV_intmiddle3,upper3,lower3,upper1,lower1,isgood
 print,'Best alfa is: ',bestalfa
 close,47
 endwhile
 close,55
 end
