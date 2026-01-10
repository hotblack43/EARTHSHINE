; Define the coefficient array:
a = [[4, 16000, 17000], $
   [2, 5, 8], $
   [3, 6, 10]]

; Define the right-hand side vector b:
b = [100.1, 0.1, 0.01]
b=b*0.0
; Compute and print the solution to ax=b:
x = LA_LINEAR_EQUATION(a, b)
PRINT, 'LA_LINEAR_EQUATION solution:', X
end
