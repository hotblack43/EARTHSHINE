!P.CHARSIZE=2
file='goodlist.JDs'
close,1
openr,1,file
plot,title='Distance MLO - Sunglint',xtitle='Degrees longitude',ytitle='Illuminated fraction',xstyle=3,ystyle=3,/nodata,randomu(seed,100),$
xrange=[0,180],yrange=[0,1]
lon=-155.5763
while not eof(1) do begin
jd=0.0d0
readf,1,jd
; get the illuminated fraction
mphase,jd,k
get_sunglintpos,jd,glon,glat,az_moon,alt_moon,moonlat,moonlong
if (glon gt 180) then glon=glon-360
plots,abs(glon-lon) mod 180,k,psym=1
;
;find lunar altitude from MLO and from sunglint
MOONPOS, jd, ra, dec
eq2hor, ra, dec, jd, alt_MLO, az, obsname='mlo';  LAT=19.5362 , LON=-155.5763 
eq2hor, ra, dec, jd, alt_GLINT, az, LAT=glat , LON=glon
print,jd,glon,abs(glon-lon) mod 180,alt_MLO,alt_GLINT,180-[abs(lon-glon) mod 180]-alt_MLO-alt_GLINT
endwhile
close,1
end
