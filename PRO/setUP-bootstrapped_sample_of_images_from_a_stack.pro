for ifwantalignment=0,1,1 do begin
 for ifwantsubshift=0,1,1 do begin	; do you wnat sub-pixel shifts?
 bias=readfits('./TTAURI/superbias.fits')
 bias=bias*0.0d0
 file='synth_stack_2456073.7781942.fits'
 ;file='/data/pth/DATA/ANDOR/MOONDROPBOX/JD2456073/2456073.7983881MOON_V_AIR.fits.gz'
 ;file='/data/pth/DATA/ANDOR/MOONDROPBOX/JD2456073/2456073.7472223MOON_V_AIR.fits.gz'
 stack=readfits(file,hdummy)
 dummy=readfits('data/pth/DARKCURRENTREDUCED/SELECTED_1/2456073.7781942MOON_V_AIR_DCR.fits',h)
 ;dummy=readfits('/data/pth/DARKCURRENTREDUCED/SELECTED_1/2456073.7983881MOON_V_AIR_DCR.fits',h)
 ;dummy=readfits('/data/pth/DARKCURRENTREDUCED/SELECTED_1/2456073.7472223MOON_V_AIR_DCR.fits',h)
 nframes=[1,3,6,12,25,50,100]
 sxaddpar, h, 'DISCX0', 256., 'Disk centre x set by setUP.'
 sxaddpar, h, 'DISCY0', 256., 'Disk centre y set by setUP.'
 for i=0,n_elements(nframes)-1,1 do begin
     ntries=10
     for itry=0,ntries-1,1 do begin
         idx=fix(randomu(seed,nframes(i))*nframes(i))
         if (nframes(i) eq 1) then idx=1
         newstack=stack(*,*,idx)
         if (ifwantalignment eq 1 and nframes(i) ne 1) then align_stack,newstack,ifwantsubshift
         if (nframes(i) ne 1) then newim=avg(newstack,2,/double)
         if (nframes(i) eq 1) then newim=newstack
         if (ifwantalignment eq 0) then name=strcompress('2456073.7781942MOON_V_AIR_UNaligned_sum_of_'+string(nframes(i))+'_#'+string(itry)+'_boot_frames.fits',/remove_all)
         if (ifwantalignment eq 1 and ifwantsubshift ne 1) then name=strcompress('2456073.7781942MOON_V_AIR_aligned_integershifts_sum_of_'+string(nframes(i))+'_#'+string(itry)+'_boot_frames.fits',/remove_all)
         if (ifwantalignment eq 1 and ifwantsubshift eq 1) then name=strcompress('2456073.7781942MOON_V_AIR_aligned_subpixelshift_sum_of_'+string(nframes(i))+'_#'+string(itry)+'_boot_frames.fits',/remove_all)
         print,name
	outim=newim-bias
	outim=outim/max(outim)*50000.
         writefits,name,outim,h
         tvscl,hist_equal(outim)
         endfor
     endfor
endfor
endfor
 end
