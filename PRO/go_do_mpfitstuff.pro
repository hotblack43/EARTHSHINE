PRO go_do_mpfitstuff,observed,start_parms,n
 ; Find best parametrs using MPFIT2DFUN method
 Nx=n
 Ny=n
 XR = indgen(Nx)
 YC = indgen(Ny)
 X = double(XR # (YC*0 + 1))        ;     eqn. 1
 Y = double((XR*0 + 1) # YC)        ;     eqn. 2
 err=sqrt(observed>1) ; Poisson noise ...
 z=observed
 ; set up the PARINFO array - indicate double-sided derivatives (best)
 parinfo = replicate({mpside:2, value:0.D, $
 fixed:0, step:0, limited:[0,0], limits:[0.D,0]}, 3)
 parinfo[0].fixed = 0
 parinfo[1].fixed = 0
 parinfo[2].fixed = 0
 ; Peak value
 parinfo[0].limited(0) = 1
 parinfo[0].limits(0)  = -10000.0
 parinfo[0].limited(1) = 1
 parinfo[0].limits(1)  = 10000.0d0
 
 ; Width
 parinfo[1].limited(0) = 1
 parinfo[1].limits(0)  = 0.0d0
 parinfo[1].limited(1) = 1
 parinfo[1].limits(1)  = 2.0d0
 
 ; Pedestal
 parinfo[2].limited(0) = 1
 parinfo[2].limits(0)  = 0.0d0
 parinfo[2].limited(1) = 1
 parinfo[2].limits(1)  = 10000.0d0
 
 ;
 parinfo[*].value = start_parms
 ; print out limits and startiong values
 for ipar=0,2,1 do begin
     print,'........................................'
     print,'Paramter ',ipar,' : ', start_parms(ipar)
     print,'Is limited ?',parinfo[ipar].limited(0),parinfo[ipar].limited(1)
     print,'What is limit ?',parinfo[ipar].limits(0),parinfo[ipar].limits(1)
     print,'Is it fixed?',parinfo[ipar].fixed
     endfor
 print,'........................................'
 results = MPFIT2DFUN('minimize_me_2', X, Y, Z, ERR, PARINFO=parinfo,perror=sigs,STATUS=hej)
 return
 end
