data=get_data('all_bulk_corrected_albedo.dat')
jd=reform(data(0,*))
phase=reform(data(1,*))
filter=reform(data(2,*))
albedo=reform(data(3,*))
BSis=reform(data(4,*))
!P.CHARSIZE=1.8
!P.MULTI=[0,1,3]
cols=['blue','green','yellow','red','orange']
;-------------------------
plot,xtitle='Lunar phase',ytitle='Albedo',title='Bulk-corrected observations',xstyle=3,ystyle=3,phase,albedo,psym=7
for ifi=0,4,1 do begin
jdx=where(filter eq ifi+1)
oplot,phase(jdx),albedo(jdx),psym=7,color=fsc_color(cols(ifi))
endfor
;-------------------------
plot,xtitle='Fraction of day',ytitle='Albedo',title='Bulk-corrected observations',xstyle=3,ystyle=3,jd mod 1,albedo,psym=7
for ifi=0,4,1 do begin
jdx=where(filter eq ifi+1)
oplot,jd(jdx) mod 1,albedo(jdx),psym=7,color=fsc_color(cols(ifi))
endfor
;-------------------------
plot,xtitle='JD',ytitle='Albedo',title='Bulk-corrected observations',xstyle=3,ystyle=3,jd,albedo,psym=7
for ifi=0,4,1 do begin
jdx=where(filter eq ifi+1)
oplot,jd(jdx),albedo(jdx),psym=7,color=fsc_color(cols(ifi))
endfor
;-------------------------
end
