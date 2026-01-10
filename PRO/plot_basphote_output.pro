data=get_data('basphote_output.dat')
jd=reform(data(0,*))
flux=reform(data(1,*))
flerr=reform(data(2,*))
mag=reform(data(3,*))
expt=reform(data(4,*))
idx=where(flux lt 3.*median(flux))
jd=jd(idx)
flux=flux(idx)
flerr=flerr(idx)
mag=mag(idx)
expt=expt(idx)
plot,jd-jd(0),flux
oploterr,jd-jd(0),flux,flerr
print,'SD of exptime in %: ',stddev(expt)/mean(expt)*100.,' %'
print,'SD of flux    in %: ',stddev(flux)/mean(flux)*100.,' %'
end
