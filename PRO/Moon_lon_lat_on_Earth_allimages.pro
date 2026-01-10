

;-------------------------------
; Code to find all long,lat positions (on Earth) of Moon at zenith for all images we have
common time,jd
openr,2,'FORHANS/Chris_list_of_good_observations_after_tunelling.justJDs'
openw,33,'moongeopos.dat'
while not eof(2) do begin
str=''
readf,2,str
jd=double(str)
        get_lon_lat_for_moon_at_zenith,longitude,latitude
print,format='(f15.7,2(1x,f9.3))',jd,longitude,latitude
printf,33,format='(f15.7,2(1x,f9.3))',jd,longitude,latitude
endwhile
close,33
close,2
end
