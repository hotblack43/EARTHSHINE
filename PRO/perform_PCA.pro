PRO goprint,PCvsDATAcorrs,data,pc,varnames,nvars
 print,'--------------------------------'
 for ipc=0,nvars-1,1 do begin;
     for k=0,nvars-1,1 do print,format='(a8,i2,a3,a7,a4,f9.4)','R (PC # ',k,' , ',varnames(ipc),') = ',correlate(pc(ipc,*),data(k,*),/double)
     print,'--------------------------------'
     endfor
 return
 end
 
 
 !P.CHARSIZE=1.0
 str=''
 openr,1,'nameoffile.txt'
 readf,1,str
 close,1
 data_in=get_data('all_data')
 names=['B','V','VE1','VE2','IRCUT']
 cnam=['blue','green','orange','brown','red']
 id=names(data_in(15,*))
 data=data_in([1,3,5,14],*)
 varnames=['Albedo','alfa','pedestal','flux']
 ; JD,albedo,erralbedo,alfa1,rlimit,pedestal,xshift,yshift,corefactor,contrast,RMSE,totfl,zodi,SLcounts,flux
 ;  0   1       2        3     4      5       6      7        8         9       10   11   12    13       14
 l=size(data,/dimensions)
 nvars=l(0)
 nobs=l(1)
 
 if_want_center=1
 if_want_stdize=1
 ; across all observations do centering or standardization of each variable
 if (if_want_center eq 1) then for ivar=0,nvars-1,1 do data(ivar,*)=data(ivar,*)-mean(data(ivar,*),/double)
 if (if_want_stdize eq 1) then for ivar=0,nvars-1,1 do data(ivar,*)=data(ivar,*)/stddev(data(ivar,*),/double)
 ;
 ; Compute the Singular Value Decomposition:
 SVDC, data, W, pc, eof
 help,data, W, pc, eof
 ; Print the singular values:
 totsing=total(w)
 PRINT,format='(a,'+string(nvars)+'(1x,f9.6),a)', 'Sing val: ',W/totsing*100.,' % of var.'
 
; Reconstruct the input data med havelåger
;sv = FLTARR(nvars, nvars)
;FOR K = 0, nvars-1 DO sv[K,K] = W[K]
;result = pc ## sv ## TRANSPOSE(eof)
; Must look at result!

 !P.MULTI=[0,3,2]
 !P.charsize=1.9
 ;plot,xstyle=3,ystyle=3,total(w/totsing,/cum)*100,title=str,ytitle='Cumulated var explained',xtitle='EOF #',psym=7
 
 print,'----------------------------------------'
 for iPC=0,3,1 do begin
     for k=0,n_elements(varnames)-1,1 do print,'R PC#',ipc,' vs variable ',varnames(k),': ',correlate(pc(ipc,*),data(k,*))
	print,'----------------------------------------'
     for jPC=ipc+1,3,1 do begin
         plot,/nodata,/isotropic,pc(ipc,*),pc(jpc,*),xtitle='PC'+string(iPC),ytitle='PC'+string(jPC),psym=7,xstyle=3,ystyle=3
         for iobs=0,nobs-1,1 do xyouts,pc(iPC,iobs),pc(JPC,iobs),id(iobs),color=fsc_color(cnam(data_in(15,iobs)))
         endfor
     endfor
; also regress data against PCs
print,'varnams:',varnames
nPCmax=2
	print,'================================='
for k=0,n_elements(varnames)-1,1 do begin
print,nPCmax,' PCs as regressors, ',varnames(k),' as (standardized) regressand:'
res=regress(reform(pc(0:nPCmax-1,*)),reform(data(k,*)),/double,yfit=yhat,sigma=sigs,status=sta)
print,'Status: ',sta
print,'R: ',correlate(yhat,reform(data(k,*)))
for l=0,nPCmax-1,1 do print,res(l),strcompress(' *PC#'+string(l)),' +/- ',sigs(l)
	print,'================================='
endfor
 end
