PRO gotonearMoon
; will move telescope near to Moon
filename='C:\MOON\dummy.file'
sub_find_moon_coordinates,filename,jd,ra,dec,hh,mm,ss,ideg,min,sec,alt,az
decl_sign=+1
if (ideg lt 0.0 or min lt 0 or sec lt 0) then decl_sign=-1
path='C:\MOON\'
create_Command_for_VB,path,hh,mm,ss,ideg,min,sec,decl_sign
spawn,'C:\MOON\Move_Telescope.exe'
writeLOGmessage,'movetelescope: Used Move_Telescope.exe! Now pausing to let telescope catch up'
Wait,5
return
end

PRO FLIP,array
; will put last row first, first row last etc in array
array=REVERSE(array,2)
return
end

PRO get_telescope_pointing,point_RA_orig,point_Decl_orig
COMMON seed,seed
; routine to measure telescopes pointing RA and Decl, in decimal degrees
;
;================================
openr,point,'c:\MOON\pointingRA.dat',/get_lun
RAstring=''
readf,point,RAstring
close,point
free_lun,point
openr,point,'c:\MOON\pointingDecl.dat',/get_lun
Declstring=''
readf,point,Declstring
close,point
free_lun,point
;
HH=fix(strmid(rastring,0,2))
MM=fix(strmid(rastring,3,2))
SS=fix(strmid(rastring,6,2))

point_RA_orig=ten(HH,MM,SS)/24.*360.
;   print,rastring,hh,mm,ss,point_RA_orig
;
deg=fix(strmid(Declstring,0,3))
min=fix(strmid(Declstring,4,2))
sec=fix(strmid(Declstring,7,2))

point_Decl_orig=ten(deg,min,sec)
;   print,Declstring,deg,min,sec,point_Decl_orig
writeLOGmessage,strcompress('get_telescope_pointing: Determined that telescope pointing is '+string(point_Decl_orig)+string(point_RA_orig))
return
end

PRO create_Command_for_VB,path,ihr,imin,xsec,ideg,imn,xsc,decl_sign
openw,lun5,path+'Command_for_VB.txt',/get_lun
str='#:Sr'
create_strings,ihr,imin,xsec,ideg,imn,xsc,ihr_str,imin_str,xsec_str,ideg_str,imn_str,xsc_str,decl_sign
strSr=str+ihr_str+':'+imin_str+':'+xsec_str+'#'
str='#:Sd'
strSd=str+ideg_str+':'+imn_str+':'+xsc_str+'#'
strMS='#:MS#'
printf,lun5,strcompress(strSr+strSd+strMS,/remove_all)
close,lun5
free_lun,lun5
writeLOGmessage,'create_Command_for_VB: created a file in '+path
return
end

PRO get_xyRaDecldata,x,y,a,d
; reads from a file x,y, (pixels in CCD frame) and Ra Decl (decimal degrees)
; if iflag = 314 then a and d are to be returned in decimal degrees
file='C:\MOON\inputxyRaDecl.dat'
print,'Waiting 5 seconds to open file C:\MOON\inputxyRaDecl.dat'
wait,5
data=read_ascii(file)
x=reform(data.field1(0,*))
y=reform(data.field1(1,*))
a=reform(data.field1(2,*))
d=reform(data.field1(3,*))
return
end

PRO get_astrometric_solution,ihr, imin, xsec,ideg, imn, xsc
openw,lun4,'C:\MOON\LOGFILES\Lastoutputfromastrometricsolution.txt',/get_lun
get_xyRaDecldata,x,y,a,d        ;   read data back in
n=n_elements(x)
printf,lun4,'get_astrometric_solution: Data read in:'
for i=0,n-1,1 do begin
    printf,lun4,format='(a,4(1x,f9.3))','get_astrometric_solution: ',x(i),y(i),a(i),d(i)
endfor
;---
printf,lun4,'get_astrometric_solution:========================================================='
; set up ordinary least squares
xmatrix=dblarr(n,2)
xmatrix(*,0)=a(0:n-1)
xmatrix(*,1)=d(0:n-1)
xprimematrix=dblarr(n,3)
xprimematrix(*,0)=1.0d0
xprimematrix(*,1)=x(0:n-1)
xprimematrix(*,2)=y(0:n-1)
printf,lun4,'get_astrometric_solution:xmatrix:'
printf,lun4,format='(a,'+string(n)+'(1x,f8.2))','get_astrometric_solution:',xmatrix
printf,lun4,'xprimematrix:'
printf,lun4,format='('+string(n)+'(1x,f8.2))',xprimematrix
result=(xmatrix ## transpose(xprimematrix)) ## invert(xprimematrix ## transpose(xprimematrix),/double,status)
printf,lun4,'After inversion STATUS=',status,' where 0 is OK, 2 is a warning, 1 is singular matrix'
printf,lun4,'Solution:'
printf,lun4,format='(3(1x,g18.7))',result
printf,lun4,'LHS recreated:'
printf,lun4,format='('+string(n)+'(1x,f8.2))',result ## xprimematrix
;---
aa=365.0    ;   These are the center coordinates of the webcam - this pixel should be
dd=174.5    ;   center of science cam also.
printf,lun4,'The CCD coordinates to find sky coordinates for are given as:',aa,dd
xprime2matrix=dblarr(3)
xprime2matrix(0)=1.0d0
xprime2matrix(1)=aa
xprime2matrix(2)=dd
coords=result ## xprime2matrix
printf,lun4,format='(a,2(1x,f8.2),a)','Sky coordinates that correspond to X,Y are:',coords,' decimal degrees, or'
radec,coords(0),coords(1),ihr, imin, xsec,ideg, imn, xsc
printf,lun4,'     RA(hh,mm,ss):',ihr, imin, xsec
printf,lun4,'Decl(deg,min,sec):', ideg, imn, xsc
; Check for Good sense of values
if (ihr lt 0 or ihr gt 23 or ideg lt -90 or ideg gt 90) then begin
    writeLOGmessage,'get_astrometric_solution: SOmething is wrong with coordinates. Stopping'
    stop
endif
close,lun4
free_lun,lun4
return
end

PRO get_webcampic,filename
; routine to snap a picture with the attached webcam and save it by the name
; supplied
;   lun3 is the filenumber for the LOG activity
;========================================
; set up a batch file to execute in order to take picture and rename file
cwd=''
cd,'C:\MOON\'
cd,current=cwd
;   printf,lun3,'get_webcampic: Creating the execute.bat file'
writeLOGmessage,'get_webcampic: Creating the execute.bat file'
openw,lun,'execute.bat',/get_lun
printf,lun,'cd C:\MOON\'
printf,lun,'astrovideo /s get_webcam_picturet.txt'
printf,lun,'erase '+filename
printf,lun,'rename webcampicture_RENAMEME.bmp '+filename
printf,lun,'cd c:\MOON\'
;   printf,lun,'PAUSE'
close,lun
free_lun,lun
writeLOGmessage,'get_webcampic: Closing the execute.bat file'
writeLOGmessage,'get_webcampic: Executing execute.bat'
spawn,'execute.bat'
writeLOGmessage,'get_webcampic: Finished Executing execute.bat'
cwd=''
cd,current=cwd
return
end

PRO writeLOGmessage,message
;
openw,lun3,'C:\MOON\LOGFILES\Lastoutputfrom_Master_find_moon.txt',/get_lun,/append
printf,lun3,strcompress(message)
close,lun3
free_lun,lun3
return
end

PRO movetelescope,point_RA_orig,point_Decl_orig,npix,ipix
; routine to move telescope in a circle around the original position
; taking npix steps to do a full circle, one step for each call
;=============================
;
delta_angle=360./float(npix)*float(ipix)
radius = 1.0
new_x = point_RA_orig + radius*cos( delta_angle / 360. *2.*!pi)
new_y = point_Decl_orig + radius*sin( delta_angle / 360. *2.*!pi)
; Generate a command file for VB
radec,new_x,new_y,ihr, imin, xsec,ideg, imn, xsc
; Check for Good sense of values
if (ihr lt 0 or ihr gt 23 or ideg lt -90 or ideg gt 90) then begin
    writeLOGmessage,'movetelescope: Something is wrong with coordinates. Stopping'
    stop
endif
; Write a suitable command file for VB to act on
path='C:\MOON\'
decl_sign=+1
if (new_y lt 0.0) then decl_sign=-1
create_Command_for_VB,path,ihr,imin,xsec,ideg,imn,xsc,decl_sign
;   if (ipix ne 0) then stop
spawn,'C:\MOON\Move_Telescope.exe'
writeLOGmessage,'movetelescope: Used Move_Telescope.exe!'
return
end




;===========================================================
; Program to center telescope on Moon
;===========================================================
;
COMMON seed,seed
; Erase the old LOG file
spawn,'ERASE C:\MOON\LOGFILES\Lastoutputfrom_Master_find_moon.txt'
writeLOGmessage,'Master_find_moon: Started by erasing old log file.'+string(systime())
spawn,'cleanup.bat'
writeLOGmessage,'Master_find_moon: Erased all old .fit files in ...\ASTRO\ '+string(systime())
read,ifstart,prompt='Is Telescope_Position.exe running (1 = Yes)'
if (ifstart ne 1) then stop
;===========================================================
;   use subroutine to fetch current coordinates of Moon
;   also store reults in a file named by filename
;
path='C:\MOON\'
filename=path+'Moon_ccordinates.txt'
sub_find_moon_coordinates,filename,jd,ra,dec,hh,mm,ss,ideg,min,sec,alt,az
;   Movethe telescope to hopefully near the Moon
gotonearMoon
print,'Waiting 24 seconds to find Moon...'
wait,24

;===========================================================
;   Take webcam pictures of Moon, readtelescope coordinates, move
;   telescope and repeat - a number of times
;
openw,lun,path+'webcampix_and_coords.txt',/get_lun
npix=6
get_telescope_pointing,point_RA_orig,point_Decl_orig
for ipix=0,npix-1,1 do begin
    filename=path+strcompress('pix'+string(ipix+1)+'.bmp',/remove_all)
    print,'Waiting 15 seconds....'
    wait,15
    get_webcampic,strcompress('pix'+string(ipix+1)+'.bmp',/remove_all)
    get_telescope_pointing,point_RA,point_Decl
    nowtime=systime(/julian)
    printf,lun,format='(f20.10,1x,f10.6,1x,f10.6,1x,a)',nowtime,point_RA,point_Decl,filename
    writeLOGmessage,'Master_find_moon: Telescope pointing '+string(point_RA)+string(point_Decl)+' at time:'+string(systime())
    movetelescope,point_RA_orig,point_Decl_orig,npix,ipix
endfor
close,lun
free_lun,lun
;=============================================
; having taken npix pictures and storing their corresponding coordinates
; now find the Moon in each picture and get the coordinates of the centroid
; in CCD units
openr,lun,path+'webcampix_and_coords.txt',/get_lun
openw,lun2,'C:\MOON\inputxyRaDecl.dat',/get_lun

for ipix=0,npix-1,1 do begin
    readf,lun,format='(f20.10,1x,f10.6,1x,f10.6,1x,a)',nowtime,point_RA,point_Decl,filename
    ;print,format='(f20.10,1x,f10.6,1x,f10.6,1x,a)',nowtime,point_RA,point_Decl,filename
    im=read_bmp(filename)
    im=reform(im(0,*,*))        ;   grab one color of the picture
    b=[-3.d0,211.d0,71.d0,95.d0,369.d0,174.d0,0.d0]    ;   Initial guess for fit parameters
    FLIP,im
    res=PT_GAUSS2DFIT(im,b)
    ;   printf,lun3,'Master_find_moon: Moon found at:',b(4),b(5),' on CCD, and at:',point_RA,point_Decl,' on the sky.'
    writeLOGmessage,'Master_find_moon: Moon found at:'+string(b(4))+string(b(5))+' on CCD, and at:'+string(point_RA)+string(point_Decl)+' on the sky.'
    printf,lun2,format='(4(1x,f13.8))',b(4),b(5),point_RA,point_Decl
    ;   printf,lun3,'Master_find_moon:',b(4),b(5),point_RA,point_Decl
    writeLOGmessage,'Master_find_moon:'+string(b(4))+string(b(5))+string(point_RA)+string(point_Decl)
    ;   help,b(4),b(5),point_RA,point_Decl
endfor
close,lun
free_lun,lun
close,lun2
free_lun,lun2
;=====================================================
; Now solve for astrometric plate solution
;
get_astrometric_solution,ihr, imin, xsec,ideg, imn, xsc
; Check for sensible solution
if (ihr lt 0 or ihr gt 23 or ideg lt 0 or ideg gt 350) then begin
    ;   printf,lun3,format='(a,6(1x,f10.1))','Master_find_moon: The astrometric solution does not make sense:',ihr, imin, xsec,ideg, imn, xsc
    writeLOGmessage,'Master_find_moon: The astrometric solution does not make sense:'+string(ihr)+string(imin)+string(xsec)+string(ideg)+string(imn)+string(xsc)
    ;   printf,lun3,'Master_find_moon: Must stop'
    writeLOGmessage,'Master_find_moon: Must stop'
stop
endif
decl_sign=+1
if (ideg lt 0.0 or imn lt 0 or xsc lt 0) then decl_sign=-1
create_Command_for_VB,path,ihr,imin,xsec,ideg,imn,xsc,decl_sign
wait,3
spawn,'C:\MOON\Move_Telescope.exe'
writeLOGmessage,'Master_find_moon: Used Move_Telescope.exe - hopefully Moon is now centered in CCDcam.'
;   printf,lun3,'All done!'
writeLOGmessage,'All done!'
;   close,lun3
;   free_lun,lun3
print,'All done!'
end