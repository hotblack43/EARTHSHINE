PRO go_do_powell,observed,start_parms
 ; Find best parametrs using POWELL method
 ; and the counting of negativesNx=n
 xi=[[1,0,0],[0,1,0],[0,0,1]]
 ftol=1.e-8
 POWELL,start_parms,xi,ftol,fmin,'countnegatives'
 return
 end
