;+
; NAME:
;       HistoMatch
;
; PURPOSE:
;
;       This is a function for Histogram Matching, in which an image
;       is manipulated in such a way that it's final histogram approximates
;       the histogram of an input image or histogram. Histogram matching
;       allows the user to specify the shape of the histogram of the final
;       product.
;
; AUTHOR:
;
;       FANNING SOFTWARE CONSULTING
;       David Fanning, Ph.D.
;       1645 Sheely Drive
;       Fort Collins, CO 80526 USA
;       Phone: 970-221-0438
;       E-mail: davidf@dfanning.com
;       Coyote's Guide to IDL Programming: http://www.dfanning.com
;
; CATEGORY:
;
;       Image Processing
;
; CALLING SEQUENCE:
;
;       output_image = HistoMatch(image, histogram_to_match)
;
; INPUTS:
;
;       image - The input image to be manipulated. Assumed to be a 2D byte array.
;
;       histogram_to_match - Can be either a 1D long vector of 256 elements specifying
;           the histogram to match, or a 2D byte array from which the histogram to
;           match is calculated.
;
; OUTPUTS:
;
;       output_image - The manipulated image adjusted to the histogram specifications.
;
; INPUT KEYWORDS:
;
;       None.
;
; OUTPUT KEYWORDS:
;
;       None.
;
; DEPENDENCIES:
;
;       None.
;
; METHOD:
;
;       Based on the Histogram Matching method on pages 94-102 of Digital
;       Image Processing, 2nd Edition, Rafael C. Gonzalez and Richard E. Woods,
;       ISBN 0-20-118075-8.
;
; EXAMPLE:
;
;       There is an example program at the end of this file. It will require TVIMAGE
;       from the Coyote Library to run. You can also find an explanation of this program
;       at http://www.dfanning.com/ip_tips/histomatch.html.
;
; MODIFICATION HISTORY:
;
;       Written by David W. Fanning, January 2003.
;-
;
;###########################################################################
;
; LICENSE
;
; This software is OSI Certified Open Source Software.
; OSI Certified is a certification mark of the Open Source Initiative.
;
; Copyright © 2003 Fanning Software Consulting.
;
; This software is provided "as-is", without any express or
; implied warranty. In no event will the authors be held liable
; for any damages arising from the use of this software.
;
; Permission is granted to anyone to use this software for any
; purpose, including commercial applications, and to alter it and
; redistribute it freely, subject to the following restrictions:
;
; 1. The origin of this software must not be misrepresented; you must
;    not claim you wrote the original software. If you use this software
;    in a product, an acknowledgment in the product documentation
;    would be appreciated, but is not required.
;
; 2. Altered source versions must be plainly marked as such, and must
;    not be misrepresented as being the original software.
;
; 3. This notice may not be removed or altered from any source distribution.
;
; For more information on Open Source Software, visit the Open Source
; web site: http://www.opensource.org.
;
;###########################################################################


FUNCTION HISTOMATCH_ERROR_MESSAGE, theMessage, Error=error, Informational=information, $
   Traceback=traceback, NoName=noname, Title=title, _Extra=extra

; An error handler for the program.

On_Error, 2

   ; Check for presence and type of message.

IF N_Elements(theMessage) EQ 0 THEN theMessage = !Error_State.Msg
s = Size(theMessage)
messageType = s[s[0]+1]
IF messageType NE 7 THEN BEGIN
   Message, "The message parameter must be a string.", _Extra=extra
ENDIF

   ; Get the call stack and the calling routine's name.

Help, Calls=callStack
IF Float(!Version.Release) GE 5.2 THEN $
   callingRoutine = (StrSplit(StrCompress(callStack[1])," ", /Extract))[0] ELSE $
   callingRoutine = (Str_Sep(StrCompress(callStack[1])," "))[0]

   ; Are widgets supported?

widgetsSupported = ((!D.Flags AND 65536L) NE 0)
IF widgetsSupported THEN BEGIN

      ; If this is an error produced with the MESSAGE command, it is a trapped
      ; error and will have the name "IDL_M_USER_ERR".

   IF !ERROR_STATE.NAME EQ "IDL_M_USER_ERR" THEN BEGIN

      IF N_Elements(title) EQ 0 THEN title = 'Trapped Error'

         ; If the message has the name of the calling routine in it,
         ; it should be stripped out. Can you find a colon in the string?

      colon = StrPos(theMessage, ":")
      IF colon NE -1 THEN BEGIN

            ; Extract the text up to the colon. Is this the same as
            ; the callingRoutine? If so, strip it.

         IF StrMid(theMessage, 0, colon) EQ callingRoutine THEN $
            theMessage = StrMid(theMessage, colon+1)

      ENDIF

         ; Add the calling routine's name, unless NONAME is set.

      IF Keyword_Set(noname) THEN BEGIN
         answer = Dialog_Message(theMessage, Title=title, _Extra=extra, $
            Error=error, Information=information)
      ENDIF ELSE BEGIN
         answer = Dialog_Message(StrUpCase(callingRoutine) + ": " + $
            theMessage, Title=title, _Extra=extra, $
            Error=error, Information=information)
      ENDELSE

   ENDIF ELSE BEGIN

         ; Otherwise, this is an IDL system error.

      IF N_Elements(title) EQ 0 THEN title = 'System Error'

      IF StrUpCase(callingRoutine) EQ "$MAIN$" THEN $
         answer = Dialog_Message(theMessage, _Extra=extra, Title=title, $
            Error=error, Information=information) ELSE $
      IF Keyword_Set(noname) THEN BEGIN
         answer = Dialog_Message(theMessage, _Extra=extra, Title=title, $
            Error=error, Information=information)
      ENDIF ELSE BEGIN
         answer = Dialog_Message(StrUpCase(callingRoutine) + "--> " + $
            theMessage, _Extra=extra, Title=title, $
            Error=error, Information=information)
      ENDELSE
   ENDELSE
ENDIF ELSE BEGIN
      Message, theMessage, /Continue, /NoPrint, /NoName, /NoPrefix, _Extra=extra
      Print, '%' + callingRoutine + ': ' + theMessage
      answer = 'OK'
ENDELSE

   ; Provide traceback information if requested.

IF Keyword_Set(traceback) THEN BEGIN
   Help, /Last_Message, Output=traceback
   Print,''
   Print, 'Traceback Report from ' + StrUpCase(callingRoutine) + ':'
   Print, ''
   FOR j=0,N_Elements(traceback)-1 DO Print, "     " + traceback[j]
ENDIF

RETURN, answer
END
; ----------------------------------------------------------------------------



FUNCTION HISTOMATCH, image, histogram_to_match

   ; Error handling.

Catch, theError
IF theError NE 0 THEN BEGIN
   Catch, /Cancel
   ok = Histomatch_Error_Message(/Traceback)
   IF N_Elements(image) NE 0 THEN RETURN, image ELSE RETURN, -1L
ENDIF

   ; We require two input parameters.

IF N_Params() NE 2 THEN Message, 'Two arguments required. Please read the program documentation.'

   ; Must have 2D image array.

IF Size(image, /N_Dimensions) NE 2 THEN Message, 'Image argument must be 2D. Returning.'

   ; Is the histogram_to_match variable a 1D or 2D array? Branch accordingly.

CASE Size(histogram_to_match, /N_Dimensions) OF
   1: BEGIN
      IF N_Elements(histogram_to_match) NE 256 THEN $
         Message, 'Histogram to match has incorrect size. Returning.'
      match_histogram =    histogram_to_match
      END
   2: match_histogram = Histogram(Byte(histogram_to_match), Min=0, Max=255, Binsize=1)
   ELSE: Message, 'Histogram to match has incorrect number of dimensions. Returning.'
ENDCASE

   ; Calculate the histogram of the input image.

h = Histogram(Byte(image), Binsize=1, Min=0, Max=255)

   ; Make sure the two histograms have the same number of pixels. This will
   ; be a problem if the two images are different sizes, you are matching a
   ; histogram from an image subset, etc.

totalPixels = Float(N_Elements(image))
totalHistogramPixels = Float(Total(match_histogram))

IF totalPixels NE totalHistogramPixels THEN $
   factor = totalPixels / totalHistogramPixels ELSE $
   factor = 1.0

match_histogram = match_histogram * factor

   ; Find a mapping from the input pixels to the transformation function s.

s = FltArr(256)
FOR k=0,255 DO BEGIN
  s[k] = Total(h(0:k) / totalPixels)
ENDFOR

   ; Find a mapping from input histogram to the transformation function v.

v = FltArr(256)
FOR q=0,255 DO BEGIN
  v[q] = Total(match_histogram(0:q) / Total(match_histogram))
ENDFOR

   ; Find probablitly density function z from v and s.

z = BytArr(256)
FOR j=0,255 DO BEGIN
   i = Where(v LT s[j], count)
   IF count GT 0 THEN z[j] = (Reverse(i))[0] ELSE z[j]=0
ENDFOR

   ; Create the matched image.

matchedImage = z[Byte(image)]
RETURN, matchedImage
END
; ----------------------------------------------------------------------------



PRO Example

   ; Get an image whose histogram you want to match.

filename = Filepath('ctscan.dat', Subdir=['examples', 'data'])
OpenR, lun, filename, /Get_Lun
image_to_match = BytArr(256, 256)
ReadU, lun, image_to_match
Free_Lun, lun

   ; Get an image to apply the histogram to.

filename = Filepath('worldelv.dat', Subdir=['examples', 'data'])
OpenR, lun, filename, /Get_Lun
image = BytArr(360, 360)
ReadU, lun, image
Free_Lun, lun


Window, 0, XSize=500, YSize=250, Title='Match this Image Histogram', XPos=100, YPos=100
!P.Multi=[0,2,1]
TVImage, image_to_match
Plot, Histogram(image_to_match), Max_Value=5000
!P.Multi=0

Window, 1, XSize=500, YSize=250, Title='Manipulate this Image', XPos=100, YPos=360
!P.Multi=[0,2,1]
TVImage, image
Plot, Histogram(image), Max_Value=5000
!P.Multi=0

Window, 2, XSize=500, YSize=250, Title='Final Result', XPos=100, YPos=630
!P.Multi=[0,2,1]
match = HistoMatch(image, image_to_match)
TVImage, match
Plot, Histogram(match), Max_Value=5000
!P.Multi=0
END