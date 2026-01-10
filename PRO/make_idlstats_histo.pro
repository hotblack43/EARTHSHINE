data=get_data('idlstats.dat')
n=reform(data(0,*))
u=reform(data(1,*))
f=reform(data(2,*))
!P.CHARSIZE=2
!P.MULTI=[0,1,2]
histo,u,0,150,5,title='IDL licenses in use',xtitle='Number of licenses in use'
histo,f,0,1,1./30.,xtitle='Fraction of licenses in use'
end
