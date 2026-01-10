; Read in data in an array with 2 columns and nframes rows
; First column is number of bias frames
; Second column is the standard deviation
data_512 = FLTARR(2,120) ; Create the data array
data_256 = FLTARR(2,120)
data_128 = FLTARR(2,120)
OPENR, 11, 'std_512.dat' ; Open datafile for reading
OPENR, 12, 'std_256.dat'
OPENR, 13, 'std_128.dat' 
READF, 11, data_512 ; Read data from file
READF, 12, data_256
READF, 13, data_128
CLOSE, 11 ; Close the file
CLOSE, 12
CLOSE, 13

; Plot the standard deviation as function of number of biasframes
PLOT_OO, data_512(0,*), data_512(1,*), PSYM = 2, $
  TITLE = 'Stdev as function of number of bias frames', $
  XTITLE = 'N', $
  YTITLE = '!7r !3', $
  CHARSIZE = 2

OPLOT, data_256(0,*), data_256(1,*), PSYM = 1
OPLOT, data_128(0,*), data_128(1,*), PSYM = 4

;SAVEIMAGE, 'std_512_256_128.gif'

end