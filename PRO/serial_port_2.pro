portstring='COM3'
print,'Trying to open ',portstring
h = comm_open(portstring, DATA=8,BAUD=9600, STOP=1, $
  PARITY='N', MODE=3);, BUFFERSIZE=8192)
print,'handle from OPEN=',h

;--------- WRITE
data = bytarr(19) + byte(':LF#')
b = comm_write(h, data)
print,'Result of write : ',b

;--------- READ
wait, .55
data2 = bytarr(19)
n=0
while (n eq 0) do begin
	b= comm_read(h, buffer=data2)
	print,'Result of read in loop : ',data2
	x=where(data2 gt 0, n)
endwhile
z=data2(0:n-1)
print, 'Result of read once n was not 0: ',z
print,string(z)

;--------- CLOSE -------------
res=comm_close(/all)
print,'result of comm_close command:',res
end


