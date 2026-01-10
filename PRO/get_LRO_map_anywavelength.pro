PRO get_LRO_map_anywavelength,lamda_wanted,new_map
 ; Read the LRO with the polar caps being scaled Clementine ...
 LRO=readfits('LRO_scaled.fits')
 ; Read in the trends found seperately, in each pixel
 LROtrends=readfits('lunar_albedo_trend.fits')
 lambdas=[321, 360, 415, 566, 604, 643, 689]
 print,'These maps exist: ',lambdas
 ;--------------------------------------------------------
 print,'You want lambda: ',lamda_wanted
 if (lamda_wanted lt lambdas(0)-20 or lamda_wanted gt lambdas(n_elements(lambdas)-1)+20) then begin
     print,'You are going outside the range of the LRO maps ...'
     stop
     endif
 d_lamda=lamda_wanted-lambdas
 idx=where(abs(d_lamda) eq min(abs(d_lamda)))
 print,'Nearest LRO map is the one for: ',lambdas(idx)
 ;
 factor=(lamda_wanted-lambdas(idx))
 new_map=LRO(*,*,idx)+LROtrends(*,*)*factor(0)
 print,'Max new_map: ',max(new_map)
 end
