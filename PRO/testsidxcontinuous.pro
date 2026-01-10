PRO TestSIDXContinuous

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

    result = SIDXAcquisitionBeginContinuous(camera)

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

    image = MAKE_ARRAY(pixels_x, pixels_y, /INTEGER, VALUE = 0);

    result = SIDXAcquisitionStart(camera)

    IF (result NE 0) THEN BEGIN
       SIDXCameraGetStatusText, camera, result, message
       print, message
       SIDXAcquisitionEnd, camera
       SIDXClose, sidx
       RETURN
    ENDIF

    count = 0
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

        count = count + frames

        WHILE (frames GT 0) DO BEGIN
           result = SIDXAcquisitionGetFrames(camera, 1, 0, image, time, frames_returned)

        	IF (result NE 0) THEN BEGIN
            SIDXCameraGetStatusText, camera, result, message
          	print, message
            SIDXAcquisitionAbort, camera
            SIDXAcquisitionEnd, camera
            SIDXClose, sidx
            RETURN
        	ENDIF

           ; Display the image data in the image tool.
           TVSCL, image, 0, /ORDER
           print, "Display frames to count %d", count

          frames = frames - 1
        ENDWHILE

    ENDREP UNTIL (count GT 100)

    print, 'Acquired frame count =', count

    SIDXAcquisitionAbort, camera

    SIDXAcquisitionEnd, camera

    SIDXClose, sidx

    print, "TestSIDXContinuous succeeded."

END