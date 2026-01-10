;-----------------------------------------------------------
 ; Version 1 - uses whole stack, does not sorty on image quality
 ; Will set up boostrapped 100-image averages for fitting.
 ; All output is to PEN/
 ;-----------------------------------------------------------
;fnamestouse=['B','V','VE1','VE2','IRCUT']
 for ifwantalignment=1,1,1 do begin
     for ifwantsubshift=0,0,1 do begin	; do you wnat sub-pixel shifts?
         bias=readfits('./TTAURI/superbias.fits')
         openr,44,'infiles'
         while not eof(44) do begin
             str=''
             readf,44,str
             bits=strsplit(str,' ',/extract)
             JDstr=bits(0)
             FILTER=bits(1)
             ntries=7	; number of bootstraps per 100-image stack
             
             JDstrintpart=string(long(double(JDstr)))
             file=strcompress('/data/pth/DATA/ANDOR/MOONDROPBOX/JD'+JDstrintpart+'/'+JDstr+'MOON'+FILTER+'AIR.fits.gz',/remove_all)
             stack=readfits(file,hdummy)
             l=size(stack,/dimensions)
             nINstack=l(2)
             dummy=readfits('/data/pth/DARKCURRENTREDUCED/SELECTED_1/'+JDstr+'MOON'+FILTER+'AIR_DCR.fits',h)
             nframes=[100]
             for i=0,n_elements(nframes)-1,1 do begin
                 for itry=0,ntries-1,1 do begin
                     idx=fix(randomu(seed,nframes(i))*nINstack)
                     print,idx,' * ',nframes(i)
                     if (nframes(i) eq 1) then idx=1
                     newstack=stack(*,*,idx)
                     if (ifwantalignment eq 1 and nframes(i) ne 1) then align_stack,newstack,ifwantsubshift
                     if (nframes(i) ne 1) then newim=avg(newstack,2,/double)
                     if (nframes(i) eq 1) then newim=newstack
                     if (ifwantalignment eq 0) then name=strcompress('PEN/'+JDstr+'MOON'+FILTER+'AIR_UNaligned_sum_of_'+string(nframes(i))+'_#'+string(itry)+'_boot_frames.fits',/remove_all)
                     if (ifwantalignment eq 1 and ifwantsubshift ne 1) then name=strcompress('PEN/'+JDstr+'MOON'+FILTER+'AIR_aligned_integershifts_sum_of_'+string(nframes(i))+'_#'+string(itry)+'_boot_frames.fits',/remove_all)
                     if (ifwantalignment eq 1 and ifwantsubshift eq 1) then name=strcompress('PEN/'+JDstr+'MOON'+FILTER+'AIR_aligned_subpixelshift_sum_of_'+string(nframes(i))+'_#'+string(itry)+'_boot_frames.fits',/remove_all)
                     print,name
                     writefits,name,newim-bias,h
                     tvscl,hist_equal(newim-bias)
                     endfor
                 endfor
             endwhile 
         
         endfor
     endfor
 close,44
 end
