file='wehrli85.txt'
data=get_data(file)
lamda=reform(data(0,*))
col1=reform(data(1,*))
col2=reform(data(2,*))
plot,title='Wehrli spåectrum of Sun',xrange=[330,1100],xstyle=3,lamda,col1,xtitle='Wavelength [nm]'
oplot,[440,440],[!Y.crange],linestyle=2
oplot,[550,550],[!Y.crange],linestyle=2
print,int_tabulated(lamda,col1)
end
