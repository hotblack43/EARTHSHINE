PRO generate_CCD_2,object_in,camera_ID,exposure_time,CCD_out,raw_CCD
;===================================================================================
; Routine to simulate realistic CCD images: Will simulate effects of Bias, Dark Current,
; ReadoutNoise and the flat field
; Version 2 - omits scattered light in optical system
;----------------------------------------------------------------------------------
;  object_in  (INPUT)   : The 'scene' as it enters the telescope - i.e. this
;                         is the object LESS any scattered light due to the
;                         atmosphere. NOTE: object_in must  contain any object Poisson noise.
;  camera_ID  (INPUT)   : A string identifying the camera characteristics
;  exposure_time (INPUT): The exposure time in seconds - sets dark current etc.
;
;  CCD_out    (OUTPUT)  : The simulated CCD image - UINT
;  raw_CCD   (OUTPUT)  : The simulated CCD image - double float
;----------------------------------------------------------------------------------
;
; Basic equation used is: CCD = (Object)*Flat+Bias+Dark+RN, where
; Flat= flat field frame, i.e. the 'gain' of the CCD - a map of pixel sensitivities
; Bias= offset added by camera electronics - fixed pattern map
; Dark= dark current added by camera due to 'shot noise' in electronics
; RN  = read-out noise, noise added by mere act of reading CCD
;===================================================================================
l=size(object_in,/dimensions)
ncols=l(0)
nrows=l(1)
if (strupcase(camera_ID) eq strupcase('simulate_perfect_CCD')) then begin
	slope=0.01
	Flat=get_a_flat(ncols,nrows,slope)	; call function tomodel flat field
	Bias=object_in*0.0d0+0.0
	get_a_dark_and_the_RN,ncols,nrows,exposure_time,camera_ID,dark,RN
	raw_CCD=(object_in)*Flat+Bias+RN
	CCD_out=UINT(raw_CCD)
	return
endif
if (strupcase(camera_ID) eq strupcase('SXVH9')) then begin
	slope=0.01
	Flat=get_a_flat(ncols,nrows,slope)	; call function to model flat field
	Bias=object_in*0.0d0+1000.0
	get_a_dark_and_the_RN,ncols,nrows,exposure_time,camera_ID,dark,RN
	raw_CCD=(object_in)*Flat+Bias+RN
	CCD_out=UINT(raw_CCD)
	return
endif
;
print,'STOPPING: The routine generate_CCD did not receive a recognised setup-string for the camera:',camera_ID
stop
end