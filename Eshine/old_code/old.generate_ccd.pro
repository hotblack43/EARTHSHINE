PRO generate_CCD,object_in,image_number,camera_ID,exposure_time,CCD_out,raw_CCD
;===================================================================================
; Routine to simulate realistic CCD images: Will simulate effects of Bias, Dark Current,
; ReadoutNoise and the flat field
; Version 2 - omits scattered light in optical system
;----------------------------------------------------------------------------------
;  object_in  (INPUT)   : The image as it enters the telescope - i.e. sky contribution is included
;                                       and there is NO POISSON NOISE
; image_number (INPUT)  : a sequence number for naming purposes
;  camera_ID  (INPUT)   : A string identifying the camera characteristics
;  exposure_time (INPUT): The exposure time in seconds - sets dark current etc.
;
;  CCD_out    (OUTPUT)  : The simulated CCD image - UINT
;  raw_CCD   (OUTPUT)  : The simulated CCD image - double float
;----------------------------------------------------------------------------------
;
; Basic equation used is: CCD = (Object)*Flat+Bias+Dark+RN, where
; Object = e.g. Moon +Sky, idalized - i.e. in un-noisy flux values
; Flat= flat field frame, i.e. the 'gain' of the CCD - a map of pixel sensitivities
; Bias= offset added by camera electronics - fixed pattern map
; Dark= dark current added by camera due to 'shot noise' in electronics
; RN  = read-out noise, noise added by mere act of reading CCD
;===================================================================================
l=size(object_in,/dimensions)
ncols=l(0)
nrows=l(1)
if (strupcase(camera_ID) eq strupcase('SXVH9')) then begin
; the CCD/camera
    full_well=27000L		; electrons
    AD=0.45							; e/ADU
    dc=0.02*exposure_time	; electrons  per pixel
	RNrms=12.0d0		; RMS mean electrons per pixel
; setting up the dark-current
	dark_current=randomn(seed,ncols,nrows,poisson=dc,/double)/AD
	RN=randomn(seed,ncols,nrows,poisson=RNrms,/double)/AD
	Bias=object_in*0.0d0+1000.0
; the gain
	slope=0.01
	gain=dindgen(l)
	gain=gain/float(nrows*ncols)*slope+1.
	gain=1.0d0+gain-mean(gain)
; First scale the image so that full-well capcity is utilized to 95%
image_electrons=object_in*gain/max(object_in*gain)*full_well*0.95d0
; then generate Poisson noise in the electron image
for i=0,l(0)-1,1 do begin
for j=0,l(1)-1,1 do begin
 if (image_electrons(i,j) ne 0) then image_electrons(i,j)=randomn(seed,poisson=image_electrons(i,j))
endfor
endfor
; then convert to ADUs
image_ADU=image_electrons/AD
; set up the dark frame - i.e. what would be registered if an image was taken with
; the same exposure time but with aperture closed
darkframe=Bias+dark_current+RN
; then assembled image as would be read out
	raw_CCD=image_ADU+darkframe
	CCD_out=UINT(raw_CCD)
	flat=gain*0.0d0
	for i=0,l(0)-1,1 do begin
	for j=0,l(1)-1,1 do begin
	if(gain(i,j) ne 0) then flat(i,j)=randomn(seed,poisson=gain(i,j)*full_well*0.5d0)
	endfor
	endfor
; generate a suitable header
	MKHDR, header, flat
        sxaddpar, header, 'CCD_CAMERA','SIMULATED SXVH9','flat simulated using generate_ccd.pro'
	writefits,strcompress('flat_'+string(image_number)+'.fit',/remove_all),flat,header
	MKHDR, header, darkframe
        sxaddpar, header, 'CCD_CAMERA','SIMULATED SXVH9','Simulated using generate_ccd.pro'
        sxaddpar, header, 'EXPTIME',string(exposure_time),'Sumulated exposure time'
	writefits,strcompress('darkframe_'+string(image_number)+'.fit',/remove_all),darkframe,header
return
endif
;
if (strupcase(camera_ID) eq strupcase('STL1001E')) then begin	; NOT IMPLEMENTED YET
; the chip/camera
    full_well=150000L
    AD=2.2	; e/ADU
    dc=34.0d0*exposure_time	; electrons per second per pixel
    RNrms=16.0d0		; RMS mean electrons per pixel
stop
return
endif
;
print,'STOPPING: The routine generate_CCD did not receive a recognised setup-string for the camera:',camera_ID
stop
end
