


datadir = 'C:\EarthShine\Simulation\Data_eshine'
datadir='C:\Documents and Settings\Daddyo\Skrivebord\ASTRO'



;===============================================================================
 HIRES_750:
;===============================================================================

;-----------------------------------------------------------
; HIRES 750 nm albedo data from JPEG file
; Source: albedo.simp750.jpeg from USGS
;-----------------------------------------------------------
ok = QUERY_JPEG(datadir+'/'+'HIRES_750_3ppd.jpg',JPEGINFO)
print, '  '
print, 'HIRES 750 JPEG'
print, JPEGINFO.type
print, JPEGINFO.num_images
print, JPEGINFO.dimensions
print, JPEGINFO.channels
print, JPEGINFO.pixel_type
if (ok) then begin
  READ_JPEG, datadir+'/'+'HIRES_750_3ppd.jpg', HIRES_JPEG, /GRAYSCALE
endif
newim = bytarr(1080,540)
newim[0:539,*] = HIRES_JPEG[540:1079,*]
newim[540:1079,*] = HIRES_JPEG[0:539,*]
HIRES_JPEG = fix(newim)
newim = 0


;-----------------------------------------------------------
; histogram
;-----------------------------------------------------------
; Nbins = 256
; hist = histogram(HIRES_JPEG,min=0,max=255,nbins=Nbins)
; plot, hist, xrange=[-5,260], yrange=[0,15000], xstyle=1, ystyle=1, thick=2.0, xtitle='pixel value', ytitle='number of pixels', title='histogram for pixel values', charsize=1.4, charthick=1.2
; stop

;-----------------------------------------------------------
; Remove gaps and bright patches
;-----------------------------------------------------------
; set_plot,'win'
; window,0,xpos=0,ypos=0,xsize=1082,ysize=542
; tv,HIRES_JPEG

; fill gaps
for ilat=0,540-1 do begin
  indx = where(HIRES_JPEG[*,ilat] GT 5,count)
  P        = [HIRES_JPEG[indx[count-1],ilat] , HIRES_JPEG[indx,ilat] , HIRES_JPEG[indx[0],ilat] ]
  ilon_xi  = [-1,indx,1080]
  ilon_gap = where(HIRES_JPEG[*,ilat] LE 5,count)
  if (count GT 0) then begin
    HIRES_JPEG[ilon_gap,ilat] = interpol(P,ilon_xi,ilon_gap)
  endif
endfor

; fill bright patches
for ilat=0,540-1 do begin
  indx = where(HIRES_JPEG[*,ilat] LE 175,count)
  P        = [HIRES_JPEG[indx[count-1],ilat] , HIRES_JPEG[indx,ilat] , HIRES_JPEG[indx[0],ilat] ]
  ilon_xi  = [-1,indx,1080]
  ilon_gap = where(HIRES_JPEG[*,ilat] GT 175,count)
  if (count GT 0) then begin
    HIRES_JPEG[ilon_gap,ilat] = interpol(P,ilon_xi,ilon_gap)
  endif
endfor

; indxLO = where(HIRES_JPEG LT 175,count)
; indxHI = where(HIRES_JPEG GE 175,count)
; HIRES_JPEG[indxLO] = 0
; HIRES_JPEG[indxHI] = 255

; window,1,xpos=0,ypos=560,xsize=1082,ysize=542
; tvscl,HIRES_JPEG

;-----------------------------------------------------------
; histogram
;-----------------------------------------------------------
; Nbins = 256
; hist = histogram(HIRES_JPEG,min=0,max=255,nbins=Nbins)
; plot, hist, xrange=[-5,260], yrange=[0,15000], xstyle=1, ystyle=1, thick=2.0, xtitle='pixel value', ytitle='number of pixels', title='histogram for pixel values', charsize=1.4, charthick=1.2
; stop

;-----------------------------------------------------------
; Convert pixel values into normalized reflectances.
; Use Mare Crisium and a highland feature as to correlate
; acording to Hillier et al. [1999]
; Plot a histogram.
;-----------------------------------------------------------
s = double(0.1188 - 0.0593)/(float(99)-float(46))
k = 0.0593d - s*float(46)
HIRES_JPEG_alb = s*double(HIRES_JPEG) + k

PVmin = s*0.0 + k + 0.00001
PVmax = s*255.0 + k + 0.00001
print,PVmin,PVmax
Nbins = 256
hist = histogram(HIRES_JPEG_alb,min=PVmin,max=PVmax,nbins=Nbins)
plot, s*findgen(Nbins)+k, hist, xrange=[s*0.0+k,s*255.0+k], yrange=[0,15000], xstyle=1, ystyle=1, thick=2.0, xtitle='normalized reflectivity', ytitle='number of pixels', title='distribution of normalized reflectivity', charsize=1.4, charthick=1.2
stop

;-----------------------------------------------------------
; Print normalized albedo to file.
;-----------------------------------------------------------
openw,1,strcompress(datadir+'/'+'HIRES_750_3ppd.alb',/remove_all)
for ilat=0,540-1 do begin
    printf,1,FORMAT='(F6.4,1079(1X,F6.4))', HIRES_JPEG_alb[*,ilat]
endfor
close,1


END
