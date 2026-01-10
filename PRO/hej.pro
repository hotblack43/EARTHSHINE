; This is an IDL procedure created by running the IDL program wcs_demo.pro
; and can be executed from the IDL prompt by typing .run hej.pro.
; This procedure may be far more complicated than what you need.  In order
; to make it more user-friendly, I have broken up the tasks performed into
; the following categories:
;   (1) SET-UP -- sections declaring constants
;   (2) CONVERSION -- section in which spherical to xy conversion is done
;   (3) LABELS -- sections setting up and printing labels on the maps
;   (4) PLOTTING -- sections in which data or lines are plotted
;To find the appropriate section, simply search for one of these four
;capitalized words.

pro hej
;SET-UP
; Set-up constants used later in this procedure
map =        5
min_lon = 0
max_lon = 345
lon_spacing = 15
min_lat = -90
max_lat = 90
lat_spacing = 15

; Based on the ranges for latitude and longitude, as well as their spacing,
; generate the latitude and longitude arrays.
num_lon = long((max_lon - min_lon)/lon_spacing) + 1
lon = dindgen(num_lon)*lon_spacing + min_lon
num_lat = long((max_lat - min_lat)/lat_spacing) + 1
lat = dindgen(num_lat)*lat_spacing + min_lat
longitude = dblarr(num_lon,num_lat)
for i = 0,num_lat - 1 do longitude[*,i] = lon
latitude = dblarr(num_lon,num_lat)
for i = 0,num_lon - 1 do latitude[i,*] = lat

;CONVERSION
; Convert the spherical coordinates into x-y coordinates by using wcssph2xy.
wcssph2xy,longitude,latitude,x,y,map

;PLOTTING
; all maps have x increasing to the left, so switch this
xx = -x

;LABELS
; The arrays lon_index and lat_index contain the indices for the latitude
; and longitude labels.  Labels occur every 30 degrees unless 30 doesn't
; divide into any of the latitude and longitude values evenly.  In this case,
; all latitude and longitude lines are labeled.
lon_index = where(long(longitude[*,0])/30 eq longitude[*,0]/30.)
lat_index = where(long(latitude[0,*])/30 eq latitude[0,*]/30.)
if (lat_index[0] eq -1) then lat_index = indgen(n_elements(latitude[0,*]))
if (lon_index[0] eq -1) then lon_index = indgen(n_elements(longitude[*,0]))

;PLOTTING
; Plot the resulting map.
xdelta = (max(xx) - min(xx))/20
ydelta = (max(y) - min(y))/20
plot,xx,y,psym = 3,xrange = [min(xx) - xdelta,max(xx) + xdelta],$
yrange = [min(y) - ydelta,max(y) + ydelta],xstyle = 4,ystyle = 4

; Only connect latitude lines in a full circle if the longitude
; values cover the full circle.
if (360 - abs(longitude(0,0) - longitude(n_elements(xx[*,0])-1)) $
                             le lon_spacing) $
then for i = 0,num_lat - 1 do oplot,[xx[*,i],xx(0,i)],[y[*,i],y(0,i)] $
else for i = 0,num_lat - 1 do oplot,xx[*,i],y[*,i]

; Connect the longitude lines from the poles outward.
for i = 0,num_lon - 1 do oplot,xx[i,*],y[i,*]

;LABELS
; Label the latitude and longitude lines and correctly orient the labels.
j = 0
repeat begin
  i = lon_index(j)
  xyouts,xx(i,0)-xdelta*sin(longitude(i,0)/!radeg),$
         y(i,0)-ydelta*cos(longitude(i,0)/!radeg),$
         strcompress(string(long(longitude(i,0)))),alignment=0.5,$
         orientation=360-longitude(i,0)
  j = j + 1
endrep until (j eq n_elements(lon_index))
if (lat_index[0] ne -1) then $
  xyouts,xx(0,lat_index),y(0,lat_index),$
       strcompress(string(long(latitude(0,lat_index))))
end
