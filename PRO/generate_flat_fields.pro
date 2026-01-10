PRO generatename,flatname,newname
 newname=strcompress('FLATFIELDS/N1_'+flatname,/remove_all)
 return
 end
 
 path='/media/SAMSUNG/SCIENCEPROJECTS/MOONDROPBOX/JD2455836/'
 list='allFLATfiles3'	; this is the MASTER list of alternating DARKLS and FLATS - starting with a DARK and ending with a DARK
 ic=0
 openr,1,list
 dark1name='' & flatname='' & dark2name=''
 while not eof(1) do begin
     if (ic eq 0) then begin
         readf,1,dark1name
         readf,1,flatname
         readf,1,dark2name
         endif
     if (ic gt 0 and not eof(1)) then begin
         dark1name=dark2name
         readf,1,flatname
         readf,1,dark2name
         endif
	print,ic
     print,'WANT: ',dark1name
     print,'WANT: ',flatname
     print,'WANT: ',dark2name
     dark1=readfits(strcompress(path+dark1name,/remove_all),hd1,/sil)
     flat=readfits(strcompress(path+flatname,/remove_all),f,/sil)
     dark2=readfits(strcompress(path+dark2name,/remove_all),hd2,/sil)
; check that files are FINITE
	if (where(finite(dark1) ne 1) ne -1) then stop
	if (where(finite(flat) ne 1) ne -1) then stop
	if (where(finite(dark2) ne 1) ne -1) then stop
	if (mean(flat) gt 10000 and mean(flat) le 56000) then begin
     dark=(dark1+dark2)/2.0d0
     flat=flat-dark
     flat=flat/mean(flat,/NaN)
     generatename,flatname,newname
     sxaddpar, f, 'COMMENT','Dark frames subtracted'
     writefits,newname,flat,f
	endif
     ic=ic+1
     endwhile
 close,1
 end
