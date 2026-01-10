; test program for serial port reader
; NOTE: you MUST set the COM port number correctly first time or code crashes
;
portstring='COM3'
print,'Trying to open ',portstring
handle=comm_open('COM1',BAUD=9600,DATA=8,MODE=3,PARITY='N',STOP=1)
print,'handle from OPEN=',handle
;--------- WRITE
data=byte('6b')
h=comm_write(handle,data)
print,'Result of write : ',h
;--------- READ
h=comm_read(handle,BUFFER=buf)
print,'Result of read : ',h
buf=''
print,'Buffer read: ',buf
;--------- CLOSE -------------
res=comm_close(/all)
print,'result of comm_close command:',res
end