!P.MULTI=[0,3,3]
FLATNAMES=['_V_','_B','_VE1','_VE2','IRCUT']
files=file_search('FLATS/','*.fits',count=nflats)
for i=0,4,1 do begin
liste=files(where(strpos(files,flatnames(i)) ne -1 eq 1))
print,'Looking at ',flatnames(i)
im=readfits(liste(0),/sil)
im=median(im,3)
for k=1,n_elements(liste)-1,1 do im=im+readfits(liste(k),/sil)
meanim=im/float(n_elements(liste))
for j=0,n_elements(liste)-1,1 do begin
contour,/cell_fill,nlevels=21,meanim,title=flatnames(i),xstyle=3,ystyle=3,/isotropic
im=readfits(liste(j),/sil)
im=median(im,3)
diff=(im-meanim)/meanim*100.0
print,'Mean abs. diff,  in pct: ',mean(abs(diff))
print,'Max  difference, in pct: ',max(diff)
print,'Min  difference, in pct: ',min(diff)
!P.charsize=2
plot,diff(*,255),xtitle='Column #',ytitle='Difference wrt mean im, in pct',title=flatnames(i)
surface,diff,title=flatnames(i)
endfor
endfor
end
