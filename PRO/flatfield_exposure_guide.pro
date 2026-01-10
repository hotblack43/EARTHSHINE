duration=30.	; duration of twilight in minutes
exptime=1.0
ROT=1.	; camera read-out time in seconds
SLEW=5.0	; telescope slew time
FILTER=5.0
n_change_filter=15
time=0.0
k=0.091
tau=1.0	; duration of twilight scale factor
icount=0
exposuretime=exptime
while (time le duration*60. and exposuretime lt 60.) do begin
exposuretime=exptime*10^(k*(time/60.)/tau)
print,icount,time,exposuretime
if (icount/n_change_filter ne float(icount)/float(n_change_filter)) then time=time+exposuretime+ROT+SLEW
if (icount/n_change_filter eq float(icount)/float(n_change_filter)) then begin
	time=time+exposuretime+ROT+SLEW+FILTER
	print,'Set filter'
endif
icount=icount+1
endwhile
end
