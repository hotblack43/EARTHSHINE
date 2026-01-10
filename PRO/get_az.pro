PRO get_az,xa,xb,ya,yb,az
if (xb-xa ge 0) then signx=+1
if (xb-xa lt 0) then signx=-1
if (yb-ya ge 0) then signy=+1
if (yb-ya lt 0) then signy=-1
arg=abs((yb-ya)/(xb-xa))
if (signx eq +1 and signy eq +1) then az=90.-atan(arg)/!dtor
if (signx eq +1 and signy eq -1) then az=90.+atan(arg)/!dtor
if (signx eq -1 and signy eq -1) then az=270.-atan(arg)/!dtor
if (signx eq -1 and signy eq +1) then az=270.+atan(arg)/!dtor
return
end
