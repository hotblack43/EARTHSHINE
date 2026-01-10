PRO generate_observing_times,startyear,stopyear,n_each_night,n_nights,list
; will generate a list of bunched observing times - bunched 
; so that each night has many observations but then there 
; may be several nights without any
;
; find the local times at which observations are performed each night
hours=randomu(seed,n_each_night)*24.0
; find the nights wehn observations are performed
jd=randomu(seed,n_nights)*(julday(1,1,stopyear)-julday(1,1,startyear))+julday(1,1,startyear)
jd=jd(sort(jd))
jd=jd(uniq(jd))	; just the unique nights
; put all hours on each of thos enights
for i=0,n_elements(jd)-1,1 do begin
	if (i eq 0) then list=(jd(0)+hours/24.0d0)
	if (i gt 0) then list=[[list],[(jd(i)+hours/24.0d0) ]]
	help,list
endfor
l=size(list,/dimensions)
n_nights=l(1)
return
end
