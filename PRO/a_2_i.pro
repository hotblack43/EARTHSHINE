PRO normit,target,moveit
mv=mean(double(target),/NaN)
factor=mv/mean(double(moveit),/NaN)
print,'factor :',factor
moveit=double(moveit)*factor
return
end

target=readfits('TOMSTONE/2709_ROLO_rotatedm90.fit')
moveit=readfits('./OUTPUT/IDEAL/ideal_LunarImg_0000.fit')
; normalize to same mean
print,mean(target),mean(moveit)
normit,target,moveit
print,mean(target),mean(moveit)
a=0.7
b=12.
c=1.2
d=32.0
e=-9.0
print,total((target-a*shift(rot(reverse(moveit),b,c,/interp),d,e))^2)
tvscl,[target,moveit]
end

