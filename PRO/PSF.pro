FUNCTION psfn,p,r
 common psfmatchpoints,y0,matchpoints
 n=n_elements(p)
 m=n_elements(matchpoints)
 if (n_elements(r) ne 1) then stop
 x=[matchpoints(0)]
 c=x(0)^p(0)*y0
 for i=1,n-1,1 do begin
     x=[x,matchpoints(i)]
     c=[c,c(i-1)*x(i)^(p[i]-p[i-1])]
     endfor
 if (r le x(0)) then begin
     value=y0
     endif else begin
     idx=min(where((x-r) ge 0))-1
     if (idx(0) eq -1) then stop
     value=c(idx)/r^p(idx)
     endelse
 return,value
 end
 
 common psfmatchpoints,y0,matchpoints
 x=[]
 y=[]
 y0=1.0d0
 liste=[]
 openr,1,'matchpoints.txt'
 while not eof(1) do begin
 str=0.0d0
 readf,1,str
 liste=[liste,str]
 endwhile
 close,1
 matchpoints=reform(transpose(liste))
 print,'There are ',n_elements(matchpoints),' matchpoints'
 powers=dblarr(n_elements(matchpoints))
 openr,1,'lastfit_v14'
 readf,1,powers
 close,1
 for k=0,100,1 do begin
 print,k,powers(k),matchpoints(k)
 endfor
 for radius=1,250,1 do begin
     x=[x,radius]
     y=[y,psfn(powers,radius)]
     endfor
 plot_oo,x,y
 end
