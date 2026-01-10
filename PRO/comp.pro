im=readfits('Cols0to200/Cols0to200_cleaned.fit')
obs=readfits('Cols0to200/Cols0to200_imin.fit')
!P.CHARSIZE=2
plot_io,abs((obs(*,512/2.)-im(*,512/2.))/obs(*,512/2.)*100.0),ystyle=1,ytitle='|% removed|'
end

