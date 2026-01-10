data=get_data('beam_Ray.dat')
alfa=reform(data(1,*))
Ray=reform(data(2,*))
plot,/nodata,alfa,ray,xtitle='Elevation angle',ytitle='Intensity',title='Blue: rayleigh scattering, Red: isotropic scattering'
oplot,alfa,ray,color=fsc_color('blue')
data=get_data('beam_Iso.dat')
alfa=reform(data(1,*))
Iso=reform(data(2,*))
oplot,alfa,Iso*2,color=fsc_color('red')
end
