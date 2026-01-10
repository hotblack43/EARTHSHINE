



; Cod eto study suitable ways to represnet a WIDE PSF as a spline





PRO spinthespline,nxb,nyb,brray2
      brray2=dblarr(nxb,nyb)
      c=fltarr(5)
      c(0) =  -0.3933615    ; +/-  3.7634037E-02
      c(1) =   -1.328291    ; +/-  0.2168711    
      c(2) =   -2.673426    ; +/-  0.6366262    
; fit for log(r) >= 0.5
      c(3) =  -0.9203336    ; +/-  1.3536011E-04
      c(4) =   -1.601890    ; +/-  6.9708112E-05

      sum = 0.0
      for i = 0, nxb-1,1 do begin
         for  j = 0, nyb-1,1 do begin
            r = sqrt((nxb/2.0-i)^2 + (nyb/2.0-j)^2)
            if (r gt 0.1) then begin
               rl = alog10(r)
               if (rl lt 0.5) then fac = c(0) + c(1)*rl + c(2)*rl^2 + c(3)*rl^3
               if (rl ge 0.5) then fac = c(3) + c(4)*rl
            endif else begin
               fac = 0.0
            endelse
            brray2(i,j) = 10.0^fac
            sum = sum + brray2(i,j)
         endfor 
      endfor
	brray2=brray2/sum/float(nxb)/float(nyb)
return
end

nxb=512
nyb=512
spinthespline,nxb,nyb,brray2
end
