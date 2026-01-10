PRO determineFLIP,JD,refimFLIPneeded
refimFLIPneeded=0
MOONPOS, jd, ramoon, DECmoon, dis
obsname='MLO'
eq2hor, ramoon, decmoon, jd, alt_moon, az_moon, ha_moon,  OBSNAME=obsname
print,'az:',az_moon
if (az_moon gt 180.) then refimFLIPneeded=1
print,'refimFLIPneeded:',refimFLIPneeded
return
end

jd='2455912.09979'
jd='2455924.7211'
determineFLIP,JD,refimFLIPneeded
print,refimFLIPneeded
end
