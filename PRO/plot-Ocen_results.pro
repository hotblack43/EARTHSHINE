file='Ocean_results.dat'
data=get_data(file)
h=reform(data(0,*))
set_plot,'win
lamda=reform(data(1,*))
rho=1.0e3
Cp=4.1813e3
kappa=reform(data(2,*))
print,'h:',mean(h),' +/- ',stddev(h)
print,'lamda:',mean(lamda),' +/- ',stddev(lamda)
print,'kappa:',mean(kappa),' +/- ',stddev(kappa)
set_plot,'win
!P.MULTI=[0,1,3]
histo,h,35,45,.5,xtitle='h (m)'
histo,lamda,1.95,2.03,.005,xtitle='!7k!3'
histo,kappa,2.6e-4,3.4e-4,0.1e-4,xtitle='!7j!3'
set_plot,'ps
device,/color,filename='Ocean_results.ps'
!P.MULTI=[0,1,3]
histo,h,35,45,.5,xtitle='h (m)'
histo,lamda,1.95,2.03,.005,xtitle='!7k!3'
histo,kappa,2.6e-4,3.4e-4,0.1e-4,xtitle='!7j!3'
device,/close
end