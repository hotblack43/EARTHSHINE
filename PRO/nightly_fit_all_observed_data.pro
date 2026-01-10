nlimit=19
min_span=0.5
file='all_observed_data.dat'
data=get_data(file)
jd=reform(data(0,*))
am=reform(data(1,*))
observedmag=reform(data(2,*))
diffs=long(jd)-long(shift(jd,1))
breaks=where(diffs ne 0)
openw,11,'nightly_reduced.data'
for i=1,n_elements(breaks)-2,1 do begin
	jd_regressor=jd(breaks(i):breaks(i+1)-1)
	airmass_regressor=am(breaks(i):breaks(i+1)-1)
	observedmag_regressor=observedmag(breaks(i):breaks(i+1)-1)
	if (n_elements(jd_regressor) ge nlimit  and abs(max(airmass_regressor))-abs(min(airmass_regressor)) gt min_span) then begin
		res=linfit(airmass_regressor,observedmag_regressor,sigma=sigs,/double,yfit=yhat)
		plot,ystyle=1,airmass_regressor,observedmag_regressor,psym=7,title=long(jd_regressor(0)),charsize=2
		oplot,airmass_regressor,yhat,thick=3
		printf,11,format='(1x,f20.2,5(1x,f15.7))',long(jd_regressor(0))+0.5,res(0),res(1),sigs(0),sigs(1)
	endif
endfor
close,11
end
