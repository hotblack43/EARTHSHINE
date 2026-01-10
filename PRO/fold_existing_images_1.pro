PRO go_get_JD_albedo_illfrac,filname,im,header,JD,albedo,illfrac
im=readfits(filname,header)
idx = WHERE(strpos(header, 'ALBEDO') NE -1, count)
albedo=strmid(header[idx],15,16)*1.0d0
idx = WHERE(strpos(header, 'JULIAN') NE -1, count)
JD=strmid(header[idx],15,16)*1.0d0
parts = strsplit(filname,'_',/extract) 
idx = where(parts eq 'illfrac')
illfrac = parts[idx+1]
return
end 

;---------------------------------------------------------
; Code to convolve generated realistic lunar images.
;---------------------------------------------------------
corefactor = 2
rlimit = 9
; build a list of all the images we want to convolve with a PSF
files=file_search('/media/pth/SSD2/SYNTHETIC_MOONIMAGES/UNFOLDED_UNNOISY/AUGMENTED/ideal*.fit')
Nfiles=n_elements(files)
for ifile=1,Nfiles,1 do begin
; get JD and albedo and illfrac from filename or the FITS header itself
                go_get_JD_albedo_illfrac,files(ifile),im1,header,JD,albedo,illfrac
        if illfrac LT 0.6 then begin
		writefits,'mixed117.fits',im1,header
        	alfa1 = randomu(seed)*0.2+1.7
 		str='./justconvolve_scwc mixed117.fits trialout117.fits '+string(alfa1)+' '+string(corefactor)+' '+string(rlimit)
 		spawn,str
 		folded=readfits('trialout117.fits')
        	actual_max = max(folded)
 		folded = folded/actual_max*50000.0d0
                outname=strcompress('/media/pth/SSD2/SYNTHETIC_MOONIMAGES/UNFOLDED_UNNOISY/AUGMENTED/FOLDED/folded_'+string(albedo)+'_'+string(illfrac)+'_.fits',/remove_all)
                print,'Writing : ',outname
		writefits,outname,folded,header
	endif
endfor
end

