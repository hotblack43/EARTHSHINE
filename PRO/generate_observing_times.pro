PRO generate_ordered_random_observing_moments,list
nobs_per_night=24
n_nights=5.*365.25
startyear=2010
for i=0,n_nights-1,1 do begin
if (randomn(seed) gt 0.0) then begin	; pick out only half the days
	x=julday(1,1,startyear)+double(i)+randomu(seed,nobs_per_night)
	x=x(sort(x))
	for j=0,nobs_per_night-1,1 do begin
		caldat,x(j),mm,dd,yy,hh,min,sec
		if (i eq 0) then list=[x(j),mm,dd,yy,hh,min,sec]
		if (i gt 0) then list=[[list],[x(j),mm,dd,yy,hh,min,sec]]
	endfor
endif
endfor
return
end

generate_ordered_random_observing_moments,list
end
