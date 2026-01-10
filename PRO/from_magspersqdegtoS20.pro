PRO convertS10,in,out,itype
; brightness in mags per square degree to S10
;
;S10 is given
;B=10.0-2.5*alog10(S10) ; mags/sq deg
;C=B+2.5*alog10(3600.0d0^2)     ; mags/sq asec

; 
;
if (itype ne 1) then stop
if (itype eq 1) then begin
; convert from mags/sq.deg to S10
out=10^((in-10)/(-2.5)) ; [S10]
endif
return
end

in=-4.24	;mags/asec²
itype=1
convertS10,in,out,itype
print,in,out
end
