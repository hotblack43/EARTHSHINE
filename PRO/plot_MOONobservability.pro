data=get_data('MOONobservability.no_txt')
a=reform(data(6,*))
!X.style=3
w=3
histo,a,42-w,42+w,.3,xtitle='Sun-Earth-Moon angle',title='Moon observability when Sun is down'
end
