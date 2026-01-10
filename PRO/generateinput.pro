 PRO get_time,header,dectime
 ;
 idx=where(strpos(header, 'FRAME') eq 0)
 str='999'
 if (idx(0) ne -1) then str=header(idx)
 yy=fix(strmid(str,11,4))
 mm=fix(strmid(str,16,2))
 dd=fix(strmid(str,19,2))
 hh=fix(strmid(str,22,2))
 mi=fix(strmid(str,25,2))
 se=float(strmid(str,28,6))
 dectime=julday(mm,dd,yy,hh,mi,se)
 return
 end

; IDL code to generate input for the synthetic model for a particular JD
;
; get the observed image
im=readfits('findamodelforthisimage.fits',header)
; get the JD from the header
get_time,header,JD
; store that value in a file so that the synethetic program can read it
get_lun,wy
openw,wy,'JD_input.dat'
printf,wy,format='(f20.7)',JD
close,wy
free_lun,wy
end
