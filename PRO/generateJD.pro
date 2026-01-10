PRO generateJD,obsdate,obstime,JD
year=fix(strmid(strmid(obsdate,11,10),0,4))
month=fix(strmid(strmid(obsdate,11,10),5,2))
dd=fix(strmid(strmid(obsdate,11,10),8,2))
hh=fix(strmid(strmid(obstime,11,8),0,2))
mm=fix(strmid(strmid(obstime,11,8),3,2))
ss=fix(strmid(strmid(obstime,11,8),6,2))
JD=julday(month,dd,year,hh,mm,ss)
return
end
