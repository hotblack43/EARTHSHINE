 ; Sets up the runoptions file for a run with e64_two
 ;................
 get_lun,uu
 openw,uu,'BINfiles/runoptions.txt'
 offset_start=10.0
 offset_stop=390.
 offset_steps=1000
 alfa_start=1.0
 alfa_stop=2.0
 alfa_steps=1000
 outerloops=1
 notzero=get_data('nonzero.dat')
 fmtstr='(2(a4,f9.2,a4,f9.2,a4,i5),2(1x,a4,i7))'
 printf,uu,format=fmtstr,$
' -a ',float(offset_start),$
' -b ',float(offset_stop),$
' -c ',fix(offset_steps),$
' -d ',float(alfa_start),$
' -e ',float(alfa_stop),$
' -f ',fix(alfa_steps),$
' -s ',fix(outerloops),$
' -g ',fix(notzero)
 close,uu
 free_lun,uu
 end
