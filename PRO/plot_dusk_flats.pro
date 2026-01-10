data=get_data('dusk_flats.txt')
t=reform(data(0,*))
texp=reform(data(1,*))
meanval=reform(data(2,*))
flux=meanval/texp
plot,t,flux,xtitle='Time',ytitle='S [counts/s]',charsize=2,xstyle=3,ystyle=3,psym=7,title='Dusk sky brightness on October 11 2010'
end
