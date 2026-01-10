PRO whichside,Ax,Ay,Bx,By,Cx,Cy,iside
; x0,y0 coordinates of one end of line
; x1,y1 other end of line
; x2,y2 - coordinates of a point
; iside = -1 or +1 according to which sid eo fline point is
side=(Bx - Ax) * (Cy - Ay) - (By - Ay) * (Cx - Ax)
if (side gt 0) then iside=+1
if (side lt 0) then iside=-1
if (side eq 0) then iside=0
return
end

x=findgen(23)+12
y=1.+2.3*x
Plot,x,y
for itest=1,10000,1 do begin
x2=randomu(seed)*35+10
y2=randomu(seed)*60+20
whichside,min(x),min(y),max(x),max(y),x2,y2,iside
if (iside eq -1) then plots,x2,y2,psym=7
if (iside eq +1) then plots,x2,y2,psym=1
if (iside eq 0) then plots,x2,y2,psym=4
endfor
end
