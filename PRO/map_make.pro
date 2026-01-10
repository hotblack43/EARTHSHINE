device,decomposed=0
map=fltarr(144,65)
for ilon=0,144-1,1 do begin
for ilat=0,65-1,1 do begin
map(ilon,ilat)=correlate(MEAN_TEMP_500_200(ilon,ilat,*),THICKNESS_500_200(ilon,ilat,*))
endfor
endfor
map=bytscl(map)
contour,map,levels=indgen(100)*0.001+0.9,/cell_fill
contour,map,levels=indgen(100)*0.001+0.9,/overplot
end

