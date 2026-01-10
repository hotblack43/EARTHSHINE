FUNCTION coscos,x
thing=cos(x)*cos(x)
return,thing
end


y1=coscos(!pi/4.)
y2=coscos(!pi/4.-0.04*!dtor)
y3=coscos(!pi/4.+.04*!dtor)
print,'+/-',(y2-y3)/y1/2.*100.0,' %'
end