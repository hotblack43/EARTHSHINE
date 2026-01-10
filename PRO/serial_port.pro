; test program for serial port reader
; NOTE: you MUST set the COM port number correctly first time or code crashes
;
portstring='COM3'
print,'Trying to open ',portstring
handle=comm_open(portstring,DATA=8,BAUD=4800,STOP=1,PARITY='N',mode=3)
print,'handle from OPEN=',handle
;--------- WRITE
; write an LX200 command
data=byte('#:GR#')
h=comm_write(handle,data)
print,'Result of write : ',h
;--------- READ
; try to read the port to get the response due to the request in write above
      t = SYSTIME(1)
      While (systime(1) - t lt 5) do begin
         h=comm_read(handle,BUFFER=result)
         print,'h=',h
      Endwhile
print,'Result of read : ',h
buf=''
print,'Buffer read: ',buf
;--------- CLOSE -------------
res=comm_close(/all)
print,'result of comm_close command:',res
end