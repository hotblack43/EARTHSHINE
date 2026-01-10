PRO get_lastfit_circle,file,x00,y00,radius
x00=0.0
y00=0.0
radius=0.0
openr,72,'lastfit_circle'
readf,72,x00,y00,radius
print,'Opened lastfit_circle, found: x00,y00,radius=',x00,y00,radius
close,72
return
end
