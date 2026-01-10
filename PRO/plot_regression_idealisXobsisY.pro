file='regression_idealisXobsisY.txt'
str='grep _B_ '+file+" | sort | uniq | awk '{print $2,$3}' > B_offset_slope.dat"
spawn,str
str='grep _V_ '+file+" | sort | uniq | awk '{print $2,$3}' > V_offset_slope.dat"
spawn,str
str='grep _VE1_ '+file+" | sort | uniq | awk '{print $2,$3}' > VE1_offset_slope.dat"
spawn,str
str='grep _VE2_ '+file+" | sort | uniq | awk '{print $2,$3}' > VE2_offset_slope.dat"
spawn,str
str='grep _IRCUT_ '+file+" | sort | uniq | awk '{print $2,$3}' > IRCUT_offset_slope.dat"
spawn,str
;
!P.CHARSIZE=2
!P.MULTI=[0,2,5]
x1min=-1.3
x1max=0.5
x2min=0.5
x2max=2.3
xstep=0.07
data=get_data('B_offset_slope.dat')
offset=reform(data(0,*))
print,'N= ',n_elements(offset)
slope=reform(data(1,*))
histo,/abs,offset,x1min,x1max,xstep,xtitle='B offset'
xyouts,/data,-0.2,5,string(median(offset),format='(f5.2)')
histo,/abs,slope,x2min,x2max,xstep,xtitle='B slope'
xyouts,/data,0.6,5,string(median(slope),format='(f4.2)')
data=get_data('V_offset_slope.dat')
offset=reform(data(0,*))
print,'N= ',n_elements(offset)
slope=reform(data(1,*))
histo,/abs,offset,x1min,x1max,xstep,xtitle='V offset'
xyouts,/data,-0.2,5,string(median(offset),format='(f5.2)')
histo,/abs,slope,x2min,x2max,xstep,xtitle='V slope'
xyouts,/data,0.6,5,string(median(slope),format='(f4.2)')
data=get_data('VE1_offset_slope.dat')
offset=reform(data(0,*))
print,'N= ',n_elements(offset)
slope=reform(data(1,*))
histo,/abs,offset,x1min,x1max,xstep,xtitle='VE1 offset'
xyouts,/data,-0.2,5,string(median(offset),format='(f5.2)')
histo,/abs,slope,x2min,x2max,xstep,xtitle='VE1 slope'
xyouts,/data,0.6,5,string(median(slope),format='(f4.2)')
data=get_data('IRCUT_offset_slope.dat')
offset=reform(data(0,*))
print,'N= ',n_elements(offset)
slope=reform(data(1,*))
histo,/abs,offset,x1min,x1max,xstep,xtitle='IRCUT offset'
xyouts,/data,-0.2,5,string(median(offset),format='(f5.2)')
histo,/abs,slope,x2min,x2max,xstep,xtitle='IRCUT slope'
xyouts,/data,0.6,5,string(median(slope),format='(f4.2)')
data=get_data('VE2_offset_slope.dat')
offset=reform(data(0,*))
print,'N= ',n_elements(offset)
slope=reform(data(1,*))
histo,/abs,offset,x1min,x1max,xstep,xtitle='VE2 offset'
xyouts,/data,-0.2,5,string(median(offset),format='(f5.2)')
histo,/abs,slope,x2min,x2max,xstep,xtitle='VE2 slope'
xyouts,/data,0.6,5,string(median(slope),format='(f4.2)')
end
