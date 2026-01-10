modeltype=1
file=strcompress('regression_results_Model'+string(modeltype)+'.dat',/remove_all)
 ncoeffs=2
 nplots=ncoeffs+2	; that is, read the coefficients plus an intercept and the RMSE each time
 block=fltarr(2,nplots)
 openr,1,file
 count=0
 while not eof(1) do begin
     readf,1,block
     ; split the block into values and errors
     if (count eq 0) then begin
         values=transpose(block(0,*))
         errors=transpose(block(1,*))
         endif
     if (count gt 0) then begin
         values=[[values],[transpose(block(0,*))]]
         errors=[[errors],[transpose(block(1,*))]]
         endif
     count=count+1
     endwhile
 close,1
 ; plotter section
l=size(values,/dimensions)
print,l 
 !P.MULTI=[0,1,4]
 !P.CHARSIZE=2
 !P.thick=2
 !x.thick=2
 !y.thick=2
if (modeltype eq 1) then ytits=['Intercept','Coeff to SAL','Coeff to CFC','RMSE']	; Model 1
if (modeltype eq 2) then ytits=['Intercept','Coeff to SAL*(1-CFC)','Coeff to CFC','RMSE']	; Model 2
 imo=indgen(l(1))+5
; plot modulu 12
for k=0,nplots-1,1 do begin
	plot,imo mod 12,values(k,*),ytitle=ytits(k),xtitle='Month number',title=file,psym=4
 	if (k eq 1 or k eq 2) then oploterr,imo mod 12,values(k,*),errors(k,*)
endfor
stop
for k=0,nplots-1,1 do begin
	plot,imo,reform(values(k,*)),ytitle=ytits(k),xtitle='Month number',title=file
 	if (k eq 1 or k eq 2) then oploterr,imo,reform(values(k,*)),reform(errors(k,*))
endfor
 end
