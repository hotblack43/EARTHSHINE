data=get_data('dome_pointing_table.noheader')
; headers were: tele_az tele_el dome_az
TAZ=reform(data(0,*))
TEL=reform(data(1,*))
dome_offset=345.-15.
DAZ=(reform(data(2,*))+dome_offset)
DAZ=DAZ mod 360
;

!P.MULTI=[0,1,2]
!P.CHARSIZE=2
!P.CHARTHICK=2
!P.THICK=2
!X.THICK=2
!Y.THICK=2
nlevels=41
levs=findgen(nlevels)/float(nlevels-1)*360.
levs=[levs,185]
levs=levs(sort(levs))
xlo=60
xhi=300
;c_ann=string(levs)
;polar_contour,c_annotation=c_ann,c_labels=findgen(100)*0+1,DAZ,TAZ,R,/irregular,/downhill,xtitle='Telescope Azimuth'
contour,DAZ,TAZ,TEL,/irregular,/downhill,xtitle='Telescope Azimuth',ytitle='Telescope alt.',title='Dome azimuth - bilinear interpolation',levels=levs,c_labels=findgen(nlevels)*0+1,xstyle=3,ystyle=3,xrange=[xlo,xhi],yrange=[0,70],c_charsize=1.3
plots,taz,tel,daz,psym=7,color=fsc_color('red')
xyouts,taz,tel,string(fix(daz),format='(i3)'),charthick=2
;
; A 2 degree grid with grid dimensions.  
delta = 10   
dims = [360, 90]/delta  
; The lon/lat grid locations  
lon_grid = FINDGEN(dims[0]) * delta    
lat_grid = FINDGEN(dims[1]) * delta  
res=GRIDDATA(taz, tel, daz, /KRIGING, /DEGREES, START = 0, /SPHERE, $  
   DELTA = delta, DIMENSION = dims)
contour,res,lon_grid,lat_grid,/downhill,xtitle='Telescope Azimuth',ytitle='Telescope alt.',title='Dome azimuth - kriging',levels=levs,c_labels=findgen(nlevels)*0+1,xstyle=3,ystyle=3,xrange=[xlo,xhi],yrange=[0,70],c_charsize=1.3
plots,taz,tel,daz,psym=7,color=fsc_color('red')
xyouts,taz,tel,string(fix(daz),format='(i3)'),charthick=2
help,res
l=size(res,/dimensions)
fmt='(i4,1x,'+string(fix(l(1)))+'(1x,i4))'
fmt3='('+string(fix(l(1)))+'(1x,i4))'
fmt2='(a,i4,1x,'+string(fix(l(1)))+'(1x,i4))'
print,'fmt:',fmt
openw,56,'gridded_dome_pointing_table.headers'
openw,57,'gridded_dome_pointing_table.no_headers'
printf,56,format=fmt2,'     ',lat_grid(*)
for i=0,l(0)-1,1 do begin
printf,56,format=fmt,lon_grid(i),res(i,*)
printf,57,format=fmt3,res(i,*)
endfor
close,56
close,57
end
