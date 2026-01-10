fac=2.*!pi/360.
h=[0,1,2,3,4,5]
for i=0,90,5 do begin
print,format='(i3,1x,6f8.3)',i,exp(-h/7.5)/cos(i*fac)
endfor
end