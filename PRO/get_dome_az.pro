PRO get_dome_az,x,y,dome_az
if (x ge 0) then signx=+1
if (x lt 0) then signx=-1
if (y ge 0) then signy=+1
if (y lt 0) then signy=-1
arg=abs(y/x)
if (signx eq +1 and signy eq +1) then dome_az=90.-atan(arg)/!dtor
if (signx eq +1 and signy eq -1) then dome_az=90.+atan(arg)/!dtor
if (signx eq -1 and signy eq -1) then dome_az=270.-atan(arg)/!dtor
if (signx eq -1 and signy eq +1) then dome_az=270.+atan(arg)/!dtor
return
end
