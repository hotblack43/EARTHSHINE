PRO getIearth,header,Iearth
 ipos=where(strpos(header,'IEARTH') ne -1)
 date_str=strmid(header(ipos),11,21)
 dummy=float(date_str)
Iearth=dummy(0)
return
end

PRO getthestepandthesignatures,im,leftside,rightside,DSstep,stddevDSstep,sig1,SDsig1,BSstep,stddevBSstep,sig2,SDsig2
;.......................................................
;.......................................................
; find the size of the Laplacian signature
lap=laplacian(im)
w=9	; width of window on a line
noff=5	; half-number of lines to coadd
ic=0
for iline=256-noff,256+noff,1 do begin
;..................
; find step on DS and BS of the original synthetic image
; first method: evaluate step size at actual edge pixel
;DSstep=max(im(leftside-w:leftside+w,iline))-min(im(leftside-w:leftside+w,iline))
;BSstep=max(im(rightside-w:rightside+w,iline))-min(im(rightside-w:rightside+w,iline))
; other method; evaluate step size from mean of before and after
DSstep=abs(mean(im(leftside-w:leftside-1,iline))-mean(im(leftside+1:leftside+w,iline)))
BSstep=abs(mean(im(rightside-w:rightside-1,iline))-mean(im(rightside+1:rightside+w,iline)))
;..................
; find the Laplacian signatures in the
line=reform(lap(*,iline))
sig1=(max(line(leftside-w:leftside+w))-min(line(leftside-w:leftside+w)))/2.
sig2=(max(line(rightside-w:rightside+w))-min(line(rightside-w:rightside+w)))/2.
if (ic eq 0) then begin
sig1sum=sig1
sig2sum=sig2
DSstepsum=DSstep
BSstepsum=BSstep
endif else begin
sig1sum=[sig1sum,sig1]
sig2sum=[sig2sum,sig2]
DSstepsum=[DSstepsum,DSstep]
BSstepsum=[BSstepsum,BSstep]
endelse
ic=ic+1
endfor
sig1=mean(sig1sum)
SDsig1=stddev(sig1sum)
sig2=mean(sig2sum)
SDsig2=stddev(sig2sum)
DSstep=mean(DSstepsum)
BSstep=mean(BSstepsum)
stddevDSstep=stddev(DSstepsum)
stddevBSstep=stddev(BSstepsum)
print,DSstepsum
print,BSstepsum
; switch order on DS and BS if needed
if (DSstep lt BSstep) then begin
; do nothing
endif else begin
; swap
swap=DSstep
DSstep=BSstep
BSstep=swap
swap=stddevDSstep
stddevDSstep=stddevBSstep
stddevBSstep=swap
swap=sig1
sig1=sig2
sig2=swap
swap=SDsig1
SDsig1=SDsig2
SDsig2=swap
endelse
print,'Step DS: ',DSstep,' +/- ',stddevDSstep
print,'Step BS: ',BSstep,' +/- ',stddevBSstep
print,'Signature DS : ',sig1,' +/- ',SDsig1
print,'Signature BS : ',sig2,' +/- ',SDsig2
return
end



files=file_search('OUTPUT/LunarIm*',count=n)
print,'Found ',n,' images.'
openw,3,'steps_alfa1p8_100ims_sum11rows.dat'
for i=0,n-1,1 do begin
im=readfits(files(i),header)
getIearth,header,Iearth
writefits,'usethis.fits',im,header
rannum=randomu(seed)*10000L
str='./syntheticmoon usethis.fits out.fits 1.8 100 '+string(fix(rannum))
spawn,str
im=readfits('out.fits')
;............................
leftside=117
rightside=395
getthestepandthesignatures,im,leftside,rightside,DSstep,stddevDSstep,sig1,SDsig1,BSstep,stddevBSstep,sig2,SDsig2
;............................
fmt='(9(1x,g20.13))'
printf,3,format=fmt,Iearth,DSstep,stddevDSstep,sig1,SDsig1,BSstep,stddevBSstep,sig2,SDsig2
endfor
close,3
print,'Now use plot_testLaplacianidelaimages.pro to plot the results'
end
