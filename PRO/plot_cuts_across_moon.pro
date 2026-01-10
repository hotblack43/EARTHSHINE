files=file_search('OUTPUT/IDEAL/ideal*',count=nfiles)
for ifile=0,nfiles-1,8 do begin
im=readfits(files(ifile))
line=im(*,255)
if (ifile eq 0) then plot_io,line,xstyle=1,yrange=[1e-4,3e2],ystyle=1,xtitle='Column',ytitle='Intensity',title='Cut across simulated lunar disk, at 1 day steps',charsize=2
if (ifile gt 0) then oplot,line
endfor

end
