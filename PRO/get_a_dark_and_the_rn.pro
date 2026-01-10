PRO get_a_dark_and_the_RN,ncols,nrows,exposure_time,camera_ID,dark,RN

if (strupcase(camera_ID) eq strupcase('simulate_perfect_CCD')) then begin
	dc=0.0	; electrons per second per pixel
	RNrms=0.0d0		; RMS mean electrons per pixel
	dark=dindgen(ncols,nrows)*0.0d0
	RN=dindgen(ncols,nrows)*0.0d0
	return
endif
if (strupcase(camera_ID) eq strupcase('SXVH9')) then begin
	dc=0.02*exposure_time	; electrons per second per pixel
	RNrms=12.0d0		; RMS mean electrons per pixel
	dark=randomn(seed,ncols,nrows,poisson=dc,/double)
	RN=randomn(seed,ncols,nrows,poisson=RNrms,/double)
	return
endif
print,'Should not be here!'
stop
end


