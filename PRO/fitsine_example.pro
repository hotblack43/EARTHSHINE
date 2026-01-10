PRO gfunct, X, A, F, pder

  p = a[2]
  F = A[0] + a[1] * sin(2.*!pi*x/p)
 

; calculate the partial derivatives.


	pder = [[replicate(1.0, N_ELEMENTS(X))],[sin(2.*!pi*x/p)],[-2*b*!pi*x*cos(2*!pi*x/p)/p**2]]
END

Compute the fit to the function we have just defined. First, define the independent and dependent variables:

X = FLOAT(INDGEN(10))
Y = [12.0, 11.0, 10.2, 9.4, 8.7, 8.1, 7.5, 6.9, 6.5, 6.1]

;Define a vector of weights.
weights = 1.0/Y

;Provide an initial guess of the function’s parameters.
A = [10.0,-0.1,2.0]
;Compute the parameters.
yfit = CURVEFIT(X, Y, weights, A, SIGMA, FUNCTION_NAME='gfunct')
