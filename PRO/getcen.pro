      PRO  getcen,array,nxpixel,nypixel,rix,riy,mx,my,radius
;    array=fltarr(nxpixel,nypixel)
;
;     centers stellar objects inside circle size "radius"
;     rix,riy are the first guess at the center
;     mx, my are the (returned) recentered coordinates
;
; IDL translation of Fortran routine getcen.f
;
      mx = rix
      my = riy

      for iter = 1, 3,1 do begin

;     find the mean

         ix = nint(mx)
         iy = nint(my)

         npix = 0
         to = 0.0
         irad = nint(radius)
         for i = -irad,irad,1 do begin
            for j = -irad,irad,1 do begin
               lx = ix+i
               ly = iy+j
               to = to + array(lx,ly)
               npix = npix + 1
            endfor
         endfor
         xmean = to/npix

;     find X-marginals

         sum1 = 0.0
         sum2 = 0.0
         to = 0.0
         for i = -irad,irad,1 do begin
            sum3 = 0.0
            lx = ix+i
            for j = -irad,irad,1 do begin
               ly = iy+j
               sum3 = sum3 + array(lx,ly) - xmean
            endfor
            if (sum3 gt 0.0) then begin
               sum1 = sum1 + lx*sum3
               sum2 = sum2 + sum3
            endif
         endfor
         mx = sum1/sum2

;     find Y-marginals

         sum1 = 0.0
         sum2 = 0.0
         to = 0.0
         for j = -irad,irad,1 do begin
            sum3 = 0.0
            ly = iy+j
            for i = -irad,irad,1 do begin
               lx = ix+i
               sum3 = sum3 + array(lx,ly) - xmean
            endfor
            if (sum3 gt 0.0) then begin
               sum1 = sum1 + ly*sum3
               sum2 = sum2 + sum3
            endif
         endfor
         my = sum1/sum2

      endfor

      return
      end


