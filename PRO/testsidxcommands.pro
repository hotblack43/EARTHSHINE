PRO TestSIDXCommands

    result = SIDXOpen(sidx, 0)

    IF (result NE 0) THEN BEGIN
       print, 'Cannot open SIDX.'
       RETURN
    ENDIF

    result = SIDXGetCameraCount(sidx, count)
    IF (result NE 0) THEN BEGIN
       SIDXGetStatusText, sidx, result, message
       print, message
       SIDXClose, sidx
       RETURN
    ENDIF

    print, 'Avaiable camera count: ', count

    index = 0
    result = SIDXGetCameraName(sidx, index, camera_name)
    IF (result NE 0) THEN BEGIN
       SIDXGetStatusText, sidx, result, message
       print, message
	   SIDXClose, sidx
       RETURN
    ENDIF

    result = SIDXSettingsRestoreCamera(sidx, camera)
    IF (result EQ 0) THEN BEGIN
       SIDXCameraClose, camera
    ENDIF

    result = SIDXCameraOpen(sidx, '', camera)

    IF (result NE 0) THEN BEGIN
        result = SIDXDialogCameraSelector(sidx, canceled, camera)

        IF (result NE 0) THEN BEGIN
           SIDXGetStatusText, sidx, result, message
           print, message
		   SIDXClose, sidx
           RETURN
        ENDIF
    ENDIF

    vendor_id = 5 ;SciMeasure camera
    result = SIDXCameraIsVendor(camera, vendor_id, is_vendor)
    IF (result NE 0) THEN BEGIN
       SIDXCameraGetStatusText, camera, result, message
       print, message
    ENDIF ELSE BEGIN
        IF (is_vendor NE 0) THEN BEGIN
           print, 'The camera is SciMeasure camera'
        ENDIF
    ENDELSE

    ; Adjust camera settings
    result = SIDXTemperaturePowerOffCooling(camera)

    IF (result NE 0) THEN BEGIN
       SIDXCameraGetStatusText, camera, result, message
       print, message
    ENDIF

    temperature = 0.2
    result = SIDXTemperatureSetSetpoint(camera, temperature)

    IF (result NE 0) THEN BEGIN
       SIDXCameraGetStatusText, camera, result, message
       print, message
    ENDIF

    result = SIDXTemperatureGetSetpoint(camera, temperature, minimum, maximum, valid)

    IF (result NE 0) THEN BEGIN
       SIDXCameraGetStatusText, camera, result, message
       print, message
    ENDIF

    print, 'CCD temperature setpoint: ', temperature

    tag = 'SciMeasureAccumulationCount'

    value = '13'
    result = SIDXSettingSet(camera, tag, value)

    IF (result NE 0) THEN BEGIN
       SIDXCameraGetStatusText, camera, result, message
       print, message
    ENDIF

    result = SIDXSettingGet(camera, tag, value)

    IF (result NE 0) THEN BEGIN
       SIDXCameraGetStatusText, camera, result, message
       print, message
    ENDIF ELSE BEGIN
        print, 'SciMeasureAccumulationCount =', value
    ENDELSE

    mode = 0 ;No trigger with constant exposure time between sequences
    result = SIDXTriggerModeAvailable(camera, mode, available)

    IF (result NE 0) THEN BEGIN
        SIDXCameraGetStatusText, camera, result, message
        print, message

    ENDIF ELSE BEGIN
        IF (available NE 0) THEN BEGIN
            result = SIDXTriggerSet(camera, mode)

            IF (result NE 0) THEN BEGIN
                SIDXCameraGetStatusText, camera, result, message
                print, message
            ENDIF
        ENDIF

        result = SIDXTriggerGet(camera, mode)
        IF (result NE 0) THEN BEGIN
           SIDXCameraGetStatusText, camera, result, message
           print, message
        ENDIF

    ENDELSE

    mode = 0 ;Shutter normal
    result = SIDXShutterModeAvailable(camera, mode, available)

    IF (result NE 0) THEN BEGIN
        SIDXCameraGetStatusText, camera, result, message
        print, message

    ENDIF ELSE BEGIN
        IF (available NE 0) THEN BEGIN
            result = SIDXShutterSet(camera, mode)

            IF (result NE 0) THEN BEGIN
                SIDXCameraGetStatusText, camera, result, message
                print, message
            ENDIF
        ENDIF

        result = SIDXShutterGet(camera, mode)
        IF (result NE 0) THEN BEGIN
           SIDXCameraGetStatusText, camera, result, message
           print, message
        ENDIF

    ENDELSE

    result = SIDXROIClear(camera)

    IF (result NE 0) THEN BEGIN
        SIDXCameraGetStatusText, camera, result, message
        print, message

    ENDIF

    result = SIDXSensorGetParameters(camera, x, y, pixel_depth)
    IF (result NE 0) THEN BEGIN
        SIDXCameraGetStatusText, camera, result, message
        print, message

    ENDIF ELSE BEGIN
        print, 'CCD x dimension:', x
        print, 'CCD y dimension:', y
        print, 'CCD pixel depth:', pixel_depth
    ENDELSE

    x_binning = 1
    result = SIDXBinningXAvailable(camera, x_binning, x_valid)

    IF (result NE 0) THEN BEGIN
        SIDXCameraGetStatusText, camera, result, message
        print, message

    ENDIF ELSE BEGIN

        IF (x_valid NE 0) THEN BEGIN
            print, 'x binning setting available: ', x_binning
        ENDIF
    ENDELSE

    y_binning = 1
    result = SIDXBinningYAvailable(camera, y_binning, y_valid)

    IF (result NE 0) THEN BEGIN
        SIDXCameraGetStatusText, camera, result, message
        print, message

    ENDIF ELSE BEGIN

        IF (y_valid NE 0) THEN BEGIN
        print, 'y binning setting available: ', y_binning
        ENDIF
    ENDELSE

   result = SIDXBinningSet(camera, x_binning, y_binning)
   IF (result NE 0) THEN BEGIN
        SIDXCameraGetStatusText, camera, result, message
        print, message
   ENDIF

    result = SIDXROISet(camera, 0, 0, 50, 50)
    IF (result NE 0) THEN BEGIN
        SIDXCameraGetStatusText, camera, result, message
        print, message

    ENDIF

    result = SIDXGainGetCount(camera, gain_count)
    IF (result NE 0) THEN BEGIN
        SIDXCameraGetStatusText, camera, result, message
        print, message

    ENDIF ELSE BEGIN
        print, 'Available gain count: ', gain_count

       IF (gain_count GT 0) THEN BEGIN
         gain = 0
         result = SIDXGainSet(camera, gain)
         IF (result NE 0) THEN BEGIN
            SIDXCameraGetStatusText, camera, result, message
            print, message
         ENDIF

         result = SIDXGainGet(camera, gain, description)
         IF (result NE 0) THEN BEGIN
            SIDXCameraGetStatusText, camera, result, message
            print, message

         ENDIF ELSE BEGIN
            print, 'First available gain: ', description
         ENDELSE

            result = SIDXGainGetCurrent(camera, gain)
         IF (result NE 0) THEN BEGIN
            SIDXCameraGetStatusText, camera, result, message
            print, message
         ENDIF
       ENDIF
    ENDELSE

    result = SIDXExposureTimeGetRange(camera, minimum, maximum, resolution)
    IF (result NE 0) THEN BEGIN
        SIDXCameraGetStatusText, camera, result, message
        print, message

    ENDIF ELSE BEGIN
        print, 'minimum exposure value: ', minimum
        print, 'maximum exposure value: ', maximum
        print, 'exposure resolution: ', resolution

        exposure = minimum + resolution
        result = SIDXExposureTimeSet(camera, exposure)
        IF (result NE 0) THEN BEGIN
            SIDXCameraGetStatusText, camera, result, message
            print, message

        ENDIF

        result = SIDXExposureTimeGet(camera, exposure)

        IF (result NE 0) THEN BEGIN
            SIDXCameraGetStatusText, camera, result, message
            print, message

        ENDIF
    ENDELSE

    result = SIDXSettingsGet(camera, settings)
    IF (result NE 0) THEN BEGIN
        SIDXCameraGetStatusText, camera, result, message
        print, message
    ENDIF ELSE BEGIN
       print, settings
    ENDELSE

    result = SIDXSettingsSaveCamera(camera)
    IF (result NE 0) THEN BEGIN
        SIDXCameraGetStatusText, camera, result, message
        print, message
    ENDIF

    SIDXClose, sidx

    print, "TestSIDXFocus succeeded."

END