PRO generate_many_unconvolved_lunar_images
n_images = 500
for i=0,n_images-1,1 do begin
	a = 2455840.8793623d0
	JD = a + 365 * RANDOMU(seed,/double)
	albedo = RANDOMU(seed,/double)*0.5d0+0.1d0
        print,a,JD,albedo
	openw,44,'JDtouseforSYNTH'
	printf,44,format='(f15.7)',JD
	close,44
	openw,44,'single_scattering_albedo.dat'
	printf,44,format='(f15.7)',albedo
	close,44
;
;	str='idl go_get_particular_synthimage_16_for_ML.pro'
	str='gdl go_get_particular_synthimage_16_for_ML.pro'
	spawn,str
endfor
end 
