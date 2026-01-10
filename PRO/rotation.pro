angle=8.	; arcseconds
angle=angle*(2.*!pi/(360.*60.*60.))	; radians
radius=450.
delta=radius*sin(angle)
print,delta,' pixels/sec'
print,delta*60.,' pixels/min'
end
