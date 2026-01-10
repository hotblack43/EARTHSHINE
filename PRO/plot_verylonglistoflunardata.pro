file='use.verylonglistoflunardata.txt'
data=get_data(file)
lunar_alt=reform(data(0,*))
lunar_lon=reform(data(1,*))
;----------------
alt_limit=30.
idx=where(lunar_alt ge alt_limit)
n_above=n_elements(idx)
print,float(n_above)/float(n_elements(lunar_alt))*100.0,'% of altitudes above ',alt_limit
titstr=''
read,titstr,prompt='What is the station?'
histo, lunar_alt,0,90,2,xtitle='Lunar altitude',ytitle='N',xrange=[0,90],title=titstr,/abs
histo, lunar_alt(idx),0,90,2,/overplot,/abs
histo, lunar_lon,0,360,5,xtitle='Lunar azimuth',ytitle='N',xrange=[0,360],title=titstr,/abs
histo, lunar_lon(idx),0,360,5,/overplot,/abs
end
