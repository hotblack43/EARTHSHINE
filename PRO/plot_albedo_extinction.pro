

PRO subr,filterstr
file=strcompress(filterstr+'_albedo_extinction.dat',/remove_all)
data=get_data(file)
;print,'Mean slopes: ',median(data),' mags/airmass'
;print,'SD_mean    : ',stddev(data)/sqrt(n_elements(data)-1)
print,format='(a,a,f9.3,a,f9.3,a,i3,a)',filterstr,' & ',median(data),'$\pm$',stddev(data)/sqrt(n_elements(data)-1),'&',n_elements(data),'\\'
return
end

filterstr='B'
subr,filterstr
filterstr='V'
subr,filterstr
filterstr='VE1'
subr,filterstr
filterstr='VE2'
subr,filterstr
filterstr='IRCUT'
subr,filterstr
end
