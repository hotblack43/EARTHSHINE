data=get_data('list_of_fittedAlbedo_B_changes_fixed_contrast.dat')
A1=reform(data(1,*))
A2=reform(data(3,*))
dA=A1-A2
print,'Mean change in pct: ',mean(da)/mean(A1)*100.,' SD in %: ',stddev(da)/mean(A1)*100.
histo,dA/mean(A1)*100.,-4,1,0.1,/abs,xtitle='!7D!3 Albedo!dB!n [% of mean]'
oplot,[median(dA/mean(A1)*100.),median(dA/mean(A1)*100.)],[!Y.crange],linestyle=2
end
