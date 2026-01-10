openw,66,'bad.data'
filename='bad_matrix.dat'
openr,1,filename
while not eof(1) do begin
readf,1,nX,nY
nX=fix(nX)
nY=fix(nY)
array=fltarr(nX,nY)
readf,1,array
print,' '
print,format='('+string(nX)+'f10.4)',array
; find zeros in rows and cols
nulls=fltarr(nY)
for irow=0,nY-1,1 do begin
row=reform(array(*,irow))
nulls(irow)=n_elements(where(row eq 0.0))
;print,'row ',irow,' has ',nulls(irow),' zeros'
endfor
maxbadrows=max(nulls)
print,'Max number of zero in a row:',maxbadrows
nulls=fltarr(nX)
for icol=0,nX-1,1 do begin
col=reform(array(icol,*))
nulls(icol)=n_elements(where(col eq 0.0))
;print,'col ',icol,' has ',nulls(icol),' zeros'
endfor
maxbadcols=max(nulls)
print,'Max number of zero in a col:',maxbadcols
print,maxbadrows*maxbadcols
printf,66,maxbadrows,maxbadcols
endwhile
close,1
close,66
;---------------------
openw,66,'good.data'
filename='good_matrix.dat'
openr,1,filename
while not eof(1) do begin
readf,1,nX,nY
nX=fix(nX)
nY=fix(nY)
array=fltarr(nX,nY)
readf,1,array
print,' '
print,format='('+string(nX)+'f10.4)',array
; find zeros in rows and cols
nulls=fltarr(nY)
for irow=0,nY-1,1 do begin
row=reform(array(*,irow))
nulls(irow)=n_elements(where(row eq 0.0))
;print,'row ',irow,' has ',nulls(irow),' zeros'
endfor
maxbadrows=max(nulls)
print,'Max number of zero in a row:',maxbadrows
nulls=fltarr(nX)
for icol=0,nX-1,1 do begin
col=reform(array(icol,*))
nulls(icol)=n_elements(where(col eq 0.0))
;print,'col ',icol,' has ',nulls(icol),' zeros'
endfor
maxbadcols=max(nulls)
print,'Max number of zero in a col:',maxbadcols
print,maxbadrows*maxbadcols
printf,66,maxbadrows,maxbadcols
endwhile
close,1
close,66
;
data_good=get_data('good.data')
data_bad=get_data('bad.data')
!P.MULTI=[0,1,2]
plot,data_good(0,*),data_good(1,*),xtitle='maxbadrows',ytitle='maxbadcols',title='Good',psym=7,xrange=[0,9],yrange=[0,6]
plot,data_bad(0,*),data_bad(1,*),xtitle='maxbadrows',ytitle='maxbadcols',title='Bad' ,psym=7,xrange=[0,9],yrange=[0,6]
end