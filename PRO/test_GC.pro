az1=110.
az2=100.
alt1=40.
alt2=40.
d=great_circle(az1,alt1,az2,alt2)/6378388.d0/!pi/2.*360.0
print,d
end
