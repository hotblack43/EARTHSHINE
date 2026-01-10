PRO TestSIDXFocus

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

    result = SIDXAcquisitionBeginFocus(camera)

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

        IF (frames > 0) THEN BEGIN
           result = SIDXAcquisitionGetFrames(camera, 1, 0, image, time, frames_returned)

           ; Display the image data in the image tool.
           TVSCL, image, 0, /ORDER

          count = count + 1
        ENDIF


    ENDREP UNTIL (count GT 100)

    SIDXAcquisitionAbort, camera

    SIDXAcquisitionEnd, camera

    SIDXClose, sidx

    print, "TestSIDXFocus succeeded."

END