 PRO getJDfromheader,header,JD
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
 return
 end

PRO getphasefromJD,JD,phase
 MOONPHASE,jd(0),phase_angle_M,alt_moon,alt_sun,obsname
 phase=phase_angle_M
 return
 end
 
 PRO extractphotometry,stack,exposure,howmany,surfmags,SD_surfmags,flags
; extract surface brightness from an image
; returns this for a reference area and one other area
 if (howmany gt 2) then begin
     print,'Stopping: too many areas'
     stop
     endif
;..............................
 im=reform(stack(*,*,0))
 imtoshow=im
 lon=reform(stack(*,*,5))
 lat=reform(stack(*,*,6))
 SA=reform(stack(*,*,7))
;..............................
 ; area 1 - the reference
 w=3
 lon0=-65
 lat0=19
 idx=where(lon gt lon0-w and lon lt lon0+w and lat gt lat0-w and lat lt lat0+w)
 imtoshow(idx)=max(imtoshow)
 ; area 2 - the other one
 w=3
 lon0=-20
 lat0=29
 jdx=where(lon gt lon0-w and lon lt lon0+w and lat gt lat0-w and lat lt lat0+w)
 imtoshow(jdx)=max(imtoshow)
 ; test if area is in sunshine or earthshine
 flag1=0
 if (max(SA(idx)) lt !PI/2.) then flag1=1
 if (min(SA(idx)) gt !PI/2.) then flag1=2
 ; test if area is in sunshine or earthshine
 flag2=0
 if (max(SA(jdx)) lt !pi/2.) then flag2=1
 if (min(SA(jdx)) gt !pi/2.) then flag2=2
 tvscl,hist_equal(imtoshow)
 ; extract
 flux=im/exposure
 areaflux=total(im(idx),/double)
 N=n_elements(idx)
 areamags_ref=-2.5*alog10(areaflux/N/6.67/6.67); mags per sq. asec
 ;
 areaflux=total(im(jdx),/double)
 N=n_elements(jdx)
 areamags_2=-2.5*alog10(areaflux/N/6.67/6.67); mags per sq. asec
 ; collate
 surfmags=[areamags_ref,areamags_2]
 flags=[flag1,flag2]
 return
 end
 
 PRO getexposure,h,exptime
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 return
 end
 
 
 openw,55,'List_of_BmV_.dat'
 file='list_of_JDandFILTER_both_B_and_V.txt'
 openr,1,file
 while not eof(1) do begin
     str=''
     readf,1,str
     bits=strsplit(str,' ',/extract)
     JD=double(bits(0))
     Bfiles=file_search('/media/thejll/OLDHD/CUBES/cube_*'+bits(0)+'*_B_*',count=nB)
     Vfiles=file_search('/media/thejll/OLDHD/CUBES/cube_*'+bits(0)+'*_V_*',count=nV)
     for iB=0,nB-1,1 do begin
         Bstack=readfits(Bfiles(iB),Bheader,/silent)
         getexposure,Bheader,Bexposure
	 getJDfromheader,Bheader,BJD
         for iV=0,nV-1,1 do begin
             Vstack=readfits(Vfiles(iV),Vheader,/silent)
             getexposure,Vheader,Vexposure
	     getJDfromheader,Vheader,VJD
             jd=(VJD+BJD)/2.
             howmany=2	; number of regions to extract from
             extractphotometry,Bstack,Bexposure,howmany,Bsurfmags,SD_Bsurfmags,flagsB
             extractphotometry,Vstack,Vexposure,howmany,Vsurfmags,SD_Vsurfmags,flagsV
             BmV_ref=Bsurfmags(0)-Vsurfmags(0)
             BmV=Bsurfmags(1)-Vsurfmags(1)
             getphasefromJD,JD,phase
             print,format='(f15.7,1x,f8.2,2(1x,i2),1x,f9.3)',JD,phase,flagsB(0),flagsB(1),BmV-BmV_ref
             printf,55,format='(f15.7,1x,f8.2,2(1x,i2),1x,f9.3)',JD,phase,flagsB(0),flagsB(1),BmV-BmV_ref
             ;a=get_kbrd()
             endfor
         endfor
     endwhile
 close,1
 close,55
 end
