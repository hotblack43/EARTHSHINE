PRO get_airmass,jd,am
;
; Calculates the airmass of the observed Moon as seen from MLO
;
; INPUT:
;   jd  -   julian day
; OUTPUT:
;   am  -   the required airmass
;
    lat=19.5d0
    lon=-115.12d0
    MOONPOS,jd,ra,dec
    eq2hor,ra,dec,jd,alt,az,lon=lon,lat=lat
    ra=degrad(ra)
    dec=degrad(dec)
    lat=degrad(lat)
    lon=degrad(lon)
    am = airmass(jd,ra,dec,lat,lon)
    return
end
