VE2=get_data('VE2counts.dat')
V=get_data('Vcounts.dat')
plot_io,v(0,*),yrange=[300,2000]
oplot,v(1,*)
oplot,ve2(0,*)
oplot,ve2(1,*)
end
