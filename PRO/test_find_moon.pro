mm=12
dd=12
yy=2010
hr=5
jd=julday(mm,dd,yy,hr)
obsname='lund'
alt=-8
RiseSet=1	; Want dawn or Dusk solution
find_sun,jd,jd_solution,alt,RiseSet,obsname
end
