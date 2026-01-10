
;===============================================================================
;
; PRO eshine_imagetofile
;
; Version 2007-08-02
;
;===============================================================================


PRO eshine_imagetofile,  image, image_info, im_fmts, ipict, iframe, mpegID


;-----------------------------------------------------------------------
; Extract image information & determine pixel type: uint or float/double
;-----------------------------------------------------------------------
JD        = image_info.JD
obsname   = image_info.obsname
camera_ID = image_info.camera_ID
CCDcols   = image_info.CCDcols
CCDrows   = image_info.CCDrows
exptime   = image_info.exptime
ptype     = size(image,/type)


;-----------------------------------------------------------------------
; Define a file prefix
;-----------------------------------------------------------------------
if (ptype EQ 12) then begin
  prefix = 'LunarImg_'
endif else if (ptype EQ 4 OR ptype EQ 5) then begin
  prefix = 'LunarImg_ideal_'
endif else begin
  stop, 'ERROR: pixel type must be UINT or FLOAT/DOUBLE'
endelse


;-----------------------------------------------------------------------
; Define a file header
;-----------------------------------------------------------------------
MKHDR, header, image
caldat, JD, mm, dd, yy, hh, mnt, sec
convert_to_strings, mm, dd, yy, hh, mnt, sec, secstring, datestring, UTtimestring
sxaddpar, header, 'TIME-OBS', UTtimestring, 'Simulated time (UT)'
sxaddpar, header, 'OBSERVATORY', obsname, 'This is a simulation'
sxaddpar, header, 'INSTRUMENT', camera_ID, 'This camera is SIMULATED in this image.'
sxaddpar, header, 'EXPTIME', string(exptime), 'This is the SIMULATED exposure time.'


;-----------------------------------------------------------------------
; Create an 8-bit image
;-----------------------------------------------------------------------
image_8bit  = bytscl(image)


;-----------------------------------------------------------------------
; Write image to FITS/TIFF/JPEG file (and associated image info).
;-----------------------------------------------------------------------
if (ipict GE 0) AND (im_fmts[0] GT 0) then begin
  FITSlabel = strcompress(prefix + string(ipict,format='(I4.4)')+'.fts',/rem)
  writefits, FITSlabel, image, header
endif
if (ipict GE 0) AND (im_fmts[1] GT 0) then begin
  TIFFlabel = strcompress(prefix + string(ipict,format='(I4.4)')+'.tif',/rem)
  write_tiff, TIFFlabel, image, /SHORT
endif
if (ipict GE 0) AND (iframe EQ -1) AND (im_fmts[2] GT 0) then begin
  JPEGlabel = strcompress(prefix + string(ipict,format='(I4.4)')+'.jpg',/rem)
  write_jpeg, JPEGlabel, congrid(image_8bit,CCDcols,CCDrows), quality=80
endif
if (ipict GE 0) AND (im_fmts[0] GT 0 OR im_fmts[1] GT 0 OR (iframe EQ -1 AND im_fmts[2] GT 0)) then begin
  openw,1,strcompress(prefix + string(ipict,format='(I4.4)')+'.info',/rem)
  writeu,1,image_info
  close,1
endif


;-----------------------------------------------------------------------
; Write image to a frame in an MPEG file.
;-----------------------------------------------------------------------
if (iframe GE 0)  AND (im_fmts[2] GT 0) then begin
  mpeg_put, mpegID, FRAME=iframe, IMAGE=congrid(image_8bit,CCDcols,CCDrows)
endif


END
