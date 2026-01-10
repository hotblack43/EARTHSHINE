; Code to analyse lunar images. Especially simulated images from eshine_15.pro
; the code extracts the illumination from a pixel in Grimaldi and a pixcel in Crisium and
; forms the ratio and displays the reuslt as a function of time
; pictures of the Moon are innserted in the plot to help understand
; the role of the lunar phase
;------------------------------------------------------------------------------------------
files=file_search('Eshine/lib_eshine/OUTPUT/JPEGS/ideal*',count=n)
print,files
plot_io,/nodata,[0,31],[1e-1,1e6],charsize=2,xtitle='Day',ytitle='Grimaldi/Crisium',psym=-5,xstyle=1,ystyle=1
for i=0,n-1,1 do begin
	im=readfits(files(i))
	pixel1=im(56,158)
	pixel2=im(273,208)
	print,pixel1/pixel2
	if (i eq 0) then begin
		ratio=[pixel1/pixel2]
		bigim=[congrid(im,18,18)]
	endif
	if (i gt 0) then begin
		ratio=[ratio,pixel1/pixel2]
		bigim=[bytscl(bigim),bytscl(shift(congrid(im,18,18),.1))]
	endif
	tvscl,congrid(im,20,20),i-0.5,100,/data
endfor
idx=where(ratio lt 0.1)
ratio(idx)=1./ratio(idx)
oplot,ratio,psym=-5

end
