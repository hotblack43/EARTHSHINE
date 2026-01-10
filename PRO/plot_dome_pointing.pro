data=get_data('dome_pointing_table.noheader')
; headers were: tele_az tele_el dome_az
TAZ=reform(data(0,*))
TEL=reform(data(1,*))
dome_offset=345.-15.
DAZ=(reform(data(2,*))+dome_offset)
DAZ=DAZ mod 360
;

nlevels=41
levs=findgen(nlevels)/float(nlevels-1)*360.
;c_ann=string(levs)
;polar_contour,c_annotation=c_ann,c_labels=findgen(100)*0+1,DAZ,TAZ,R,/irregular,/downhill,xtitle='Telescope Azimuth'
contour,DAZ,TAZ,TEL,/irregular,/downhill,xtitle='Telescope Azimuth',ytitle='Telescope alt.',title='Dome azimuth',levels=levs,c_labels=findgen(nlevels)*0+1,xstyle=3,ystyle=3,xrange=[70,290]
end
