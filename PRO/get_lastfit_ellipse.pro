PRO get_lastfit_ellipse,file,x00,y00,radius1,radius2
x00=0.0
y00=0.0
radius1=0.0
radius2=0.0
openr,72,'lastfit_ellipse'
readf,72,x00,y00,radius1,radius2
close,72
return
end
