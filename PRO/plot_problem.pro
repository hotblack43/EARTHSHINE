 filternames=['B','IRCUT','V','VE1','VE2']
 coln=['blue','orange','green','gray','yellow','red']
 types=['H-X_HIRESscaled', 'H-X_LRO', 'H-X_UVVISnoscale', 'newH-63_HIRESscaled', 'newH-63_LRO', 'newH-63_UVVISnoscale']

data=get_data('eureqain.noheader')
albedo=reform(data(0,*))
filter=reform(data(1,*))
brdf=reform(data(2,*))
phase=reform(data(3,*))
magnitude=reform(data(5,*))
;
!P.thick=4
!P.charthick=3
!p.charsize=2
!P.multi=[0,1,2]
for ifilter=0,4,1 do begin
idx=where(filter eq ifilter)
tstr=filternames(ifilter)
plot,psym=7,phase(idx),magnitude(idx),title=tstr,xtitle='Phase (FM at 0)',ytitle='BS magnitude'
oplot,[0,0],[!Y.crange],linestyle=2
for k=0,5,1 do begin
	 kdx=where(filter eq ifilter and brdf eq k)
	 oplot,psym=7,phase(kdx),magnitude(kdx),color=fsc_color(coln(k))
endfor
plot,psym=7,phase(idx),albedo(idx),xtitle='Phase (FM at 0)',ytitle='Albedo'
oplot,[0,0],[!Y.crange],linestyle=2
for k=0,5,1 do begin
	 kdx=where(filter eq ifilter and brdf eq k)
	 oplot,psym=7,phase(kdx),albedo(kdx),color=fsc_color(coln(k))
endfor
endfor
for k=0,5,1 do print,coln(k),' is ',types(k)
end
