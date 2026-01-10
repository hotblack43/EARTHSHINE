!P.CHARSIZE=2
data=get_data('justDS.dat')
alfa=reform(data(3,*))
histo,alfa,min(alfa),max(alfa),(max(alfa)-min(alfa))/20.
delta=stddev(alfa)/sqrt(n_elements(alfa)-1)
xyouts,1.702,0.45,'!7a!3 from BS: '+string(median(alfa),format='(f7.5)')+' +/- '+string(delta,format='(f7.5)'),charsize=1.2
mn=min(alfa)
mx=max(alfa)
st=(max(alfa)-min(alfa))/20.
;
data=get_data('jutsBS.dat')
alfa=reform(data(3,*))
!P.COLOR=fsc_color('red')
histo,/overplot,alfa,mn,mx,st/3.
delta=stddev(alfa)/sqrt(n_elements(alfa)-1)
xyouts,1.702,0.4,'!7a!3 from DS: '+string(median(alfa),format='(f7.5)')+' +/- '+string(delta,format='(f7.5)'),charsize=1.2
end
