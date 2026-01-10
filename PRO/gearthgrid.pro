; USAGE: gearthgrid,lon,lat,outfile='myfilename.kml'  
; came from: /home/obc/google_earth/gearthgrid.pro
; lon and lat are 1 or 2 dimensional arrays of longitude and latitude
;---------------------------------------------------------
PRO gearthgrid,x,y,outfile=outfile

IF n_elements(outfile) EQ 0 THEN outfile='/home/obc/temp/gearthgrid.kml'


s=size(x)
nlon = s(1)
nlat = s(2)
IF s(0) EQ 1 THEN BEGIN
  nlat = s(1)
  nlon = 1
  x=reform(/over,x,nlon,nlat)
  y=reform(/over,y,nlon,nlat)
ENDIF ELSE IF s(0) NE 2 THEN BEGIN
  nlon=1
  nlat=1
ENDIF

openw,uwrite,/get_lun,outfile
openr,ughead,/get_lun,'/home/obc/google_earth/globalhead.txt'
openr,ugtail,/get_lun,'/home/obc/google_earth/globaltail.txt'
openr,uhead,/get_lun,'/home/obc/google_earth/head.txt'
openr,utail,/get_lun,'/home/obc/google_earth/tail.txt'

ss=strarr(1)
WHILE EOF(ughead) EQ 0 DO BEGIN
  readf,ughead,ss
  printf,uwrite,ss
ENDWHILE
close,ughead

shead = strarr(5)
ihead=0
WHILE EOF(uhead) EQ 0 DO BEGIN
  readf,uhead,ss
  shead(ihead) = ss
  ihead = ihead + 1
ENDWHILE
close,uhead

stail = strarr(10)
itail=0
WHILE EOF(utail) EQ 0 DO BEGIN
  readf,utail,ss
  stail(itail) = ss
  itail = itail + 1
ENDWHILE
close,utail

FOR j=0,nlat-1 DO FOR i=0,nlon-1 DO BEGIN
  FOR ii=0,ihead-1 DO printf,uwrite,shead(ii)
;  printf,uwrite,'        Point ',i,j
;  printf,uwrite,'<BR/>   Long. ',x(i,j)
  printf,uwrite,'        Long. ',x(i,j)
  printf,uwrite,'<BR/>   Lat.  ',y(i,j)
  printf,uwrite,'<BR/>   </description>'
  printf,uwrite,'  <Point> <altitudeMode>clampToGround</altitudeMode>'

  printf,uwrite,'  <coordinates>',x(i,j),', ',y(i,j),',0</coordinates> '
  printf,uwrite,' </Point> '
  IF s(0) EQ 2 THEN $
    printf,uwrite,' <name>    Point ',i,',',j,' </name>',format='(A,I4,A,I4,A)' $
  ELSE $
    printf,uwrite,' <name>    Point ',j,' </name>',format='(A,I4,A)'
  FOR ii=0,itail-1 DO printf,uwrite,stail(ii)
ENDFOR

WHILE EOF(ugtail) EQ 0 DO BEGIN
  readf,ugtail,ss
  printf,uwrite,ss
ENDWHILE
close,ugtail

close,uwrite
free_lun,uwrite,ughead,uhead,ugtail,utail
IF s(0) EQ 1 THEN BEGIN
  x=reform(/over,x,nlat)
  y=reform(/over,y,nlat)
ENDIF
END
