PRO get_photometric_ratio,image,ratio
common boxes,x1,x2,x3,x4,y1,y2,y3,y4
patch1=mean(image(x1:x2,y1:y2))
patch2=mean(image(x3:x4,y3:y4))
ratio=patch1/patch2	; for linear images
;print,patch1,patch2,ratio
return
end

PRO get_im_phase,filename,im,phase
;print,filename
		im=readfits(filename,header)
		  jd=double(strmid(header(8),16,32-16))
;		  MPHASE,jd, phase
                  phase=double(strmid(header(9),16,32-16))
return
end


CPU, TPOOL_MIN_ELTS=10000, TPOOL_NTHREADS=2
 common stuff,FFTideal,observed,ideal,maxerr,n,llim,rrlim,dlim,ulim,tstr,x0,y0,radius,mask,r,header
 common flags,iflag,iflag2
common boxes,x1,x2,x3,x4,y1,y2,y3,y4
 iflag=-911
 ; read in the image to be corrected
 ; get the observed file names
 path='OUTPUT/IDEAL/'
 observednames=file_search(path+'Observed_*.fit',count=n1)
 onames=strmid(observednames(*),strlen(observednames(2))-18,100)
 InSpacenames=file_search(path+'InSpace_*.fit',count=n2)
 inames=strmid(InSpacenames(*),strlen(InSpacenames(2))-17,100)
 if (n1 ne n2) then stop
     k=0.0031	; set empirically!
openw,23,'message.txt'
printf,23,'Padding, and K='+string(k)
close,23
 for ifile=0,n1-1,1 do begin
     observed=readfits(path+onames(ifile),header)
     phase=double(strmid(header(9),16,32-16))
     sxaddpar, header, 'MPHASE', phase, 'Lunar PHase (S:M:E)'
     l=size(observed,/dimensions)
     if (l(0) ne l(1)) then stop
     n=l(0)
     tstr='WholeSkyPOISSON'
     ; read in the 'ideal image' as seen in spave without a distoring telescope
     ideal=readfits(path+inames(ifile))
     ;
     ;////////////////////////////////////////////
     ; do the blind deconvolution
     ideal=go_pad_image(ideal)
	writefits,'ideal_padded.fit',ideal
     observed=go_pad_image(observed)
	writefits,'observed_padded.fit',observed
     blind,ideal,observed,correctedim,k
     correctedim=go_unpad(correctedim)
     writefits,'modelofobservation.fit',observed,header
     writefits,'cleaned.fit',correctedim,header
     scattered=observed-correctedim
     writefits,'scattered.fit',scattered,header
     ;////////////////////////////////////////////
     ; move the generated files
     filenameending=strmid(onames(ifile),strlen(onames(ifile))-9,20)
     outname=strcompress(path+'ModelObserved_'+filenameending,/remove_all)
     file_move,'modelofobservation.fit',outname,/overwrite
     outname=strcompress(path+'Cleaned_'+filenameending,/remove_all)
     file_move,'cleaned.fit',outname,/overwrite
     outname=strcompress(path+'Scattered_'+filenameending,/remove_all)
     file_move,'scattered.fit',outname,/overwrite
     endfor	; ifile loop
; now extract photometry
;=====================================================================================
; code to extract photometric information from images of the Moon
;width=4
;x1=85-width & x2=85+width & x3=440-width & x4=440+width 
;y1=254-width & y2=254+width & y3=257-width & y4=257+width ; suitable for centered 512x512 image
x1=123 & x2=126 & y1=241 & y2=271
x3=388 & x4=391 & y3=237 & y4=278
;
openw,5,'DSBS_ratio.dat'
;-----------------------
path='OUTPUT/IDEAL/'
InSpacefiles=file_search(path+'InSpace_*.fit',count=nfiles1)
Observefiles=file_search(path+'Observed_*.fit',count=nfiles2)
Cleanedfiles=file_search(path+'Cleaned_*.fit',count=nfiles3)
BBSOfiles=file_search(path+'BBSO_cleaned_*.fit',count=nfiles4)
if ((nfiles1 ne nfiles2) or (nfiles1 ne nfiles3 or (nfiles1 ne nfiles4))) then stop
nfiles=nfiles1 ; (say)
;-------------
; set a pedestal to remove from ALL images
for ifile=0,nfiles-1,1 do begin
print,'----------------------------------------------------------------'
	get_im_phase,InSpacefiles(ifile),im,phase
	get_photometric_ratio,im,ratio_InSpace

	get_im_phase,Observefiles(ifile),im,dummy
	get_photometric_ratio,im,ratio_Observed

	get_im_phase,Cleanedfiles(ifile),im,dummy
	get_photometric_ratio,im,ratio_Cleaned

	get_im_phase,BBSOfiles(ifile),im,dummy
	get_photometric_ratio,im,ratio_BBSO

	print,phase,ratio_InSpace,ratio_Observed,ratio_Cleaned,ratio_BBSO
	printf,5,phase,ratio_InSpace,ratio_Observed,ratio_Cleaned,ratio_BBSO
endfor
close,5
; and the plot the results
file='DSBS_ratio.dat'
data=get_data(file)
phase=reform(data(0,*))
ratio_InSpace=reform(data(1,*))
ratio_Observed=reform(data(2,*))
ratio_Cleaned=reform(data(3,*))
ratio_BBSO=reform(data(4,*))
set_plot,'ps
device,/landscape,/color
!P.CHARSIZE=1.3
!P.THICK=2
!x.THICK=2
!y.THICK=2
idx=where(phase gt 0)
openr,23,'message.txt'
str=''
readf,23,str
close,23
plot_io,phase(idx),ratio_InSpace(idx),title='Space: Plus, Observed:diamonds, Cleaned: triangles, BBSO:squares',psym=1,xtitle='Lunar Phase angle (S-M-E)',ytitle='BS/DS',yrange=[1,1e6],subtitle=str
oplot,phase(idx),ratio_InSpace(idx),psym=1,color=fsc_color('red')
oplot,phase(idx),ratio_Observed(idx),psym=4,color=fsc_color('red')
oplot,phase(idx),ratio_Cleaned(idx),psym=5,color=fsc_color('red')
oplot,phase(idx),ratio_BBSO(idx),psym=6,color=fsc_color('red')
idx=where(phase le 0)
oplot,abs(phase(idx)),1./ratio_InSpace(idx),psym=1,color=fsc_color('blue')
oplot,abs(phase(idx)),1./ratio_Observed(idx),psym=4,color=fsc_color('blue')
oplot,abs(phase(idx)),1./ratio_Cleaned(idx),psym=5,color=fsc_color('blue')
oplot,abs(phase(idx)),1./ratio_BBSO(idx),psym=6,color=fsc_color('blue')
;
plots,[40,40],[1,1e4],linestyle=2
plots,[140,140],[1,1e4],linestyle=2
device,/close
end

 
