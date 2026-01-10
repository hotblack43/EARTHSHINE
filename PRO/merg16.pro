;+
; NAME:
;
;   MERG16
;
; PURPOSE:
;
;   Merge 3 16bit linear TIFF files into a single medium dynamic range
;   (MDR) 16bit TIFF, obtained in a bracketed set of images at [-2, 0,
;   2EV].  Assumes linearity over a large range of intensity values.
;
; CATEGORY:
;
;   Medium Dynamic Range Imaging
;
; CALLING SEQUENCE:
;
;   merg16,image_set,output_image,[KEEP_RANGE=, GAMMA=e, _EXTRA=e]
;
; INPUTS:
;
;   image_set: A vector of 3 image file [dark_file, normal_file,
;     bright_file], which must contain 16bit linear imaging data
;     (e.g. as produced by dcraw -4 -T).
;
;   output_image: The TIFF image filename to write the MDR output to.
;
; KEYWORD PARAMETERS:
;
;   KEEP_RANGE: A two element integer vector, given [low_cutoff,
;     high_cutoff], the range over which data is assumed to scale
;     linearly with shutter speed.  [800,60000] by default (the useful
;     lower end may vary depending on noise performance.)
;
;   GAMMA: If passed, gamma-correct the image with this gamma value
;     (e.g. 2.2).  By default, output is linear.
;
;   _EXTRA: Extra keywords for WRITE_TIFF.
;
; SIDE EFFECTS:
;
;   The output_image is written.
;
; RESTRICTIONS:
;
;   Input images must be linear 16bit TIFFs, most readily converted
;   from the RAW image formats of a digital cameras using Dave
;   Coffin's DCRAW (http://cybercom.net/~dcoffin/dcraw/).  Images are
;   assumed to be offset by factors of 4 in (linear) output value.
;
; EXAMPLE:
;
;   merg16,['dark.tiff','normal.tiff','bright.tiff'],'mdr16.tiff',GAMMA=2.2
;
; MODIFICATION HISTORY:
;
;   02/17/07 J.D. Smith <jdsmith@as.arizona.edu>: Written.
;
;-
;##############################################################################
; 
; LICENSE
;
;  Copyright (C) 2007 J.D. Smith
;
;  MERGE16 is free software; you can redistribute it and/or modify it
;  under the terms of the GNU General Public License as published by
;  the Free Software Foundation; either version 2, or (at your option)
;  any later version.
;  
;  MERGE16 is distributed in the hope that it will be useful, but
;  WITHOUT ANY WARRANTY; without even the implied warranty of
;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;  General Public License for more details.
;  
;  You should have received a copy of the GNU General Public License
;  along with MERGE16; see the file COPYING.  If not, write to the Free
;  Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;  Boston, MA 02110-1301, USA.
;
;##############################################################################

pro merg16,file_set,file_out,KEEP_RANGE=cr,GAMMA=gamma,_EXTRA=e
  if n_elements(cr) eq 0 then cr=[800U,60000U] ;linearity/noise range
  
  if n_elements(file_set) ne 3 || n_params() ne 2 then $
     message,'Usage: merg16, [dark_file, normal_file, bright_file], out_file'
  
  for i=0L,2 do begin 
     imtmp=read_tiff(file_set[i])
     if i eq 0 then begin ;; Setup full arrays
        s=size(imtmp,/DIMENSIONS)
        targ=[s,3]              ; [color channel, x, y, exposure]
        off=product(s,/PRESERVE_TYPE)
        im=lonarr(targ,/NOZERO)
        imkeep=bytarr(targ,/NOZERO)
     endif 
     imtmp=reform(imtmp,off,/OVERWRITE) ;for easy running insertion
     case i of ;keep flags
        0: imkeep[i*off]=(imtmp gt cr[0]) ;dark, keep high 
        1: imkeep[i*off]=(imtmp gt cr[0]) AND (imtmp lt cr[1]) ;norm 
        2: imkeep[i*off]=(imtmp lt cr[1]) ;bright, keep low
     endcase 
     if i gt 0 then imtmp/=2^(2*i) ;shift down by 2 stops.
     im[i*off]=temporary(imtmp)
  endfor 
  
  ;; If a pixel is excluded in any color, exclude it in *all* colors
  imkeep=rebin(reform(product(temporary(imkeep),1,/PRESERVE_TYPE), $
                      [1,targ[1:*]]),targ,/SAMPLE)
  
  ;; Take care of pixels with all three excluded
  t=total(imkeep,4,/PRESERVE_TYPE)
  wh=where(t eq 0b,cnt)
  if cnt gt 0 then begin 
     ;; If none are present, turn them all on!
     imkeep[rebin(wh,cnt,3,/SAMPLE)+ rebin(lindgen(1,3),cnt,3,/SAMPLE)*off]=1b
     t[wh]=3b
  endif 
  
  ;; Average
  im=uint(total(temporary(im)*imkeep,4,/PRESERVE_TYPE)/t)
  
  ;; Gamma remap
  if n_elements(gamma) gt 0 then begin 
     gtab=round((findgen(2L^16)/(2L^16-1))^(1./gamma)*(2L^16-1))
     im=gtab[temporary(im)]
  endif 

  write_tiff,file_out,im,/SHORT,_EXTRA=e
end
