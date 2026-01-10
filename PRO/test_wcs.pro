CD1_1   =    -0.00185370590808d0 ; Transformation matrix
CD1_2   =     6.0086260108d-06 ; no comment
CD2_1   =   -4.73014728394d-06 ; no comment
CD2_2   =    -0.00185310470908d0 ; no comment
;
m=[[cd1_1,cd1_2],[cd2_1,cd2_2]]
print,m
r=transpose([256,256])
print,m#r
end

