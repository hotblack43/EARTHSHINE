PRO make_IDEAL_images_of_Moon_from_list
    n_images = 4246
    seed = 0
    JD = 0.0d0

    OPENR, 44, '/home/pth/WORKSHOP/EARTHSHINE_CODE/all_MLO_good_Moon_image_JDs.txt', ERROR=err

    FOR i=0, n_images-1 DO BEGIN
        ; Read JD value from the input file
        IF NOT EOF(44) THEN BEGIN
            READF, 44, JD
            PRINT, 'Here I read : ', JD
        ENDIF ELSE BEGIN
            PRINT, 'End of file reached prematurely.'
            BREAK
        ENDELSE

        albedo = RANDOMU(seed, /double) * 0.5d0 + 0.1d0
        PRINT, JD, albedo

        OPENW, 45, 'JDtouseforSYNTH'
        PRINTF, 45, FORMAT='(f15.7)', JD
        CLOSE, 45

        OPENW, 46, 'single_scattering_albedo.dat'
        PRINTF, 46, FORMAT='(f15.7)', albedo
        CLOSE, 46

        str = 'gdl go_get_particular_synthimage_16_for_ML.pro'
        SPAWN, str
    ENDFOR

    ; Close and free the logical unit number
    CLOSE, 44
END

