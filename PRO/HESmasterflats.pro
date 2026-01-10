; Program der skaber master_flats fra good_mean_flats_X.txt filer

;----------------------------------------------------------------------------
; Nødvendigt input til programmet:
; Filerne good_mean_flats_X.txt og darks_X.txt skal være 
; tilstede i mappen for natten XXX.

; Dialogboks, hvor brugeren manuelt indtaster natten XXX,
; de sidste tre cifre i den Julianske dato.
;nat = DIALOG(/STRING, VALUE='XXX', 'Hvilken nat?')
nat = '999'
;----------------------------------------------------------------------------

; Access the superbias
superbias = double(READFITS('~/SCIENCEPROJECTS/EARTHSHINE/superbias.fits'))

; Skab korrekte filstier som string-arrays
;filsti_flat = [nat + '/good_mean_flats_B.txt', $
;  nat + '/good_mean_flats_V.txt', $
;  nat + '/good_mean_flats_VE1.txt', $
;  nat + '/good_mean_flats_VE2.txt', $
;  nat + '/good_mean_flats_IRCUT.txt']
;filsti_dark = [nat + '/darks_B.txt', $
;  nat + '/darks_V.txt', $
;  nat + '/darks_VE1.txt', $
;  nat + '/darks_VE2.txt', $
;  nat + '/darks_IRCUT.txt']
;filsti_master = [nat + '/master_B.fits', $
;  nat + '/master_V.fits', $
;  nat + '/master_VE1.fits', $
;  nat + '/master_VE2.fits', $
;  nat + '/master_IRCUT.fits']
;filsti_1 = nat + '/good_mean_flats_B.txt'
;filsti_2 = nat + '/darks_B.txt'
filsti_master = nat + '/master_V.fits'
filsti_flat = '/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455999/2455999.9029300LAMP_FLAT_V_AIR.fits'
filsti_dark1 = '/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455999/2455999.9020220DARK_DARK0P01S.fits'
filsti_dark2 = '/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455999/2455999.9030378DARK_DARK0P01S.fits'

dark1 = double(READFITS(filsti_dark1))
dark2 = double(READFITS(filsti_dark2))
dark = [[[dark1]],[[dark2]]]
flat = double(READFITS(filsti_flat))

; Scale superbias using the appropriate darks 
scaled_superbias = superbias * (AVG(dark)/AVG(superbias))

; Loop to go through each filter
;for filter = 0,4,1 do begin

for i = 0,19,1 do begin
  
    ; Subtract scaled superbias from flatfield
    flat[*,*,i] = flat[*,*,i] - scaled_superbias

    ; Remove gradient
    fit_flat = SFIT(flat[*,*,i],2)
    SURFACE, fit_flat, CHARSIZE = 2

    ; Normalize bias-subtracted flatfield
    flat[*,*,i] = (flat[*,*,i] - fit_flat + AVG(fit_flat)) / AVG(flat[*,*,i] - fit_flat + AVG(fit_flat))
    SURFACE, flat[*,*,i], CHARSIZE = 2

endfor

n_flats = 19

  ;----------------------------------------------------------------------------------
  ;--------------Create masterflat from flat_norm_cube-------------------------------
  ;----------------------------------------------------------------------------------

    
    ; Create empty array for the masterflat
    master_flat = FLTARR(512,512)
    sigma = FLTARR(512,512)

    for i = 0, 511, 1 do begin
      for j = 0, 511, 1 do begin
    
	; Create nframes vector for each pixel in order to sort
	x = flat(i,j,0:n_flats-1)
   
	; Sort values in pixel-vector x
	y = x(SORT(x))

	; Select the half median values
	y = y(n_flats*0.25:n_flats*0.75)

	; Find the mean pixel value and standard error 
	z = AVG(y)
	sd = STDDEV(y)

	; Allocate the mean pixel value to the small superbias
	master_flat(i,j) = z
	sigma(i,j) = sd

      endfor
    endfor 

    ;fits_write, filsti_master[filter], master_flat
    writefits, 'HES.flat', master_flat



END
