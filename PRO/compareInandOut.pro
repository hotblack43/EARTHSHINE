file1='EX2_ideal_image_input_400x400_LONG.fit'
input=double(readfits(file1))
file2='Corrected_image_King_LONG.fit'
output=double(readfits(file2))
diff=(output-input)/input*100.0
dark_in=input(131:215,138:238)
dark_out=output(131:215,138:238)
bright_in=input(248:271,185:260)
bright_out=output(248:271,185:260)
DB_in=mean(dark_in)/mean(bright_in)
DB_out=mean(dark_out)/mean(bright_out)
print,'Input: dark/bright=',mean(dark_in)/mean(bright_in)
print,'Output: dark/bright=',mean(dark_out)/mean(bright_out)
print,'ratio of DB ratios:',DB_in/DB_out
print,'dark IN/OUT:',mean(dark_in)/mean(dark_out)
print,'bright IN/OUT',mean(bright_in)/mean(bright_out)
surface,congrid(diff,100,100),charsize=2,title='(O-I)/I*100'
;contour,congrid(diff,100,100),/isotropic,/cell_fill,nlevels=101,charsize=2,title='(O-I)/I*100'
; look at the last field subtracted
file3='Last_subtracted_image_LONG.fit'
subtracted=readfits(file3)
end