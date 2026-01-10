FUNCTION powfunc, X
   RETURN, (X[0] + 2.0*X[1]) * EXP(-X[0]^2 -X[1]^2)
END
PRO TEST_POWELL
   ; Define the fractional tolerance:
   ftol = 1.0e-4
   ; Define the starting point:
   P = [.5d, -.25d]
   ; Define the starting directional vectors in column format:
   xi = TRANSPOSE([[1.0, 0.0],[0.0, 1.0]])
   ; Minimize the function:
   POWELL, P, xi, ftol, fmin, 'powfunc'
   ; Print the solution point:
   PRINT, 'Solution point: ', P
   ; Print the value at the solution point:
   PRINT, 'Value at solution point: ', fmin
END
