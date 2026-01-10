PRO setup_pointer,pointer,C,n_unknown_in
l=size(C,/dimensions)
nX=l(0)
nY=l(1)
success=0
colsuccess=0
rowsuccess=0
while (success eq 0) do begin

ratio=float(n_unknown_in)/float(n_elements(C))
pointer=randomu(seed,nX,nY)
idx=where(pointer lt ratio)
jdx=where(pointer ge ratio)
pointer(idx)=0.0
pointer(jdx)=1.0
; check

nulls=fltarr(nY)
for irow=0,nY-1,1 do begin
row=reform(pointer(*,irow))
nulls(irow)=n_elements(where(row eq 0.0))
endfor
maxbadrows=max(nulls)
if (maxbadrows lt nX) then rowsuccess=1
print,'Max number of zero in a row:',maxbadrows
nulls=fltarr(nX)
for icol=0,nX-1,1 do begin
col=reform(pointer(icol,*))
nulls(icol)=n_elements(where(col eq 0.0))
endfor
maxbadcols=max(nulls)
if (maxbadcols lt nY) then colsuccess=1
print,'Max number of zero in a col:',maxbadcols
success=colsuccess*rowsuccess
print,fix(pointer)
endwhile
n_unknown_in=n_elements(where(pointer eq 0))
     return
     end


 PRO get_data_for_matrix,fname,C
 common stuff12,meanC,Corig,C_STD
 common flagstuff,region_indicator
 Corig=get_data(fname)
 meanC=mean(Corig)
 C_STD=stddev(Corig)	; realistic rnd numbers
 C_STD=0.0	; climatology
 C=Corig-meanC
; special
if (fname eq 'matrixERAandGCM.dat') then begin
 Corig=get_data(fname)
 col_start=2*(region_indicator-1)
 col_stop=2*(region_indicator-1)+1
 print,region_indicator,col_start,col_stop
 Corig=Corig(col_start:col_stop,*)
 meanC=mean(Corig)
 C=Corig-meanC
endif
 return
 end

 FUNCTION GCMxRCM, X, Y, P
 ;-----------------------------------------------------
 ; function used by MPFIT2DFUN - designates the value to be minimized
 ; For use with 'fill_RCM_GCM_matrix_v3.pro'
 ; Peter Thejll Nov 20, 2008
 ;-----------------------------------------------------
 ; X,Y	: (INPUT) dummies of the right sizes
 ;
 ; P	: (INPUT) guess at the values to be determined
 ;                 the values of X and Y and any additional weights will be
 ;                 packaged after one another at the end of P
 ; GCMxRCM : (OUTPUT) the value to be minimized (a sum over pixels om
 ;		 the rim of the circle in the difference image
 ;-----------------------------------------------------
 ;
 common stuff,C,nX,nY,pointer,idx
 ; find the positions that are not empty
 use=array_indices(C,idx)
 l=size(use,/dimensions)
 x_vec=P(0:nX-1)
 y_vec=P(nX:nX+nY-1)
 factor=P(nX+nY)

 sum=0.0
 for i=0,l(1)-1,1 do begin
     sum=sum+(C(use(0,i),use(1,i)) - x_vec(use(0,i))*y_vec(use(1,i)))^2
     ;	print,i,C(use(0,i),use(1,i)),x_vec(use(0,i)),y_vec(use(1,i))
     endfor
 ;--------------------------------
 ;part1=sqrt(sum)/float(l(1))
 ;part2=(factor-total(x_vec^2))^2*10.0
 ;print,part1,part2
 ;sum=part1+part2
 ;--------------------------------
 ;part1=sqrt(sum)/float(l(1))
 ;sum=part1
 ;--------------------------------
 return, sum
 END

 ; Test code for 'filling the matrix' using least squares to solve for vectors
 ; this version uses PDF skill scores as the matrix value
 ; and regions as one dimension and RCM/GCM pairs as the other dimension
 common stuff,C,nX,nY,pointer,idx
 common stuff12,meanC,Corig,C_STD
 common flagstuff,region_indicator
 file_delete,'bad_matrix.dat',/QUIET
  file_delete,'good_matrix.dat',/QUIET
 ; fetch the known matrix in C
;get_data_for_matrix,'C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\matrix.in',C
get_data_for_matrix,'C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\matrixERA.in',C
;get_data_for_matrix,'matrixR1.dat',C
 region_indicator=1	; 1,2,3,4,5,6,7,8 are possible
openw,78,'C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\regionindicator.txt'
printf,78,strcompress('Region '+string(region_indicator))
close,78
;get_data_for_matrix,'C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\matrixERAandGCM.dat',C
 nMC=50
 openw,55,'X.dat'
 openw,56,'Y.dat'
 openw,44,'results_2.dat'
 for iMC=0,nMC,1 do begin
     l=size(C,/dimensions)
     nX=l(0)
     nY=l(1)
     ; and then pretend some are not known
     pointer=C*0+1
     n_unknown=nX*nY/2.
     setup_pointer,pointer,C,n_unknown

     idx=where(pointer ne 0)
     meanCnotzer=mean(Corig(where(pointer ne 0)))
     ; set up P
     ;p=[randomn(seed,nX),randomn(seed,nY),1.0d0]	; P is just three lists of the X and Y values and the 'factor'
     p=[indgen(nX+nY+1)*0+0.5]	; P is just three lists of the X and Y values and the 'factor'

     ; Use MPFIT2DFUN to get even better positions ...
     start_parms=P
     XR=findgen(nX)
     YC=findgen(nY)
     XX = XR # (YC*0 + 1)        ;     eqn. 1
     YY = (XR*0 + 1) # YC        ;     eqn. 2
     z=C
     err=z*9.9
	maxiter=1000
     ; set up the PARINFO array - indicate double-sided derivatives (best)
     parinfo = replicate({fixed:0, mpside:0, value:0.D, limited:[0,0], limits:[0.D,0]}, nX+nY+1)
     parinfo[*].mpside= 2
     parinfo[*].limited(0) = 0
     parinfo[*].limited(1) = 0
     parinfo[*].limits(0)  = 0.0
     parinfo[*].limits(1)  = 1.0
     parinfo[*].value = [start_parms]
     parinfo[nX+nY].fixed= 1
     myfunct_name='GCMxRCM'
     result = MPFIT2DFUN(myfunct_name, XX, YY, Z, ERR, start_parms, $
     PARINFO=parinfo,perror=sigs,status=status,/QUIET,             $
     MAXITER=maxiter,niter=niter,FTOL=1e-6)
     print,'STATUS=',status,' NITER=',niter
	if (status eq 1 and niter ne maxiter) then begin
     ; extract the vectors
     guessed_X=result(0:nX-1)
     guessed_Y=result(nX:nX+nY-1)
     print,format='('+string(nX)+'f10.4,1x)',(Corig-(guessed_x#guessed_y+meanCnotzer))/Corig
     print,'RMSE per RCM/GCM pair:',sqrt(total(((Corig-(guessed_x#guessed_y+meanCnotzer))/Corig)^2))/nX/nY*100,'%'
     print,'factor: ',result(n_elements(result)-1)
     ;
     jdx=where(pointer eq 0)
     use=array_indices(C,jdx)
     sum=0.0
     sum_rnd=0.0
     for i=0,n_elements(jdx)-1,1 do begin
         diff=Corig(use(0,i),use(1,i)) - (guessed_X(use(0,i))*guessed_Y(use(1,i))+meanCnotzer)
         diff_rnd=Corig(use(0,i),use(1,i)) - (randomn(seed)*C_STD+meanCnotzer)	; guess a random number
         rel_diff=diff/Corig(use(0,i),use(1,i))
         rel_diff_rnd=diff_rnd/Corig(use(0,i),use(1,i))
         rel_diff_pct=rel_diff*100.0
         rel_diff_rnd_pct=rel_diff_rnd*100.0
         sum=sum+rel_diff_pct^2
         sum_rnd=sum_rnd+rel_diff_rnd_pct^2
         endfor
     print,'RMSE for withheld elements using LS method:       ',sqrt(sum)/n_elements(jdx),' in pct.'
     print,'RMSE for withheld elements using suitable rnd nos:',sqrt(sum_rnd)/n_elements(jdx),' in pct.'
     con=cond(c*pointer,lnorm=2,/DOUBLE)
     print,'Condition number of matrix:',con
     if (sqrt(sum)/n_elements(jdx) gt sqrt(sum_rnd)/n_elements(jdx)) then begin
     openw,88,'bad_matrix.dat',/append
      printf,88,nX,nY
     printf,88,format='('+string(nX)+'f10.4)',C*pointer
     close,88
    	endif
    	if (sqrt(sum)/n_elements(jdx) le sqrt(sum_rnd)/n_elements(jdx)) then begin
     openw,88,'good_matrix.dat',/append
      printf,88,nX,nY
     printf,88,format='('+string(nX)+'f10.4)',C*pointer
     close,88
    	endif
     print,'Set ',n_unknown,' as unkown matrix values.'
     x_vec=result(0:nX-1)
     y_vec=result(nX:nX+nY-1)
     ; normalize X and scale Y accordingly
     length=sqrt(total(x_vec^2))
     x_vec=x_vec/length
     y_vec=y_vec*length
     ;
     print,format='(a,'+string(nX)+'f10.4)','Guessed X:',x_vec
     print,format='(a,'+string(nY)+'f10.4)','Guessed Y:',Y_vec
     printf,55,format='('+string(nX)+'f10.4)',x_vec
     printf,56,format='('+string(nY)+'f10.4)',Y_vec
     printf,44,format='(7(1x,f10.4))',sqrt(sum)/n_elements(jdx),result(n_elements(result)-1),status,total(x_vec^2),total(y_vec^2),sqrt(sum_rnd)/n_elements(jdx),con
	endif	; status if
     endfor	; end of MC loop
 close,44
 close,55
 close,56
 end
