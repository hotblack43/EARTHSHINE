 PRO writeBIN,im,name
 openw,1,name
 writeu,1,im
 close,1
 return
 end

 ;---------------------------------------------------------------------------
 ; will write FITS images out as binary files for reading from C or Fortran etc
 ;---------------------------------------------------------------------------
 mask=readfits('mask.fits')	;	512x512 (allows only sky pixels)
 writeBIN,mask,'mask.bin'
 observed=readfits('presentinput.fits')	; 512x512
 writeBIN,observed,'observed.bin'
 ideal=readfits('ideal.fits')	; 1536x1536
 writeBIN,ideal,'ideal.bin'
 PSForig=readfits('PSF_fromHalo_1536.fits')	; 1536x1536
 writeBIN,PSForig,'PSF_fromHalo_1536.bin'
 end
