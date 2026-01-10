PRO getraddecerr,tabname,median_delta_RA,median_delta_DEC,sd_ra,sd_DEC
ftab_ext,tabname,[3,4],ra,dec
ftab_ext,tabname,[7,8],ra2,dec2
delta_ra=ra-ra2
delta_dec=dec-dec2
; SD of the median, not just SD!!!!!
sd_ra=robust_sigma(delta_ra)/sqrt(n_elements(delta_ra)-1)
sd_dec=robust_sigma(delta_dec)/sqrt(n_elements(delta_dec)-1)
median_delta_RA=median(delta_ra)
median_delta_DEC=median(delta_dec)
end

!P.MULTI=[0,1,3]
fmt='(a,1x,f10.5,a,f5.2,1x,f10.5,a,f5.2,a)'
print,'Errors in RA and DEC between solution and catalogue'
getraddecerr,'R_new.corr',median_delta_RA,median_delta_DEC,sd_ra,sd_DEC
print,format=fmt,'R ',median_delta_ra*3600.,' +/- ',sd_ra*3600.,median_delta_DEC*3600.,' +/- ',sd_DEC*3600.,' arc seconds.'
getraddecerr,'G_new.corr',median_delta_RA,median_delta_DEC,sd_ra,sd_DEC
print,format=fmt,'G ',median_delta_ra*3600.,' +/- ',sd_ra*3600.,median_delta_DEC*3600.,' +/- ',sd_DEC*3600.,' arc seconds.'
getraddecerr,'B_new.corr',median_delta_RA,median_delta_DEC,sd_ra,sd_DEC
print,format=fmt,'B ',median_delta_ra*3600.,' +/- ',sd_ra*3600.,median_delta_DEC*3600.,' +/- ',sd_DEC*3600.,' arc seconds.'
end
