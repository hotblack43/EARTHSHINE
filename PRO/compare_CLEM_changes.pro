file='CLEM.profiles_fitted_results_SEP_2014_TESTmodlvssemiempirical.txt'

str="grep semi "+file+" | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11}' > p1"
spawn,str
semi=get_data('p1')
str="grep theret "+file+" | awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11}' > p2"
spawn,str
theo=get_data('p2')
;
nsemi=n_elements(semi(0,*))
ntheo=n_elements(theo(0,*))
!P.CHARSIZE=2
!P.MULTI=[0,2,4]
if (nsemi ne ntheo) then stop
varnames=['JD','A','dA','alfa','rc','ped','dX','dY','cf','contrast','RMSE']
for ivar=0,11-1,1 do begin
if (ivar ne 7) then begin
openw,33,'fil'
for i=0,nsemi-1,1 do begin
idx=where(theo(0,*) eq semi(0,i))
if (idx(0) eq -1) then stop
printf,33,(semi(ivar,i)-theo(ivar,idx))/(0.5*(semi(ivar,i)+theo(ivar,idx)))*100.
print,ivar,i,(semi(ivar,i)-theo(ivar,idx))/(0.5*(semi(ivar,i)+theo(ivar,idx)))*100.
endfor
close,33
data=get_data('fil')
if (stddev(data) ne 0) then histo,/zeroline,/abs,data,min(data),max(data),(max(data)-min(data))/10.,xtitle=varnames(ivar)
if (ivar eq 1) then begin
print,'SD/mn of A in S: ',stddev(semi(ivar,*))/mean(semi(ivar,*))
print,'SD/mn of A in T: ',stddev(theo(ivar,*))/mean(theo(ivar,*))
endif
endif
endfor
end
