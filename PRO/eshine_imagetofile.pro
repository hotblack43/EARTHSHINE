
;===============================================================================
;
; PRO eshine_imagetofile
;
; Version 2007-06-27
;
;===============================================================================


PRO eshine_imagetofile,  image_16bit, image_info, camera_ID, exposure_time, imsize, im_fmts, ipict, iframe, mpegID


;------------------------------
; Create an 8-bit image
;------------------------------
image_8bit = bytscl(image_16bit)


;-----------------------------------------------------------------------
; Define a file header
;-----------------------------------------------------------------------
MKHDR, header, image_16bit
caldat, image_info.JD, mm, dd, yy, hh, mnt, sec
convert_to_strings, mm, dd, yy, hh, mnt, sec, secstring, datestring, UTtimestring
sxaddpar, header, 'TIME-OBS', UTtimestring, 'Simulated time (UT)'
sxaddpar, header, 'OBSERVATORY', image_info.obsname, 'This is a simulation'
sxaddpar, header, 'INSTRUMENT', camera_ID, 'This camera is SIMULATED in this image.'
sxaddpar, header, 'EXPTIME', string(exposure_time), 'This is the SIMULATED exposure time.'


;-----------------------------------------------------------------------
; Write image to FITS/TIFF/JPEG file (and associated image info).
;-----------------------------------------------------------------------
if (ipict GE 0) AND (im_fmts[0] GT 0) then begin
  FITSlabel = strcompress('LunarImg_'+string(ipict,format='(I4.4)')+'.fts',/rem)
  writefits, FITSlabel, image_16bit, header
endif
if (ipict GE 0) AND (im_fmts[1] GT 0) then begin
  TIFFlabel = strcompress('LunarImg_'+string(ipict,format='(I4.4)')+'.tif',/rem)
  write_tiff, TIFFlabel, image_16bit, /SHORT
endif
if (ipict GE 0) AND (iframe EQ -1) AND (im_fmts[2] GT 0) then begin
  JPEGlabel = strcompress('LunarImg_'+string(ipict,format='(I4.4)')+'.jpg',/rem)
  write_jpeg, JPEGlabel, congrid(image_8bit,imsize,imsize), quality=80
endif
if (ipict GE 0) AND (im_fmts[0] GT 0 OR im_fmts[1] GT 0 OR (iframe EQ -1 AND im_fmts[2] GT 0)) then begin
  openw,1,strcompress('LunarImg_'+string(ipict,format='(I4.4)')+'.info',/rem)
  writeu,1,image_info
  close,1
endif


;-----------------------------------------------------------------------
; Write image to a frame in an MPEG file.
;-----------------------------------------------------------------------
if (iframe GE 0)  AND (im_fmts[2] GT 0) then begin
  mpeg_put, mpegID, FRAME=iframe, IMAGE=congrid(image_8bit,imsize,imsize)
endif


END
