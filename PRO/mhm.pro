FUNCTION mhm,array_in
; applies Andrew Mattingly's mean half median clipping routineto array
x=array_in
x=x(sort(x))
n=n_elements(x)
x=x(0.25*n:0.75*n)
mhm=mean(x)
return,mhm
end
