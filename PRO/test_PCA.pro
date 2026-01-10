 
 im=double(readfits('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2456015/2456015.8108611MOON_VE1_AIR.fits.gz'))
 for pwr=5L,6L,1L do begin
     n=2LL^pwr
     im2=rebin(im,n,n,100) 
     data=reform(im2,n*n,100)
     l=size(data,/dimensions)
     nvars=l(0)
     nvars_str=string(nvars,format='(i)')
     nobs=l(1)
     nobs_str=string(nobs,format='(i)')
     openw,1,'PCA_data.txt'
	fmt_str_nvars=strcompress('('+nvars_str+'(1x,f11.4))',/remove_all)
	fmt_str_nobs=strcompress('('+nobs_str+'(1x,f11.4))',/remove_all)
     for l=0,nobs-1,1 do printf,1,format=fmt_str_nvars,data(*,l)
     close,1
     t1=systime(/UTC,/JULIAN)
     SVDC, data, W, pc_mat, eof_mat
	openw,1,'PCA_W.txt'
	printf,1,format=fmt_str_nvars,w
	close,1
	openw,1,'PCA_PC.txt'
	for l=0,nobs-1,1 do printf,1,format=fmt_str_nvars,pc_mat(*,l)
	close,1
	openw,1,'PCA_EOF.txt'
	for l=0,nvars-1,1 do printf,1,format=fmt_str_nvars,eof_mat(*,l)
	close,1
	writefits,'PCA_EOF.fits',eof_mat
     ; Print the singular values:
     totsing=total(w)
     PRINT,format='(a,'+string(nvars)+'(1x,f9.6),a)', 'Sing val: ',W/totsing*100.,' % of var.'
     ; Reconstruct the input data med havelåger
     sv = FLTARR(nvars, nvars)
     FOR K = 0, nvars-1 DO sv[K,K] = W[K]
     result = pc_mat ## sv ## TRANSPOSE(eof_mat)
     print,'DATA - RECONSTRUCTION:'
     PRINT,format='('+string(nvars)+'(1x,f9.6))', data-result
     t2=systime(/UTC,/JULIAN)
     print,pwr,n,(t2-t1)*24.*60.,' minutes'
     endfor
 end
