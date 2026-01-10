FUNCTION comm_send,stringin,portopen
portstring='COM3'
h = comm_open(portstring, DATA=8,BAUD=9600, STOP=1, $
  PARITY='N', MODE=3);, BUFFERSIZE=8192)
;--------- WRITE
data = bytarr(1900) + byte(stringin)
b = comm_write(h, data)
;--------- READ
wait,0.1
data2 = bytarr(1900)
n=0
t=systime(1)
while (n eq 0 and (systime(1) - t lt 10)) do begin
	b= comm_read(h, buffer=data2)
;	print,'Result of read in loop : ',data2
	x=where(data2 gt 0, n)
endwhile
z=data2(0:n-1)
;print, 'Result of read once n was not 0: ',z
stringout=string(z)
res=comm_close(/all)
return,stringout
end

;--------- CLOSE -------------

  portopen=1
stringin=':GD#'
stringin=':SS 12:12:12#'
stringout=comm_send(stringin,portopen)
print,'result of ',stringin,' :',stringout
stringin=':GS#'
stringout=comm_send(stringin,portopen)
print,'result of ',stringin,' :',stringout
stringin=':Mn#'
stringout=comm_send(stringin,portopen)
print,'result of ',stringin,' :',stringout
stringin=':Qn#'
stringout=comm_send(stringin,portopen)
print,'result of ',stringin,' :',stringout

end


