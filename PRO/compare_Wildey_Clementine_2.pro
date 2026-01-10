; Getthe Clementine map
Clem=readfits('Clementine_albedo.fits')
lonClem=findgen(1080)*360./1080.
lonClem=reverse(lonClem)
latClem=findgen(540)*180./540.-90.
; write out as 3-.column table
openw,1,'Clem.txt'
for i=0,1080-1,1 do begin
for j=0,540-1,1 do begin
if (Clem(i,j) gt 0) then printf,1,Clem(i,j),lonClem(i),latClem(j)
endfor
endfor
close,1
;
; get the Wildey map
lonWIldey=readfits('LUNARALBEDO/wildey_longitudes.fit')
latWIldey=readfits('LUNARALBEDO/wildey_latitudes.fit')
WIldeyAlb=readfits('LUNARALBEDO/wildey_normal_albedo_DMI_version_1.fit')
; write out as 3-.column table
openw,2,'Wild.txt'
for i=0,569-1,1 do begin
for j=0,569-1,1 do begin
if (WIldeyAlb(i,j) gt 0) then printf,2,WIldeyAlb(i,j),lonWIldey(i,j),latWIldey(i,j)
endfor
endfor
close,2
end
