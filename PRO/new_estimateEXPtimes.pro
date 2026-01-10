PRO estimateexptimes,jd,FILTERtimes
filters=get_data('SETUP/exposure_factors.MOON')
days_since_last_fullmoon,jd,days
daysago=days-jd
get_exposure_factor,daysago,factor
caldat,days,mm,dd,yy,hh,mi,se
print,'FM was ',abs(daysago),' ago . So the exposure factor is now ',factor
scaling=0.85*0.75
FILTERtimes=filters*factor*scaling
end
