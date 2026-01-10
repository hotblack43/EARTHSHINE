FUNCTION ls,i,e
; i and e are angle sin DEGREES
val=cos(i*!dtor)/(cos(i*!dtor)+cos(e*!dtor))
print,val
return,val
end

a=findgen(90)
plot,a,ls(a,90.)
end
