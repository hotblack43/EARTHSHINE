
PRO save_stuff,imin,im4,observed_image,cleaned_image,difference
common method,method_str
common fitedresults,P
common type,typeflag
common describstr,exp_str
common paths,path
; gaussian case
if (STRUPCASE(typeflag) eq "GAUSSIAN" and strupcase(method_str) ne 'LINEAR') then begin
MKHDR, header, difference
sxaddpar, header, 'Sigma', p(0), 'Convolved Gaussian cleanup'
sxaddpar, header, 'Factor', p(1), 'Convolved Gaussian cleanup'
endif
if (STRUPCASE(typeflag) eq "KING" and strupcase(method_str) ne 'LINEAR') then begin
; King profile case
MKHDR, header, difference
sxaddpar, header, 'Height', p(0), 'Convolved King Profile cleanup'
sxaddpar, header, 'Power', p(1), 'Convolved King Profile cleanup'
endif
if (strupcase(method_str) eq 'LINEAR') then begin
	MKHDR, header, difference
	sxaddpar, header, '', 0, 'BBSOs linear sky extrapolation used'
endif
;
WRITEFITS, strcompress(path+'Corrected_image_'+exp_str+'.fit',/remove_all), difference,header
WRITEFITS, strcompress(path+'Corrected_image_'+exp_str+'_LONG.fit',/remove_all), long(difference),header
return
end
