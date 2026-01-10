PRO hejsa
!null = Python.run('import rpy2.robjects as robjects')
robjects = Python.robjects
R = robjects.r

!null = R('ctl <- c(4.17,5.58,5.18,6.11,4.50,4.61,5.17,4.53,5.33,5.14)')
;res = R('x = 17 ; x')
print, res

y = 12
print, y

print, 'This is the end'
end
