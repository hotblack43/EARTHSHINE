openw,45,'fluxes_m_r.dat'
for t_limit=0.0,1.0,0.001 do begin
openw,44,'data.dat'
openr,1,'flux_vs_counts.dat'
while not eof(1) do begin
readf,1,a0,a1,measured,requested,a4,a5,counts
if (measured ge t_limit and requested ge t_limit) then printf,44,measured,requested,counts
endwhile
close,1
close,44
data=get_data('data.dat')
m=reform(data(0,*))
r=reform(data(1,*))
c=reform(data(2,*))
;print,'Measured exposure times SD:',stddev(m)
;print,'Requested exposure times SD:',stddev(r)
;print,'Counts SD:',stddev(c)
;print,'Counts/Measured SD                :',stddev(c/m)
;print,'Counts/Requested SD               :',stddev(c/r)
print,'For exposures longer than ',t_limit*1000.,' ms'
print,'Counts/Measured SD in pct of mean :',stddev(c/m)/mean(c/m)*100.0,' %.'
print,'Counts/Requested SD in pct of mean:',stddev(c/r)/mean(c/r)*100.0,' %.'
printf,45,t_limit*1000.,stddev(c/m)/mean(c/m)*100.0,stddev(c/r)/mean(c/r)*100.0
endfor
close,45
end
