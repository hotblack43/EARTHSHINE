; Define the array A: 
A = [[1.0, 2.0, -1.0, 2.5], $ 
     [1.5, 3.3, -0.5, 2.0], $ 
     [3.1, 0.7,  2.2, 0.0], $ 
     [0.0, 0.3, -2.0, 5.3], $ 
     [2.1, 1.0,  4.3, 2.2], $ 
    [0.0, 5.5,  3.8, 0.2]] 
			  
			  ; Define the right-hand side vector B: 
B = [0.0, 1.0, 5.3, -2.0, 6.3, 3.8] 
			   
			   ; Decompose A: 
			   SVDC, A, W, U, V 
			    
			    ; Compute the solution and print the result: 
PRINT, SVSOL(U, W, V, B)
;
res=regress(a,b,const=const)
print,const
print,res
			    end
