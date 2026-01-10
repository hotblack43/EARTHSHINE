FUNCTION SUNEARTHMOON_ANGLE,jd
; returns the angle (in DEGREES) between Moon-Earth-Sun - i.e. as seen from Earth
; code taken from a VB script at http://www.paulsadowski.com/WSH/moonphase.htm
;     ' Calculate illumination (synodic) phase
V=(jd-2451550.1)/29.530588853
V=V-fix(V)
if (V lt 0) then  V=V+1
V=V*360.

return,V
end


mm=5            ; Observing month
dd=31           ; Observing day of that month
yy=2004         ; Observing year
hh=21           ; Observing hour UT
;
min=0         ; Observing minute past that hour
sec=0.0     ; Observing second past that minute

jdstart=double(julday(mm,dd,yy,hh,min,sec))      ; the Julian day - watch out for rounding problems beyond 1/10'th day
jdstep=1.
fmt='(f10.2,1x,i2,1x,i2,1x,i4,2(1x,f9.4))'
for JD=jdstart,jdstart+60,jdstep do begin
    mphase,jd,k
    caldat,jd,mm,dd,yy
    phase=SUNEARTHMOON_ANGLE(jd)

    print,format=fmt,jd,mm,dd,yy,phase,k
endfor
end