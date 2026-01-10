data=get_data('deltasum.dat')
data2=get_data('deltasum_v2.dat')
help
plot_oo,data(0,*),data(3,*),xtitle='Iteration',ytitle='!7D!3!u2!n',charsize=2,yrange=[1e-8,1e8],ystyle=1,title='Alignment convergence'
oplot,data2(0,*),data2(3,*),linestyle=2
end
