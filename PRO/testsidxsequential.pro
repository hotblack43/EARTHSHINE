PRO TestSIDXSequential

    result = SIDXOpen(sidx, 0)

    IF (result NE 0) THEN BEGIN
       SIDXGetStatusText, sidx, result, message
       print, message
       RETURN
    ENDIF

    result = SIDXDialogCameraSelector(sidx, canceled, camera)

    IF (result NE 0) THEN BEGIN
       SIDXGetStatusText, sidx, result, message
       print, message
       SIDXClose, sidx
       RETURN
    ENDIF

	IF (canceled NE 0) THEN BEGIN
       print, "Operation canceled."
       SIDXClose, sidx
       RETURN
	ENDIF

    ; Adjust camera settings
    result = SIDXDialogCamera(camera, canceled)

    IF (result NE 0) THEN BEGIN
       SIDXCameraGetStatusText, camera, result, message
       print, message
       SIDXClose, sidx
       RETURN
    ENDIF

    IF (canceled NE 0) THEN BEGIN
       print, "Camera dialog was canceled."
       SIDXClose, sidx
       RETURN
    ENDIF

    result = SIDXDialogImage(camera, canceled)

    IF (result NE 0) THEN BEGIN
       SIDXCameraGetStatusText, camera, result, message
       print, message
       SIDXClose, sidx
       RETURN
    ENDIF

    IF (canceled NE 0) THEN BEGIN
       print, "Imaging dialog was canceled."
       SIDXClose, sidx
       RETURN
    ENDIF

    frames_acquire = 1
    result = SIDXAcquisitionBeginSequence(camera, frames_acquire)

    IF (result NE 0) THEN BEGIN
       SIDXCameraGetStatusText, camera, result, message
       print, message
       SIDXClose, sidx
       RETURN
    ENDIF

    result = SIDXAcquisitionGetSize(camera, 0, bytes, pixels_x, pixels_y)

    IF (result NE 0) THEN BEGIN
       SIDXCameraGetStatusText, camera, result, message
       print, message
       SIDXAcquisitionEnd, camera
       SIDXClose, sidx
       RETURN
    ENDIF

    image = MAKE_ARRAY(pixels_x, pixels_y, frames_acquire, /INTEGER, VALUE = 0);

    result = SIDXAcquisitionStart(camera)

    IF (result NE 0) THEN BEGIN
       SIDXCameraGetStatusText, camera, result, message
       print, message
       SIDXAcquisitionEnd, camera
       SIDXClose, sidx
       RETURN
    ENDIF

    REPEAT BEGIN
        result = SIDXAcquisitionFramesAvailable(camera, frames)

        IF (result NE 0) THEN BEGIN
            SIDXCameraGetStatusText, camera, result, message
            print, message
            SIDXAcquisitionAbort, camera
            SIDXAcquisitionEnd, camera
            SIDXClose, sidx
            RETURN
        ENDIF

    ENDREP UNTIL (frames GE frames_acquire)

    SIDXAcquisitionStop, camera

    result = SIDXAcquisitionGetFrames(camera, frames, 0, image, time, frames_returned)
    IF (result NE 0) THEN BEGIN
        SIDXCameraGetStatusText, camera, result, message
        print, message
        SIDXAcquisitionEnd, camera
        SIDXClose, sidx
        RETURN
    ENDIF

    TVSCL, image, 0

;   count = 0
;   WHILE (count LT frames_acquire) DO BEGIN
        ; Display the image data in the image tool.
;        current_image = EXTRAC(image, 1, 1, count, pixels_x, pixels_y, 1)
;         TVSCL, current_image, 0
;        count = count + 1

;    ENDWHILE

    SIDXAcquisitionEnd, camera

    SIDXClose, sidx

    print, "TestSIDXSequential succeeded."

END