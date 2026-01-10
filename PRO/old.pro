
;+
; NAME:
;       FSC_COLOR
;
; PURPOSE:
;
;       The purpose of this function is to obtain drawing colors
;       by name and in a device/decomposition independent way.
;       The color names and values may be read in as a file, or 104 color
;       names and values are supplied with the program. These colors were
;       obtained from the file rgb.txt, found on most X-Window distributions.
;       Representative colors were chosen from across the color spectrum. To
;       see a list of colors available, type:
;
;          Print, FSC_Color(/Names), Format='(6A18)'
;          
;        If the color names '0', '1', '2', ..., '255' are used, they will
;        correspond to the colors in the current color table in effect at
;        the time the FSC_Color program is called.
;
; AUTHOR:
;
;       FANNING SOFTWARE CONSULTING:
;       David Fanning, Ph.D.
;       1645 Sheely Drive
;       Fort Collins, CO 80526 USA
;       Phone: 970-221-0438
;       E-mail: davidf@dfanning.com
;       Coyote's Guide to IDL Programming: http://www.dfanning.com
;
; CATEGORY:
;
;       Graphics, Color Specification.
;
; CALLING SEQUENCE:
;
;       color = FSC_Color(theColor, theColorIndex)
;
; NORMAL CALLING SEQUENCE FOR DEVICE-INDEPENDENT COLOR:
;
;       If you write your graphics code *exactly* as it is written below, then
;       the same code will work in all graphics devices I have tested.
;       These include the PRINTER, PS, and Z devices, as well as X, WIN, and MAC.
;
;       In practice, graphics code is seldom written like this. (For a variety of
;       reasons, but laziness is high on the list.) So I have made the
;       program reasonably tolerant of poor programming practices. I just
;       point this out as a place you might return to before you write me
;       a nice note saying my program "doesn't work". :-)
;
;       axisColor = FSC_Color("Green", !D.Table_Size-2)
;       backColor = FSC_Color("Charcoal", !D.Table_Size-3)
;       dataColor = FSC_Color("Yellow", !D.Table_Size-4)
;       thisDevice = !D.Name
;       Set_Plot, 'toWhateverYourDeviceIsGoingToBe', /Copy
;       Device, .... ; Whatever you need here to set things up properly.
;       IF (!D.Flags AND 256) EQ 0 THEN $
;         POLYFILL, [0,1,1,0,0], [0,0,1,1,0], /Normal, Color=backColor
;       Plot, Findgen(11), Color=axisColor, Background=backColor, /NoData, $
;          NoErase= ((!D.Flags AND 256) EQ 0)
;       OPlot, Findgen(11), Color=dataColor
;       Device, .... ; Whatever you need here to wrap things up properly.
;       Set_Plot, thisDevice
;
; OPTIONAL INPUT PARAMETERS:
;
;       theColor: A string with the "name" of the color. To see a list
;           of the color names available set the NAMES keyword. This may
;           also be a vector of color names. Colors available are these:
;
;           Active            Almond     Antique White        Aquamarine             Beige            Bisque
;             Black              Blue       Blue Violet             Brown         Burlywood        Cadet Blue
;          Charcoal        Chartreuse         Chocolate             Coral   Cornflower Blue          Cornsilk
;           Crimson              Cyan    Dark Goldenrod         Dark Gray        Dark Green        Dark Khaki
;       Dark Orchid          Dark Red       Dark Salmon   Dark Slate Blue         Deep Pink       Dodger Blue
;              Edge              Face         Firebrick      Forest Green             Frame              Gold
;         Goldenrod              Gray             Green      Green Yellow         Highlight          Honeydew
;          Hot Pink        Indian Red             Ivory             Khaki          Lavender        Lawn Green
;       Light Coral        Light Cyan        Light Gray      Light Salmon   Light Sea Green      Light Yellow
;        Lime Green             Linen           Magenta            Maroon       Medium Gray     Medium Orchid
;          Moccasin              Navy             Olive        Olive Drab            Orange        Orange Red
;            Orchid    Pale Goldenrod        Pale Green            Papaya              Peru              Pink
;              Plum       Powder Blue            Purple               Red              Rose        Rosy Brown
;        Royal Blue      Saddle Brown            Salmon       Sandy Brown         Sea Green          Seashell
;          Selected            Shadow            Sienna          Sky Blue        Slate Blue        Slate Gray
;              Snow      Spring Green        Steel Blue               Tan              Teal              Text
;           Thistle            Tomato         Turquoise            Violet        Violet Red             Wheat
;             White            Yellow
;
;           In addition, these system colors are available if a connection to the window system is available.
;
;           Frame   Text   Active   Shadow   Highlight   Edge   Selected   Face
;
;           The color WHITE is used if this parameter is absent or a color name is mis-spelled. To see a list
;           of the color names available in the program, type this:
;
;              IDL> Print, FSC_Color(/Names), Format='(6A18)'
;
;       theColorIndex: The color table index (or vector of indices the same length
;           as the color name vector) where the specified color is loaded. The color table
;           index parameter should always be used if you wish to obtain a color value in a
;           color-decomposition-independent way in your code. See the NORMAL CALLING
;           SEQUENCE for details. If theColor is a vector, and theColorIndex is a scalar,
;           then the colors will be loaded starting at theColorIndex.
;
;        When the BREWER keyword is set, you must use more arbitrary and less descriptive color
;        names. To see a list of those names, use the command above with the BREWER keyword set,
;        or call PICKCOLORNAME with the BREWER keyword set:
;
;               IDL> Print, FSC_Color(/Names, /BREWER), Format='(8A10)'
;               IDL> color = PickColorName(/BREWER)
;
;         Here are the Brewer names:
;
;       WT1       WT2       WT3       WT4       WT5       WT6       WT7       WT8
;      TAN1      TAN2      TAN3      TAN4      TAN5      TAN6      TAN7      TAN8
;      BLK1      BLK2      BLK3      BLK4      BLK5      BLK6      BLK7      BLK8
;      GRN1      GRN2      GRN3      GRN4      GRN5      GRN6      GRN7      GRN8
;      BLU1      BLU2      BLU3      BLU4      BLU5      BLU6      BLU7      BLU8
;      ORG1      ORG2      ORG3      ORG4      ORG5      ORG6      ORG7      ORG8
;      RED1      RED2      RED3      RED4      RED5      RED6      RED7      RED8
;      PUR1      PUR2      PUR3      PUR4      PUR5      PUR6      PUR7      PUR8
;      PBG1      PBG2      PBG3      PBG4      PBG5      PBG6      PBG7      PBG8
;      YGB1      YGB2      YGB3      YGB4      YGB5      YGB6      YGB7      YGB8
;      RYB1      RYB2      RYB3      RYB4      RYB5      RYB6      RYB7      RYB8
;       TG1       TG2       TG3       TG4       TG5       TG6       TG7       TG8
;
;       As of 3 July 2008, the Brewer names are also now available to the user without using 
;       the BREWER keyword. If the BREWER keyword is used, *only* Brewer names are available.
;       
; RETURN VALUE:
;
;       The value that is returned by FSC_Color depends upon the keywords
;       used to call it, on the version of IDL you are using,and on the depth
;       of the display device when the program is invoked. In general,
;       the return value will be either a color index number where the specified
;       color is loaded by the program, or a 24-bit color value that can be
;       decomposed into the specified color on true-color systems. (Or a vector
;       of such numbers.)
;
;       If you are running IDL 5.2 or higher, the program will determine which
;       return value to use, based on the color decomposition state at the time
;       the program is called. If you are running a version of IDL before IDL 5.2,
;       then the program will return the color index number. This behavior can
;       be overruled in all versions of IDL by setting the DECOMPOSED keyword.
;       If this keyword is 0, the program always returns a color index number. If
;       the keyword is 1, the program always returns a 24-bit color value.
;
;       If the TRIPLE keyword is set, the program always returns the color triple,
;       no matter what the current decomposition state or the value of the DECOMPOSED
;       keyword. Normally, the color triple is returned as a 1 by 3 column vector.
;       This is appropriate for loading into a color index with TVLCT:
;
;          IDL> TVLCT, FSC_Color('Yellow', /Triple), !P.Color
;
;       But sometimes (e.g, in object graphics applications) you want the color
;       returned as a row vector. In this case, you should set the ROW keyword
;       as well as the TRIPLE keyword:
;
;          viewobj= Obj_New('IDLgrView', Color=FSC_Color('charcoal', /Triple, /Row))
;
;       If the ALLCOLORS keyword is used, then instead of a single value, modified
;       as described above, then all the color values are returned in an array. In
;       other words, the return value will be either an NCOLORS-element vector of color
;       table index numbers, an NCOLORS-element vector of 24-bit color values, or
;       an NCOLORS-by-3 array of color triples.
;
;       If the NAMES keyword is set, the program returns a vector of
;       color names known to the program.
;
;       If the color index parameter is not used, and a 24-bit value is not being
;       returned, then colorIndex is typically set to !D.Table_Size-1. However,
;       this behavior is changed on 8-bit devices (e.g., the PostScript device,
;       or the Z-graphics buffer) and on 24-bit devices that are *not* using
;       decomposed color. On these devices, the colors are loaded at an
;       offset of !D.Table_Size - ncolors - 2, and the color index parameter reflects
;       the actual index of the color where it will be loaded. This makes it possible
;       to use a formulation as below:
;
;          Plot, data, Color=FSC_Color('Dodger Blue')
;
;       on 24-bit displays *and* in PostScript output! Note that if you specify a color
;       index (the safest thing to do), then it will always be honored.
;
; INPUT KEYWORD PARAMETERS:
;
;       ALLCOLORS: Set this keyword to return indices, or 24-bit values, or color
;              triples, for all the known colors, instead of for a single color.
;
;       BREWER: Set this keyword if you wish to use the Brewer Colors, as defined
;              in this reference:
;
;              http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_intro.html
;              
;              As of 3 July 2008, the BREWER names are always available to the user, with or
;              without this keyword. If the keyword is used, only BREWER names are available.
;
;       DECOMPOSED: Set this keyword to 0 or 1 to force the return value to be
;              a color table index or a 24-bit color value, respectively.
;
;       CHECK_CONNECTION: If this keyword is set, the program will check to see if it can obtain
;              a window connection before it tries to load system colors (which require one). If you
;              think you might be using FSC_COLOR in a cron job, for example, you would want to set this
;              keyword. If there is no window connection, the system colors are not available from the program.
;
;       FILENAME: The string name of an ASCII file that can be opened to read in
;              color values and color names. There should be one color per row
;              in the file. Please be sure there are no blank lines in the file.
;              The format of each row should be:
;
;                  redValue  greenValue  blueValue  colorName
;
;              Color values should be between 0 and 255. Any kind of white-space
;              separation (blank characters, commas, or tabs) are allowed. The color
;              name should be a string, but it should NOT be in quotes. A typical
;              entry into the file would look like this:
;
;                  255   255   0   Yellow
;
;       NAMES: If this keyword is set, the return value of the function is
;              a ncolors-element string array containing the names of the colors.
;              These names would be appropriate, for example, in building
;              a list widget with the names of the colors. If the NAMES
;              keyword is set, the COLOR and INDEX parameters are ignored.
;
;                 listID = Widget_List(baseID, Value=GetColor(/Names), YSize=16)
;
;
;       NODISPLAY: Normally, FSC_COLOR loads "system" colors as part of its palette of colors.
;              In order to do so, it has to create an IDL widget, which in turn has to make
;              a connection to the windowing system. If your program is being run without a 
;              window connection, then this program will fail. If you can live without the system 
;              colors (and most people don't even know they are there, to tell you the truth), 
;              then setting this keyword will keep them from being loaded, and you can run
;              FSC_COLOR without a display. THIS KEYWORD NOW DEPRECIATED IN FAVOR OF CHECK_CONNECTION.
;
;       ROW:   If this keyword is set, the return value of the function when the TRIPLE
;              keyword is set is returned as a row vector, rather than as the default
;              column vector. This is required, for example, when you are trying to
;              use the return value to set the color for object graphics objects. This
;              keyword is completely ignored, except when used in combination with the
;              TRIPLE keyword.
;
;       SELECTCOLOR: Set this keyword if you would like to select the color name with
;              the PICKCOLORNAME program. Selecting this keyword automaticallys sets
;              the INDEX positional parameter. If this keyword is used, any keywords
;              appropriate for PICKCOLORNAME can also be used. If this keyword is used,
;              the first positional parameter can be a color name that will appear in
;              the SelectColor box.
;
;       TRIPLE: Setting this keyword will force the return value of the function to
;              *always* be a color triple, regardless of color decomposition state or
;              visual depth of the machine. The value will be a three-element column
;              vector unless the ROW keyword is also set.
;
;       In addition, any keyword parameter appropriate for PICKCOLORNAME can be used.
;       These include BOTTOM, COLUMNS, GROUP_LEADER, INDEX, and TITLE.
;
; OUTPUT KEYWORD PARAMETERS:
;
;       CANCEL: This keyword is always set to 0, unless that SELECTCOLOR keyword is used.
;              Then it will correspond to the value of the CANCEL output keyword in PICKCOLORNAME.
;
;       COLORSTRUCTURE: This output keyword (if set to a named variable) will return a
;              structure in which the fields will be the known color names (without spaces)
;              and the values of the fields will be either color table index numbers or
;              24-bit color values. If you have specified a vector of color names, then
;              this will be a structure containing just those color names as fields.
;
;       NCOLORS: The number of colors recognized by the program. It will be 104 by default.
;
; COMMON BLOCKS:
;       None.
;
; SIDE EFFECTS:
;       None.
;
; RESTRICTIONS:
;
;   Required programs from the Coyote Library:
;
;      http://www.dfanning.com/programs/error_message.pro
;      http://www.dfanning.com/programs/pickcolorname.pro
;      http://www.dfanning.com/programs/decomposedcolor.pro
;
; EXAMPLE:
;
;       To get drawing colors in a device-decomposed independent way:
;
;           axisColor = FSC_Color("Green", !D.Table_Size-2)
;           backColor = FSC_Color("Charcoal", !D.Table_Size-3)
;           dataColor = FSC_Color("Yellow", !D.Table_Size-4)
;           Plot, Findgen(11), Color=axisColor, Background=backColor, /NoData
;           OPlot, Findgen(11), Color=dataColor
;
;       To set the viewport color in object graphics:
;
;           theView = Obj_New('IDLgrView', Color=FSC_Color('Charcoal', /Triple))
;
;       To change the viewport color later:
;
;           theView->SetProperty, Color=FSC_Color('Antique White', /Triple)
;
;       To load the drawing colors "red", "green", and "yellow" at indices 100-102, type this:
;
;           IDL> TVLCT, FSC_Color(["red", "green", and "yellow"], /Triple), 100
;
; MODIFICATION HISTORY:
;
;       Written by: David W. Fanning, 19 October 2000. Based on previous
;          GetColor program.
;       Fixed a problem with loading colors with TVLCT on a PRINTER device. 13 Mar 2001. DWF.
;       Added the ROW keyword. 30 March 2001. DWF.
;       Added the PICKCOLORNAME code to the file, since I keep forgetting to
;          give it to people. 15 August 2001. DWF.
;       Added ability to specify color names and indices as vectors. 5 Nov 2002. DWF.
;       Fixed a problem with the TRIPLE keyword when specifying a vector of color names. 14 Feb 2003. DWF.
;       Fixed a small problem with the starting index when specifying ALLCOLORS. 24 March 2003. DWF.
;       Added system color names. 23 Jan 2004. DWF
;       Added work-around for WHERE function "feature" when theColor is a one-element array. 22 July 2004. DWF.
;       Added support for 8-bit graphics devices when color index is not specified. 25 August 2004. DWF.
;       Fixed a small problem with creating color structure when ALLCOLORS keyword is set. 26 August 2004. DWF.
;       Extended the color index fix for 8-bit graphics devices on 25 August 2004 to
;         24-bit devices running with color decomposition OFF. I've concluded most of
;         the people using IDL don't have any idea how color works, so I am trying to
;         make it VERY simple, and yet still maintain the power of this program. So now,
;         in general, for most simple plots, you don't have to use the colorindex parameter
;         and you still have a very good chance of getting what you expect in a device-independent
;         manner. Of course, it would be *nice* if you could use that 24-bit display you paid
;         all that money for, but I understand your reluctance. :-)   11 October 2004. DWF.
;       Have renamed the first positional parameter so that this variable doesn't change
;         while the program is running. 7 December 2004. DWF.
;       Fixed an error I introduced on 7 December 2004. Sigh... 7 January 2005. DWF.
;       Added eight new colors. Total now of 104 colors. 11 August 2005. DWF.
;       Modified GUI to display system colors and removed PickColorName code. 13 Dec 2005. DWF.
;       Fixed a problem with colorIndex when SELECTCOLOR keyword was used. 13 Dec 2005. DWF.
;       Fixed a problem with color name synonyms. 19 May 2006. DWF.
;       The previous fix broke the ability to specify several colors at once. Fixed. 24 July 2006. DWF.
;       Updated program to work with 24-bit Z-buffer in IDL 6.4. 11 June 2007. DWF
;       Added the CRONJOB keyword. 07 Feb 2008. DWF.
;       Changed the CRONJOB keyword to NODISPLAY to better reflect its purpose. 7 FEB 2008. DWF.
;       Added the BREWER keyword to allow selection of Brewer Colors. 15 MAY 2008. DWF.
;       Added the CHECK_CONNECTION keyword and depreciated the NODISPLAY keyword for cron jobs. 15 MAY 2008. DWF.
;       Added the BREWER names to the program with or without the BREWER keyword set. 3 JULY 2008. DWF.
;       If color names '0', '1', '2', ..., '255', are used, the colors are taken from the current
;          color table in effect when the program is called. 23 March 2009. DWF.
;       Added the ability to use 24-bit PostScript color, if available. 24 May 2009. DWF.
;       Program relies on DecomposedColor() to determine decomposed state of PostScript device. 24 May 2009. DWF.
;       Mis-spelled variable name prevented color structure from being returned by COLORSTRUCTURE keyword. 14 Oct 2009. DWF.
;-
;******************************************************************************************;
;  Copyright (c) 2008-2009, by Fanning Software Consulting, Inc.                           ;
;  All rights reserved.                                                                    ;
;                                                                                          ;
;  Redistribution and use in source and binary forms, with or without                      ;
;  modification, are permitted provided that the following conditions are met:             ;
;                                                                                          ;
;      * Redistributions of source code must retain the above copyright                    ;
;        notice, this list of conditions and the following disclaimer.                     ;
;      * Redistributions in binary form must reproduce the above copyright                 ;
;        notice, this list of conditions and the following disclaimer in the               ;
;        documentation and/or other materials provided with the distribution.              ;
;      * Neither the name of Fanning Software Consulting, Inc. nor the names of its        ;
;        contributors may be used to endorse or promote products derived from this         ;
;        software without specific prior written permission.                               ;
;                                                                                          ;
;  THIS SOFTWARE IS PROVIDED BY FANNING SOFTWARE CONSULTING, INC. ''AS IS'' AND ANY        ;
;  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES    ;
;  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT     ;
;  SHALL FANNING SOFTWARE CONSULTING, INC. BE LIABLE FOR ANY DIRECT, INDIRECT,             ;
;  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED    ;
;  TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;         ;
;  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND             ;
;  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT              ;
;  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS           ;
;  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.                            ;
;******************************************************************************************;
FUNCTION FSC_Color_Count_Rows, filename, MaxRows = maxrows

    ; This utility routine is used to count the number of
    ; rows in an ASCII data file.
    
    IF N_Elements(maxrows) EQ 0 THEN maxrows = 500L
    IF N_Elements(filename) EQ 0 THEN BEGIN
       filename = Dialog_Pickfile()
       IF filename EQ "" THEN RETURN, -1
    ENDIF
    
    OpenR, lun, filename, /Get_Lun
    
    Catch, theError
    IF theError NE 0 THEN BEGIN
       Catch, /Cancel
       count = count-1
       Free_Lun, lun
       RETURN, count
    ENDIF
    
    RESTART:
    
    count = 1L
    line = ''
    FOR j=count, maxrows DO BEGIN
       ReadF, lun, line
       count = count + 1
    
          ; Try again if you hit MAXROWS without encountering the
          ; end of the file. Double the MAXROWS parameter.
    
       IF j EQ maxrows THEN BEGIN
          maxrows = maxrows * 2
          Point_Lun, lun, 0
          GOTO, RESTART
       ENDIF
    
    ENDFOR
    
    RETURN, -1
    
END ;-------------------------------------------------------------------------------



FUNCTION FSC_Color_Color24, color

   ; This FUNCTION accepts a [red, green, blue] triple that
   ; describes a particular color and returns a 24-bit long
   ; integer that is equivalent to (can be decomposed into)
   ; that color. The triple can be either a row or column
   ; vector of 3 elements or it can be an N-by-3 array of
   ; color triples.

    ON_ERROR, 2
    
    s = Size(color)
    
    IF s[0] EQ 1 THEN BEGIN
       IF s[1] NE 3 THEN Message, 'Input color parameter must be a 3-element vector.'
       RETURN, color[0] + (color[1] * 2L^8) + (color[2] * 2L^16)
    ENDIF ELSE BEGIN
       IF s[2] GT 3 THEN Message, 'Input color parameter must be an N-by-3 array.'
       RETURN, color[*,0] + (color[*,1] * 2L^8) + (color[*,2] * 2L^16)
    ENDELSE

END ;--------------------------------------------------------------------------------------------



FUNCTION FSC_Color, theColour, colorIndex, $
   AllColors=allcolors, $
   Brewer=brewer, $
   Check_Connection=check_connection, $
   ColorStructure=colorStructure, $
   Cancel=cancelled, $
   Decomposed=decomposedState, $
   _Extra=extra, $
   Filename=filename, $
   Names=names, $
   NColors=ncolors, $
   NODISPLAY=nodisplay, $
   Row=row, $
   SelectColor=selectcolor, $
   Triple=triple
   
    ; Return to caller as the default error behavior.
    On_Error, 2

    ; Do you have to check the window connection?
    haveConnection = 1
    IF Keyword_Set(check_connection) THEN BEGIN
    
       ; In CRON jobs, there is no X connection so system colors cannot be supported.
       ; Here is a quick test to see if we can connect to a windowing system. 
       Catch, theError
       IF theError NE 0 THEN BEGIN
          Catch, /CANCEL
          haveConnection = 0
          GOTO, testConnection
       ENDIF
       theWindow = !D.Window
       Window, /FREE, XSIZE=5, YSIZE=5, /PIXMAP
       Catch, /CANCEL
       
       testConnection: ; Come here if you choke on creating a window.
       IF !D.Window NE theWindow THEN BEGIN
          WDelete, !D.Window
          IF theWindow GE 0 THEN WSet, theWindow
       ENDIF
    
    ENDIF    
    
     ; Error handling for the rest of the program.
    Catch, theError
    IF theError NE 0 THEN BEGIN
       Catch, /Cancel
       ok = Error_Message(/Traceback)
       cancelled = 1
       RETURN, !P.Color
    ENDIF
    
    ; I don't want to change the original variable.
    IF N_Elements(theColour) NE 0 THEN theColor = theColour ELSE $
        theColor = Keyword_Set(brewer) ? 'WT1' : 'WHITE'
        
    ; Make sure the color parameter is compressed and an uppercase string.
    varInfo = Size(theColor)
    IF varInfo[varInfo[0] + 1] NE 7 THEN $
       Message, 'The color name parameter must be a string.', /NoName
    theColor = StrUpCase(StrCompress(StrTrim(theColor,2), /Remove_All))
    
    ; Read the first color as bytes. If none of the bytes are less than 48
    ; or greater than 57, then this is a "number" string and you should
    ; assume the current color table is being used.
    bytecheck = Byte(theColor[0])
    i = Where(bytecheck LT 40, lessthan)
    i = Where(bytecheck GT 57, greaterthan)
    IF (lessthan + greaterthan) EQ 0 THEN useCurrentColors = 1 ELSE useCurrentColors = 0
    
    ; Handle depreciated NODISPLAY keyword.
    IF Keyword_Set(nodisplay) THEN haveConnection = 0

    ; Get the decomposed state of the IDL session right now.
    IF N_Elements(decomposedState) EQ 0 THEN BEGIN
       IF Float(!Version.Release) GE 5.2 THEN BEGIN
          IF (!D.Name EQ 'X' OR !D.Name EQ 'WIN' OR !D.Name EQ 'MAC') THEN BEGIN
             Device, Get_Decomposed=decomposedState
          ENDIF ELSE decomposedState = 0
       ENDIF ELSE decomposedState = 0
       IF (Float(!Version.Release) GE 6.4) AND (!D.NAME EQ 'Z') THEN BEGIN
          Device, Get_Decomposed=decomposedState
       ENDIF
    ENDIF ELSE decomposedState = Keyword_Set(decomposedState)
    
    ; Get depth of visual display (and decomposed state for PostScript devices).
    IF (!D.Flags AND 256) NE 0 THEN Device, Get_Visual_Depth=theDepth ELSE theDepth = 8
    IF (Float(!Version.Release) GE 6.4) AND (!D.NAME EQ 'Z') THEN Device, Get_Pixel_Depth=theDepth
    IF (!D.NAME EQ 'PS') AND (Float(!Version.Release) GE 7.1) THEN BEGIN
       decomposedState = DecomposedColor(DEPTH=theDepth)
   ENDIF

    ; Need brewer colors?
    brewer = Keyword_Set(brewer)
    
    ; Load the colors.
    IF N_Elements(filename) NE 0 THEN BEGIN
    
       ; Count the number of rows in the file.
       ncolors = FSC_Color_Count_Rows(filename)
    
       ; Read the data.
       OpenR, lun, filename, /Get_Lun
       rvalue = BytArr(NCOLORS)
       gvalue = BytArr(NCOLORS)
       bvalue = BytArr(NCOLORS)
       colors = StrArr(NCOLORS)
       redvalue = 0B
       greenvalue = 0B
       bluevalue = 0B
       colorvalue = ""
       FOR j=0L, NCOLORS-1 DO BEGIN
          ReadF, lun, redvalue, greenvalue, bluevalue, colorvalue
          rvalue[j] = redvalue
          gvalue[j] = greenvalue
          bvalue[j] = bluevalue
          colors[j] = colorvalue
       ENDFOR
       Free_Lun, lun
    
       ; Trim the colors array of blank characters.
       colors = StrTrim(colors, 2)
    
    ENDIF ELSE BEGIN
    
       ; Set up the color vectors.
       IF Keyword_Set(Brewer) THEN BEGIN
       
           ; Set up the color vectors.
           colors = [ 'WT1', 'WT2', 'WT3', 'WT4', 'WT5', 'WT6', 'WT7', 'WT8']
           rvalue = [  255,   255,   255,   255,   255,   245,   255,   250 ]
           gvalue = [  255,   250,   255,   255,   248,   245,   245,   240 ]
           bvalue = [  255,   250,   240,   224,   220,   220,   238,   230 ]
           colors = [ colors, 'TAN1', 'TAN2', 'TAN3', 'TAN4', 'TAN5', 'TAN6', 'TAN7', 'TAN8']
           rvalue = [ rvalue,   250,   255,    255,    255,    255,    245,    222,    210 ]
           gvalue = [ gvalue,   235,   239,    235,    228,    228,    222,    184,    180 ]
           bvalue = [ bvalue,   215,   213,    205,    196,    181,    179,    135,    140 ]
           colors = [ colors, 'BLK1', 'BLK2', 'BLK3', 'BLK4', 'BLK5', 'BLK6', 'BLK7', 'BLK8']
           rvalue = [ rvalue,   250,   230,    210,    190,    128,     110,    70,       0 ]
           gvalue = [ gvalue,   250,   230,    210,    190,    128,     110,    70,       0 ]
           bvalue = [ bvalue,   250,   230,    210,    190,    128,     110,    70,       0 ]
           colors = [ colors, 'GRN1', 'GRN2', 'GRN3', 'GRN4', 'GRN5', 'GRN6', 'GRN7', 'GRN8']
           rvalue = [ rvalue,   250,   223,    173,    109,     53,     35,      0,       0 ]
           gvalue = [ gvalue,   253,   242,    221,    193,    156,     132,    97,      69 ]
           bvalue = [ bvalue,   202,   167,    142,    115,     83,      67,    52,      41 ]
           colors = [ colors, 'BLU1', 'BLU2', 'BLU3', 'BLU4', 'BLU5', 'BLU6', 'BLU7', 'BLU8']
           rvalue = [ rvalue,   232,   202,    158,     99,     53,     33,      8,       8 ]
           gvalue = [ gvalue,   241,   222,    202,    168,    133,    113,     75,      48 ]
           bvalue = [ bvalue,   250,   240,    225,    211,    191,    181,    147,     107 ]
           colors = [ colors, 'ORG1', 'ORG2', 'ORG3', 'ORG4', 'ORG5', 'ORG6', 'ORG7', 'ORG8']
           rvalue = [ rvalue,   254,    253,    253,    250,    231,    217,    159,    127 ]
           gvalue = [ gvalue,   236,    212,    174,    134,     92,     72,     51,     39 ]
           bvalue = [ bvalue,   217,    171,    107,     52,     12,      1,      3,      4 ]
           colors = [ colors, 'RED1', 'RED2', 'RED3', 'RED4', 'RED5', 'RED6', 'RED7', 'RED8']
           rvalue = [ rvalue,   254,    252,    252,    248,    225,    203,    154,    103 ]
           gvalue = [ gvalue,   232,    194,    146,     97,     45,     24,     12,      0 ]
           bvalue = [ bvalue,   222,    171,    114,     68,     38,     29,     19,     13 ]
           colors = [ colors, 'PUR1', 'PUR2', 'PUR3', 'PUR4', 'PUR5', 'PUR6', 'PUR7', 'PUR8']
           rvalue = [ rvalue,   244,    222,    188,    152,    119,    106,     80,     63 ]
           gvalue = [ gvalue,   242,    221,    189,    148,    108,     82,     32,      0 ]
           bvalue = [ bvalue,   248,    237,    220,    197,    177,    163,    139,    125 ]
           colors = [ colors, 'PBG1', 'PBG2', 'PBG3', 'PBG4', 'PBG5', 'PBG6', 'PBG7', 'PBG8']
           rvalue = [ rvalue,   243,    213,    166,     94,     34,      3,      1,      1 ]
           gvalue = [ gvalue,   234,    212,    189,    164,    138,    129,    101,     70 ]
           bvalue = [ bvalue,   244,    232,    219,    204,    171,    139,     82,     54 ]
           colors = [ colors, 'YGB1', 'YGB2', 'YGB3', 'YGB4', 'YGB5', 'YGB6', 'YGB7', 'YGB8']
           rvalue = [ rvalue,   244,    206,    127,     58,     30,     33,     32,      8 ]
           gvalue = [ gvalue,   250,    236,    205,    175,    125,     95,     48,     29 ]
           bvalue = [ bvalue,   193,    179,    186,    195,    182,    168,    137,     88 ]
           colors = [ colors, 'RYB1', 'RYB2', 'RYB3', 'RYB4', 'RYB5', 'RYB6', 'RYB7', 'RYB8']
           rvalue = [ rvalue,   201,    245,    253,    251,    228,    193,    114,     59 ]
           gvalue = [ gvalue,    35,    121,    206,    253,    244,    228,    171,     85 ]
           bvalue = [ bvalue,    38,    72,     127,    197,    239,    239,    207,    164 ]
           colors = [ colors, 'TG1', 'TG2', 'TG3', 'TG4', 'TG5', 'TG6', 'TG7', 'TG8']
           rvalue = [ rvalue,  84,    163,   197,   220,   105,    51,    13,     0 ]
           gvalue = [ gvalue,  48,    103,   141,   188,   188,   149,   113,    81 ]
           bvalue = [ bvalue,   5,     26,    60,   118,   177,   141,   105,    71 ]
       
       ENDIF ELSE BEGIN
       
           ; Set up the color vectors. Both original and Brewer colors.
           colors= ['White']
           rvalue = [ 255]
           gvalue = [ 255]
           bvalue = [ 255]
           colors = [ colors,   'Snow',     'Ivory','Light Yellow', 'Cornsilk',     'Beige',  'Seashell' ]
           rvalue = [ rvalue,     255,         255,       255,          255,          245,        255 ]
           gvalue = [ gvalue,     250,         255,       255,          248,          245,        245 ]
           bvalue = [ bvalue,     250,         240,       224,          220,          220,        238 ]
           colors = [ colors,   'Linen','Antique White','Papaya',     'Almond',     'Bisque',  'Moccasin' ]
           rvalue = [ rvalue,     250,        250,        255,          255,          255,          255 ]
           gvalue = [ gvalue,     240,        235,        239,          235,          228,          228 ]
           bvalue = [ bvalue,     230,        215,        213,          205,          196,          181 ]
           colors = [ colors,   'Wheat',  'Burlywood',    'Tan', 'Light Gray',   'Lavender','Medium Gray' ]
           rvalue = [ rvalue,     245,        222,          210,      230,          230,         210 ]
           gvalue = [ gvalue,     222,        184,          180,      230,          230,         210 ]
           bvalue = [ bvalue,     179,        135,          140,      230,          250,         210 ]
           colors = [ colors,  'Gray', 'Slate Gray',  'Dark Gray',  'Charcoal',   'Black',  'Honeydew', 'Light Cyan' ]
           rvalue = [ rvalue,      190,      112,          110,          70,         0,         240,          224 ]
           gvalue = [ gvalue,      190,      128,          110,          70,         0,         255,          255 ]
           bvalue = [ bvalue,      190,      144,          110,          70,         0,         255,          240 ]
           colors = [ colors,'Powder Blue',  'Sky Blue', 'Cornflower Blue', 'Cadet Blue', 'Steel Blue','Dodger Blue', 'Royal Blue',  'Blue' ]
           rvalue = [ rvalue,     176,          135,          100,              95,            70,           30,           65,            0 ]
           gvalue = [ gvalue,     224,          206,          149,             158,           130,          144,          105,            0 ]
           bvalue = [ bvalue,     230,          235,          237,             160,           180,          255,          225,          255 ]
           colors = [ colors,  'Navy', 'Pale Green','Aquamarine','Spring Green',  'Cyan' ]
           rvalue = [ rvalue,        0,     152,          127,          0,            0 ]
           gvalue = [ gvalue,        0,     251,          255,        250,          255 ]
           bvalue = [ bvalue,      128,     152,          212,        154,          255 ]
           colors = [ colors, 'Turquoise', 'Light Sea Green', 'Sea Green','Forest Green',  'Teal','Green Yellow','Chartreuse', 'Lawn Green' ]
           rvalue = [ rvalue,      64,          143,               46,          34,             0,      173,           127,         124 ]
           gvalue = [ gvalue,     224,          188,              139,         139,           128,      255,           255,         252 ]
           bvalue = [ bvalue,     208,          143,               87,          34,           128,       47,             0,           0 ]
           colors = [ colors, 'Green', 'Lime Green', 'Olive Drab',  'Olive','Dark Green','Pale Goldenrod']
           rvalue = [ rvalue,      0,        50,          107,        85,            0,          238 ]
           gvalue = [ gvalue,    255,       205,          142,       107,          100,          232 ]
           bvalue = [ bvalue,      0,        50,           35,        47,            0,          170 ]
           colors = [ colors,     'Khaki', 'Dark Khaki', 'Yellow',  'Gold', 'Goldenrod','Dark Goldenrod']
           rvalue = [ rvalue,        240,       189,        255,      255,      218,          184 ]
           gvalue = [ gvalue,        230,       183,        255,      215,      165,          134 ]
           bvalue = [ bvalue,        140,       107,          0,        0,       32,           11 ]
           colors = [ colors,'Saddle Brown',  'Rose',   'Pink', 'Rosy Brown','Sandy Brown', 'Peru']
           rvalue = [ rvalue,     139,          255,      255,        188,        244,        205 ]
           gvalue = [ gvalue,      69,          228,      192,        143,        164,        133 ]
           bvalue = [ bvalue,      19,          225,      203,        143,         96,         63 ]
           colors = [ colors,'Indian Red',  'Chocolate',  'Sienna','Dark Salmon',   'Salmon','Light Salmon' ]
           rvalue = [ rvalue,    205,          210,          160,        233,          250,       255 ]
           gvalue = [ gvalue,     92,          105,           82,        150,          128,       160 ]
           bvalue = [ bvalue,     92,           30,           45,        122,          114,       122 ]
           colors = [ colors,  'Orange',      'Coral', 'Light Coral',  'Firebrick', 'Dark Red', 'Brown',  'Hot Pink' ]
           rvalue = [ rvalue,       255,         255,        240,          178,        139,       165,        255 ]
           gvalue = [ gvalue,       165,         127,        128,           34,          0,        42,        105 ]
           bvalue = [ bvalue,         0,          80,        128,           34,          0,        42,        180 ]
           colors = [ colors, 'Deep Pink',    'Magenta',   'Tomato', 'Orange Red',   'Red', 'Crimson', 'Violet Red' ]
           rvalue = [ rvalue,      255,          255,        255,        255,          255,      220,        208 ]
           gvalue = [ gvalue,       20,            0,         99,         69,            0,       20,         32 ]
           bvalue = [ bvalue,      147,          255,         71,          0,            0,       60,        144 ]
           colors = [ colors,    'Maroon',    'Thistle',       'Plum',     'Violet',    'Orchid','Medium Orchid']
           rvalue = [ rvalue,       176,          216,          221,          238,         218,        186 ]
           gvalue = [ gvalue,        48,          191,          160,          130,         112,         85 ]
           bvalue = [ bvalue,        96,          216,          221,          238,         214,        211 ]
           colors = [ colors,'Dark Orchid','Blue Violet',  'Purple']
           rvalue = [ rvalue,      153,          138,       160]
           gvalue = [ gvalue,       50,           43,        32]
           bvalue = [ bvalue,      204,          226,       240]
           colors = [ colors, 'Slate Blue',  'Dark Slate Blue']
           rvalue = [ rvalue,      106,            72]
           gvalue = [ gvalue,       90,            61]
           bvalue = [ bvalue,      205,           139]
           colors = [ colors, 'WT1', 'WT2', 'WT3', 'WT4', 'WT5', 'WT6', 'WT7', 'WT8']
           rvalue = [ rvalue,  255,   255,   255,   255,   255,   245,   255,   250 ]
           gvalue = [ gvalue,  255,   250,   255,   255,   248,   245,   245,   240 ]
           bvalue = [ bvalue,  255,   250,   240,   224,   220,   220,   238,   230 ]
           colors = [ colors, 'TAN1', 'TAN2', 'TAN3', 'TAN4', 'TAN5', 'TAN6', 'TAN7', 'TAN8']
           rvalue = [ rvalue,   250,   255,    255,    255,    255,    245,    222,    210 ]
           gvalue = [ gvalue,   235,   239,    235,    228,    228,    222,    184,    180 ]
           bvalue = [ bvalue,   215,   213,    205,    196,    181,    179,    135,    140 ]
           colors = [ colors, 'BLK1', 'BLK2', 'BLK3', 'BLK4', 'BLK5', 'BLK6', 'BLK7', 'BLK8']
           rvalue = [ rvalue,   250,   230,    210,    190,    128,     110,    70,       0 ]
           gvalue = [ gvalue,   250,   230,    210,    190,    128,     110,    70,       0 ]
           bvalue = [ bvalue,   250,   230,    210,    190,    128,     110,    70,       0 ]
           colors = [ colors, 'GRN1', 'GRN2', 'GRN3', 'GRN4', 'GRN5', 'GRN6', 'GRN7', 'GRN8']
           rvalue = [ rvalue,   250,   223,    173,    109,     53,     35,      0,       0 ]
           gvalue = [ gvalue,   253,   242,    221,    193,    156,     132,    97,      69 ]
           bvalue = [ bvalue,   202,   167,    142,    115,     83,      67,    52,      41 ]
           colors = [ colors, 'BLU1', 'BLU2', 'BLU3', 'BLU4', 'BLU5', 'BLU6', 'BLU7', 'BLU8']
           rvalue = [ rvalue,   232,   202,    158,     99,     53,     33,      8,       8 ]
           gvalue = [ gvalue,   241,   222,    202,    168,    133,    113,     75,      48 ]
           bvalue = [ bvalue,   250,   240,    225,    211,    191,    181,    147,     107 ]
           colors = [ colors, 'ORG1', 'ORG2', 'ORG3', 'ORG4', 'ORG5', 'ORG6', 'ORG7', 'ORG8']
           rvalue = [ rvalue,   254,    253,    253,    250,    231,    217,    159,    127 ]
           gvalue = [ gvalue,   236,    212,    174,    134,     92,     72,     51,     39 ]
           bvalue = [ bvalue,   217,    171,    107,     52,     12,      1,      3,      4 ]
           colors = [ colors, 'RED1', 'RED2', 'RED3', 'RED4', 'RED5', 'RED6', 'RED7', 'RED8']
           rvalue = [ rvalue,   254,    252,    252,    248,    225,    203,    154,    103 ]
           gvalue = [ gvalue,   232,    194,    146,     97,     45,     24,     12,      0 ]
           bvalue = [ bvalue,   222,    171,    114,     68,     38,     29,     19,     13 ]
           colors = [ colors, 'PUR1', 'PUR2', 'PUR3', 'PUR4', 'PUR5', 'PUR6', 'PUR7', 'PUR8']
           rvalue = [ rvalue,   244,    222,    188,    152,    119,    106,     80,     63 ]
           gvalue = [ gvalue,   242,    221,    189,    148,    108,     82,     32,      0 ]
           bvalue = [ bvalue,   248,    237,    220,    197,    177,    163,    139,    125 ]
           colors = [ colors, 'PBG1', 'PBG2', 'PBG3', 'PBG4', 'PBG5', 'PBG6', 'PBG7', 'PBG8']
           rvalue = [ rvalue,   243,    213,    166,     94,     34,      3,      1,      1 ]
           gvalue = [ gvalue,   234,    212,    189,    164,    138,    129,    101,     70 ]
           bvalue = [ bvalue,   244,    232,    219,    204,    171,    139,     82,     54 ]
           colors = [ colors, 'YGB1', 'YGB2', 'YGB3', 'YGB4', 'YGB5', 'YGB6', 'YGB7', 'YGB8']
           rvalue = [ rvalue,   244,    206,    127,     58,     30,     33,     32,      8 ]
           gvalue = [ gvalue,   250,    236,    205,    175,    125,     95,     48,     29 ]
           bvalue = [ bvalue,   193,    179,    186,    195,    182,    168,    137,     88 ]
           colors = [ colors, 'RYB1', 'RYB2', 'RYB3', 'RYB4', 'RYB5', 'RYB6', 'RYB7', 'RYB8']
           rvalue = [ rvalue,   201,    245,    253,    251,    228,    193,    114,     59 ]
           gvalue = [ gvalue,    35,    121,    206,    253,    244,    228,    171,     85 ]
           bvalue = [ bvalue,    38,    72,     127,    197,    239,    239,    207,    164 ]
           colors = [ colors, 'TG1', 'TG2', 'TG3', 'TG4', 'TG5', 'TG6', 'TG7', 'TG8']
           rvalue = [ rvalue,  84,    163,   197,   220,   105,    51,    13,     0 ]
           gvalue = [ gvalue,  48,    103,   141,   188,   188,   149,   113,    81 ]
           bvalue = [ bvalue,   5,     26,    60,   118,   177,   141,   105,    71 ]
       ENDELSE
    ENDELSE
    
    ; Don't load system colors if you are doing this without a window connection.
    IF haveConnection THEN BEGIN
    
       ; Add system color names for IDL version 5.6 and higher.
       IF Float(!Version.Release) GE 5.6 THEN BEGIN
       
          tlb = Widget_Base()
          sc = Widget_Info(tlb, /System_Colors)
          Widget_Control, tlb, /Destroy
          frame = sc.window_frame
          text = sc.window_text
          active = sc.active_border
          shadow = sc.shadow_3d
          highlight = sc.light_3d
          edge = sc.light_edge_3d
          selected = sc.highlight
          face = sc.face_3d
          colors  = [colors,  'Frame',  'Text',  'Active',  'Shadow']
          rvalue =  [rvalue,   frame[0], text[0], active[0], shadow[0]]
          gvalue =  [gvalue,   frame[1], text[1], active[1], shadow[1]]
          bvalue =  [bvalue,   frame[2], text[2], active[2], shadow[2]]
          colors  = [colors,  'Highlight',  'Edge',  'Selected',  'Face']
          rvalue =  [rvalue,   highlight[0], edge[0], selected[0], face[0]]
          gvalue =  [gvalue,   highlight[1], edge[1], selected[1], face[1]]
          bvalue =  [bvalue,   highlight[2], edge[2], selected[2], face[2]]
       
       ENDIF
       
    ENDIF
    
    ; Load the colors from the current color table, if you need them.
    IF useCurrentColors THEN BEGIN
        TVLCT, rrr, ggg, bbb, /GET
        IF decomposedState EQ 0 THEN BEGIN
            colors = SIndgen(256)
            rvalue = rrr
            gvalue = ggg
            bvalue = bbb           
        ENDIF ELSE BEGIN
            colors = [colors, SIndgen(256)]
            rvalue = [rvalue, rrr]
            gvalue = [gvalue, ggg]
            bvalue = [bvalue, bbb]
        ENDELSE
    ENDIF
    ; Make sure we are looking at compressed, uppercase names.
    colors = StrUpCase(StrCompress(StrTrim(colors,2), /Remove_All))

    ; Check synonyms of color names.
    FOR j=0, N_Elements(theColor)-1 DO BEGIN
       IF StrUpCase(theColor[j]) EQ 'GREY' THEN theColor[j] = 'GRAY'
       IF StrUpCase(theColor[j]) EQ 'LIGHTGREY' THEN theColor[j] = 'LIGHTGRAY'
       IF StrUpCase(theColor[j]) EQ 'MEDIUMGREY' THEN theColor[j] = 'MEDIUMGRAY'
       IF StrUpCase(theColor[j]) EQ 'SLATEGREY' THEN theColor[j] = 'SLATEGRAY'
       IF StrUpCase(theColor[j]) EQ 'DARKGREY' THEN theColor[j] = 'DARKGRAY'
       IF StrUpCase(theColor[j]) EQ 'AQUA' THEN theColor[j] = 'AQUAMARINE'
       IF StrUpCase(theColor[j]) EQ 'SKY' THEN theColor[j] = 'SKYBLUE'
       IF StrUpCase(theColor[j]) EQ 'NAVYBLUE' THEN theColor[j] = 'NAVY'
       IF StrUpCase(theColor[j]) EQ 'CORNFLOWER' THEN theColor[j] = 'CORNFLOWERBLUE'
       IF StrUpCase(theColor[j]) EQ 'BROWN' THEN theColor[j] = 'SIENNA'
    ENDFOR
    
    ; How many colors do we have?
    ncolors = N_Elements(colors)
    
    ; Check for offset.
    IF (theDepth EQ 8) OR (decomposedState EQ 0) THEN offset = !D.Table_Size - ncolors - 2 ELSE offset = 0
    IF (useCurrentColors) AND (decomposedState EQ 0) THEN offset = 0
        
    ; Did the user want to select a color name? If so, we set
    ; the color name and color index, unless the user provided
    ; them. In the case of a single positional parameter, we treat
    ; this as the color index number as long as it is not a string.
    cancelled = 0.0
    IF Keyword_Set(selectcolor) THEN BEGIN
    
       CASE N_Params() OF
          0: BEGIN
             theColor = PickColorName(Filename=filename, _Extra=extra, Cancel=cancelled, BREWER=brewer)
             IF cancelled THEN RETURN, !P.Color
             IF theDepth GT 8 AND (decomposedState EQ 1) THEN BEGIN
                   colorIndex = !P.Color < (!D.Table_Size - 1)
             ENDIF ELSE BEGIN
                   colorIndex = Where(StrUpCase(colors) EQ StrUpCase(StrCompress(theColor, /Remove_All)), count) + offset
                   colorIndex = colorIndex[0]
                   IF count EQ 0 THEN Message, 'Cannot find color: ' + StrUpCase(theColor), /NoName
             ENDELSE
    
             END
          1: BEGIN
             IF Size(theColor, /TName) NE 'STRING' THEN BEGIN
                colorIndex = theColor
                theColor = brewer ? 'WT1' : 'White'
             ENDIF ELSE colorIndex = !P.Color < 255
             theColor = PickColorName(theColor, Filename=filename, _Extra=extra, Cancel=cancelled, BREWER=brewer)
             IF cancelled THEN RETURN, !P.Color
             END
          2: BEGIN
             theColor = PickColorName(theColor, Filename=filename, _Extra=extra, Cancel=cancelled, BREWER=brewer)
             IF cancelled THEN RETURN, !P.Color
             END
       ENDCASE
    ENDIF
    
    ; Make sure you have a color name and color index.
    CASE N_Elements(theColor) OF
       0: BEGIN
             theColor = brewer ? 'WT1' : 'White'
             IF N_Elements(colorIndex) EQ 0 THEN BEGIN
                IF theDepth GT 8 THEN BEGIN
                   colorIndex = !P.Color < (!D.Table_Size - 1)
                ENDIF ELSE BEGIN
                   colorIndex = Where(colors EQ theColor, count) + offset
                   colorIndex = colorIndex[0]
                   IF count EQ 0 THEN Message, 'Cannot find color: ' + theColor, /NoName
                ENDELSE
             ENDIF ELSE colorIndex = 0 > colorIndex < (!D.Table_Size - 1)
          ENDCASE
    
       1: BEGIN
             type = Size(theColor, /TNAME)
             IF type NE 'STRING' THEN Message, 'The color must be expressed as a color name.'
             theColor = theColor[0] ; Make it a scalar or you run into a WHERE function "feature". :-(
             IF N_Elements(colorIndex) EQ 0 THEN BEGIN
                IF (theDepth GT 8) AND (decomposedState EQ 1) THEN BEGIN
                   colorIndex = !P.Color < (!D.Table_Size - 1)
                ENDIF ELSE BEGIN
                   colorIndex = Where(colors EQ theColor, count) + offset
                   colorIndex = colorIndex[0]
                   IF count EQ 0 THEN Message, 'Cannot find color: ' + theColor, /NoName
                ENDELSE
             ENDIF ELSE colorIndex = 0 > colorIndex < (!D.Table_Size - 1)
             ENDCASE
    
       ELSE: BEGIN
             type = Size(theColor, /TNAME)
             IF type NE 'STRING' THEN Message, 'The colors must be expressed as color names.'
             ncolors = N_Elements(theColor)
             CASE N_Elements(colorIndex) OF
                0: colorIndex = Indgen(ncolors) + (!D.Table_Size - (ncolors + 1))
                1: colorIndex = Indgen(ncolors) + colorIndex
                ELSE: IF N_Elements(colorIndex) NE ncolors THEN $
                   Message, 'Index vector must be the same length as color name vector.'
             ENDCASE
    
                ; Did the user want color triples?
    
             IF Keyword_Set(triple) THEN BEGIN
                colors = LonArr(ncolors, 3)
                FOR j=0,ncolors-1 DO colors[j,*] = FSC_Color(theColor[j], colorIndex[j], Filename=filename, $
                   Decomposed=decomposedState, /Triple, BREWER=brewer)
                RETURN, colors
             ENDIF ELSE BEGIN
                colors = LonArr(ncolors)
                FOR j=0,ncolors-1 DO colors[j] = FSC_Color(theColor[j], colorIndex[j], Filename=filename, $
                   Decomposed=decomposedState, BREWER=brewer)
                RETURN, colors
            ENDELSE
          END
    ENDCASE
    
    ; Did the user ask for the color names? If so, return them now.
    IF Keyword_Set(names) THEN RETURN, Reform(colors, 1, ncolors)
    
    ; Process the color names.
    theNames = StrUpCase( StrCompress(colors, /Remove_All ) )
    
    ; Find the asked-for color in the color names array.
    theIndex = Where(theNames EQ StrUpCase(StrCompress(theColor, /Remove_All)), foundIt)
    theIndex = theIndex[0]
    
    ; If the color can't be found, report it and continue with
    ; the first color in the color names array.
    IF foundIt EQ 0 THEN BEGIN
       Message, "Can't find color " + theColor + ". Substituting " + StrUpCase(colors[0]) + ".", /Informational
       theColor = theNames[0]
       theIndex = 0
    ENDIF
    
    ; Get the color triple for this color.
    r = rvalue[theIndex]
    g = gvalue[theIndex]
    b = bvalue[theIndex]
    
    ; Did the user want a color triple? If so, return it now.
    IF Keyword_Set(triple) THEN BEGIN
       IF Keyword_Set(allcolors) THEN BEGIN
          IF Keyword_Set(row) THEN RETURN, Transpose([[rvalue], [gvalue], [bvalue]]) ELSE RETURN, [[rvalue], [gvalue], [bvalue]]
       ENDIF ELSE BEGIN
          IF Keyword_Set(row) THEN RETURN, [r, g, b] ELSE RETURN, [[r], [g], [b]]
       ENDELSE
    ENDIF
    
    ; Otherwise, we are going to return either an index
    ; number where the color has been loaded, or a 24-bit
    ; value that can be decomposed into the proper color.
    IF decomposedState THEN BEGIN
    
       ; Need a color structure?
       IF Arg_Present(colorStructure) THEN BEGIN
          theColors = FSC_Color_Color24([[rvalue], [gvalue], [bvalue]])
          colorStructure = Create_Struct(theNames[0], theColors[0])
          FOR j=1, ncolors-1 DO colorStructure = Create_Struct(colorStructure, theNames[j], theColors[j])
       ENDIF
    
       IF Keyword_Set(allcolors) THEN BEGIN
          RETURN, FSC_Color_Color24([[rvalue], [gvalue], [bvalue]])
       ENDIF ELSE BEGIN
          RETURN, FSC_Color_Color24([r, g, b])
       ENDELSE
    
    ENDIF ELSE BEGIN
    
       IF Keyword_Set(allcolors) THEN BEGIN
    
          ; Need a color structure?
          IF Arg_Present(colorStructure) THEN BEGIN
             allcolorIndex = !D.Table_Size - ncolors - 2
             IF allcolorIndex LT 0 THEN $
                Message, 'Number of colors exceeds available color table values. Returning.', /NoName
             IF (allcolorIndex + ncolors) GT 255 THEN $
                Message, 'Number of colors exceeds available color table indices. Returning.', /NoName
             theColors = IndGen(ncolors) + allcolorIndex
             colorStructure = Create_Struct(theNames[0],  theColors[0])
             FOR j=1, ncolors-1 DO colorStructure = Create_Struct(colorStructure, theNames[j], theColors[j])
          ENDIF
    
          IF N_Elements(colorIndex) EQ 0 THEN colorIndex = !D.Table_Size - ncolors - 2
          IF colorIndex LT 0 THEN $
             Message, 'Number of colors exceeds available color table values. Returning.', /NoName
          IF (colorIndex + ncolors) GT 255 THEN BEGIN
             colorIndex = !D.Table_Size - ncolors - 2
          ENDIF
          IF !D.Name NE 'PRINTER' THEN TVLCT, rvalue, gvalue, bvalue, colorIndex
          RETURN, IndGen(ncolors) + colorIndex
       ENDIF ELSE BEGIN
    
          ; Need a color structure?
          IF Arg_Present(colorStructure) THEN BEGIN
             colorStructure = Create_Struct(theColor,  colorIndex)
          ENDIF
    
          IF !D.Name NE 'PRINTER' THEN TVLCT, rvalue[theIndex], gvalue[theIndex], bvalue[theIndex], colorIndex
          RETURN, colorIndex
       ENDELSE
    
    
    ENDELSE

END ;-------------------------------------------------------------------------------------------------------
PRO rnd_filename,filename
;
; will generate a random filename 
;
;n=10
;digits=fix(randomu(seed,n)*100)
;str=''
;for i=0,n-1,1 do str=str+string(digits(i))
;str=strcompress(str,/remove_all)+'.randomfile'
;filename=str
filename=strcompress(string(long(randomu(seed)*1000000))+'.randomfile',/remove_all)
return
end
FUNCTION get_file_size,file
rnd_filename,size_filename
spawn,'wc '+file+' > '+size_filename
n=0L
openr,luin,size_filename, /get_lun
readf,luin,n
close,luin
free_lun,luin
spawn,'rm '+size_filename
get_file_size=n
return,get_file_size
end
FUNCTION get_data,filename
n=get_file_size(filename)
rnd_filename,size_filename
spawn,'wc '+filename+' > '+size_filename
get_lun,uuu
openr,uuu,size_filename
nn=0L
m=0L
readf,uuu,nn,m
close,uuu
free_lun,uuu
ncols=double(m)/double(nn)
if (ncols ne fix(ncols)) then begin
	print,ncols,fix(ncols),' while reading ',filename
	print,' check out the file "size_filename"'
	spawn,' cat '+size_filename
	stop
endif
data=dblarr(ncols,n)
get_lun,uuu
openr,uuu,filename
readf,uuu,data
close,uuu
free_lun,uuu
get_data=data
spawn,'rm '+size_filename
return,get_data
end
; $Id: caldat.pro,v 1.18 2001/01/15 22:28:00 scottm Exp $
;
; Copyright (c) 1992-2001, Research Systems, Inc.  All rights reserved.
;	Unauthorized reproduction prohibited.
;

;+
; NAME:
;	CALDAT
;
; PURPOSE:
;	Return the calendar date and time given julian date.
;	This is the inverse of the function JULDAY.
; CATEGORY:
;	Misc.
;
; CALLING SEQUENCE:
;	CALDAT, Julian, Month, Day, Year, Hour, Minute, Second
;	See also: julday, the inverse of this function.
;
; INPUTS:
;	JULIAN contains the Julian Day Number (which begins at noon) of the
;	specified calendar date.  It should be a long integer.
; OUTPUTS:
;	(Trailing parameters may be omitted if not required.)
;	MONTH:	Number of the desired month (1 = January, ..., 12 = December).
;
;	DAY:	Number of day of the month.
;
;	YEAR:	Number of the desired year.
;
;	HOUR:	Hour of the day
;	Minute: Minute of the day
;	Second: Second (and fractions) of the day.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	Accuracy using IEEE double precision numbers is approximately
;	1/10000th of a second.
;
; MODIFICATION HISTORY:
;	Translated from "Numerical Recipies in C", by William H. Press,
;	Brian P. Flannery, Saul A. Teukolsky, and William T. Vetterling.
;	Cambridge University Press, 1988 (second printing).
;
;	DMS, July 1992.
;	DMS, April 1996, Added HOUR, MINUTE and SECOND keyword
;	AB, 7 December 1997, Generalized to handle array input.
;	AB, 3 January 2000, Make seconds output as DOUBLE in array output.
;-
;
pro CALDAT, julian, month, day, year, hour, minute, second

COMPILE_OPT idl2

	ON_ERROR, 2		; Return to caller if errors

	nParam = N_PARAMS()
	IF (nParam LT 1) THEN MESSAGE,'Incorrect number of arguments.'

	min_julian = -1095
	max_julian = 1827933925
	minn = MIN(julian, MAX=maxx)
	IF (minn LT min_julian) OR (maxx GT max_julian) THEN MESSAGE, $
		'Value of Julian date is out of allowed range.'

	igreg = 2299161L    ;Beginning of Gregorian calendar
	julLong = FLOOR(julian + 0.5d)   ;Better be long
	minJul = MIN(julLong)

	IF (minJul GE igreg) THEN BEGIN  ; all are Gregorian
		jalpha = LONG(((julLong - 1867216L) - 0.25d) / 36524.25d)
		ja = julLong + 1L + jalpha - long(0.25d * jalpha)
	ENDIF ELSE BEGIN
		ja = julLong
		gregChange = WHERE(julLong ge igreg, ngreg)
		IF (ngreg GT 0) THEN BEGIN
    		jalpha = long(((julLong[gregChange] - 1867216L) - 0.25d) / 36524.25d)
    		ja[gregChange] = julLong[gregChange] + 1L + jalpha - long(0.25d * jalpha)
		ENDIF
	ENDELSE
	jalpha = -1  ; clear memory

	jb = TEMPORARY(ja) + 1524L
	jc = long(6680d + ((jb-2439870L)-122.1d0)/365.25d)
	jd = long(365d * jc + (0.25d * jc))
	je = long((jb - jd) / 30.6001d)

	day = TEMPORARY(jb) - TEMPORARY(jd) - long(30.6001d * je)
	month = TEMPORARY(je) - 1L
	month = ((TEMPORARY(month) - 1L) MOD 12L) + 1L
	year = TEMPORARY(jc) - 4715L
	year = TEMPORARY(year) - (month GT 2)
	year = year - (year LE 0)

; see if we need to do hours, minutes, seconds
	IF (nParam GT 4) THEN BEGIN
		fraction = julian + 0.5d - TEMPORARY(julLong)
		hour = floor(fraction * 24d)
		fraction = TEMPORARY(fraction) - hour/24d
		minute = floor(fraction*1440d)
		second = (TEMPORARY(fraction) - minute/1440d) * 86400d
	ENDIF

; if julian is an array, reform all output to correct dimensions
	IF (SIZE(julian,/N_DIMENSION) GT 0) THEN BEGIN
		dimensions = SIZE(julian,/DIMENSION)
		month = REFORM(month,dimensions)
		day = REFORM(day,dimensions)
		year = REFORM(year,dimensions)
		IF (nParam GT 4) THEN BEGIN
			hour = REFORM(hour,dimensions)
			minute = REFORM(minute,dimensions)
			second = REFORM(second,dimensions)
		ENDIF
	ENDIF

END
; $Id: deriv.pro,v 1.8 2001/01/15 22:28:02 scottm Exp $
;
; Copyright (c) 1984-2001, Research Systems, Inc.  All rights reserved.
;	Unauthorized reproduction prohibited.
;

Function Deriv, X, Y
;+
; NAME:
;	DERIV
;
; PURPOSE:
;	Perform numerical differentiation using 3-point, Lagrangian 
;	interpolation.
;
; CATEGORY:
;	Numerical analysis.
;
; CALLING SEQUENCE:
;	Dy = Deriv(Y)	 	;Dy(i)/di, point spacing = 1.
;	Dy = Deriv(X, Y)	;Dy/Dx, unequal point spacing.
;
; INPUTS:
;	Y:  Variable to be differentiated.
;	X:  Variable to differentiate with respect to.  If omitted, unit 
;	    spacing for Y (i.e., X(i) = i) is assumed.
;
; OPTIONAL INPUT PARAMETERS:
;	As above.
;
; OUTPUTS:
;	Returns the derivative.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;	See Hildebrand, Introduction to Numerical Analysis, Mc Graw
;	Hill, 1956.  Page 82.
;
; MODIFICATION HISTORY:
;	Written, DMS, Aug, 1984.
;	Corrected formula for points with unequal spacing.  DMS, Nov, 1999.
;-
;
; on_error,2              ;Return to caller if an error occurs
n = n_elements(x)
if n lt 3 then message, 'Parameters must have at least 3 points'

if (n_params(0) ge 2) then begin
    if n ne n_elements(y) then message,'Vectors must have same size'

;df/dx = y0*(2x-x1-x2)/(x01*x02)+y1*(2x-x0-x2)/(x10*x12)+y2*(2x-x0-x1)/(x20*x21)
; Where: x01 = x0-x1, x02 = x0-x2, x12 = x1-x2, etc.
    
    type = size(x, /type)       ;If not floating type, ensure floating...
    if (type ne 4) and (type ne 5) and (type ne 6) and (type ne 9) then begin
        xx = float(x)
        x12 = xx - shift(xx,-1) ;x1 - x2
        x01 = shift(xx,1) - xx  ;x0 - x1
        x02 = shift(xx,1) - shift(xx,-1) ;x0 - x2
    endif else begin            ;Already floating or double
        x12 = x - shift(x,-1)   ;x1 - x2
        x01 = shift(x,1) - x    ;x0 - x1
        x02 = shift(x,1) - shift(x,-1) ;x0 - x2
    endelse

    d = shift(y,1) * (x12 / (x01*x02)) + $ ;Middle points
      y * (1./x12 - 1./x01) - $
      shift(y,-1) * (x01 / (x02 * x12))
; Formulae for the first and last points:
    d[0] = y[0] * (x01[1]+x02[1])/(x01[1]*x02[1]) - $ ;First point
      y[1] * x02[1]/(x01[1]*x12[1]) + $
      y[2] * x01[1]/(x02[1]*x12[1])
    n2 = n-2
    d[n-1] = -y[n-3] * x12[n2]/(x01[n2]*x02[n2]) + $ ;Last point
      y[n-2] * x02[n2]/(x01[n2]*x12[n2]) - $
      y[n-1] * (x02[n2]+x12[n2]) / (x02[n2]*x12[n2])

endif else begin                ;Equally spaced point case

    d = (shift(x,-1) - shift(x,1))/2.
    d[0] = (-3.0*x[0] + 4.0*x[1] - x[2])/2.
    d[n-1] = (3.*x[n-1] - 4.*x[n-2] + x[n-3])/2.
endelse
return, d
end
PRO CT2LST, lst, lng, tz, tme, day, mon, year
;+
; NAME:
;     CT2LST
; PURPOSE:
;     To convert from Local Civil Time to Local Mean Sidereal Time.
;
; CALLING SEQUENCE:
;     CT2LST, Lst, Lng, Tz, Time, [Day, Mon, Year] 
;                       or
;     CT2LST, Lst, Lng, dummy, JD
;
; INPUTS:
;     Lng  - The longitude in degrees (east of Greenwich) of the place for 
;            which the local sidereal time is desired, scalar.   The Greenwich 
;            mean sidereal time (GMST) can be found by setting Lng = 0.
;     Tz  - The time zone of the site in hours.  Use this to easily account 
;            for Daylight Savings time (e.g. 4=EDT, 5 = EST/CDT), scalar
;            This parameter is not needed (and ignored) if Julian date is 
;            supplied.
;     Time or JD  - If more than four parameters are specified, then this is 
;               the time of day of the specified date in decimal hours.  If 
;               exactly four parameters are specified, then this is the 
;               Julian date of time in question, scalar or vector
;
; OPTIONAL INPUTS:
;      Day -  The day of the month (1-31),integer scalar or vector
;      Mon -  The month, in numerical format (1-12), integer scalar or 
;      Year - The year (e.g. 1987)
;
; OUTPUTS:
;       Lst   The Local Sidereal Time for the date/time specified in hours.
;
; RESTRICTIONS:
;       If specified, the date should be in numerical form.  The year should
;       appear as yyyy.
;
; PROCEDURE:
;       The Julian date of the day and time is question is used to determine
;       the number of days to have passed since 0 Jan 2000.  This is used
;       in conjunction with the GST of that date to extrapolate to the current
;       GST; this is then used to get the LST.    See Astronomical Algorithms
;       by Jean Meeus, p. 84 (Eq. 11-4) for the constants used.
;
; EXAMPLE:
;       Find the Greenwich mean sidereal time (GMST) on 1987 April 10, 19h21m UT
;
;       For GMST, we set lng=0, and for UT we set Tz = 0
;
;       IDL> CT2LST, lst, 0, 0,ten(19,21), 10, 4, 1987
;
;               ==> lst =  8.5825249 hours  (= 8h 34m 57.0896s)
;
;       The Web site  http://tycho.usno.navy.mil/sidereal.html contains more
;       info on sidereal time, as well as an interactive calculator.
; PROCEDURES USED:
;       jdcnv - Convert from year, month, day, hour to julian date
;
; MODIFICATION HISTORY:
;     Adapted from the FORTRAN program GETSD by Michael R. Greason, STX, 
;               27 October 1988.
;     Use IAU 1984 constants Wayne Landsman, HSTX, April 1995, results 
;               differ by about 0.1 seconds  
;     Converted to IDL V5.0   W. Landsman   September 1997
;     Longitudes measured *east* of Greenwich   W. Landsman    December 1998
;-
 On_error,2

 if N_params() LT 3 THEN BEGIN
        print,'Syntax - CT2LST, Lst, Lng, Tz, Time, Day, Mon, Year' 
        print,'                 or'
        print,'         CT2LST, Lst, Lng, Tz, JD'
        return
 endif
;                            If all parameters were given, then compute
;                            the Julian date; otherwise assume it is stored
;                            in Time.
;

 IF N_params() gt 4 THEN BEGIN
   time = tme + tz
   jdcnv, year, mon, day, time, jd 
 ENDIF ELSE jd = double(tme)
;
;                            Useful constants, see Meeus, p.84
;
 c = [280.46061837d0, 360.98564736629d0, 0.000387933d0, 38710000.0 ]
 jd2000 = 2451545.0D0
 t0 = jd - jd2000
 t = t0/36525
;
;                            Compute GST in seconds.
;
 theta = c[0] + (c[1] * t0) + t^2*(c[2] - t/ c[3] )
;
;                            Compute LST in hours.
;
 lst = ( theta + double(lng))/15.0d
 neg = where(lst lt 0.0D0, n)
 if n gt 0 then lst[neg] = 24.D0 + (lst[neg] mod 24)
 lst = lst mod 24.D0
;   
 RETURN
 END
function premat, equinox1, equinox2, FK4 = FK4
;+
; NAME:
;       PREMAT
; PURPOSE:
;       Return the precession matrix needed to go from EQUINOX1 to EQUINOX2.  
; EXPLANTION:
;       This matrix is used by the procedures PRECESS and BARYVEL to precess 
;       astronomical coordinates
;
; CALLING SEQUENCE:
;       matrix = PREMAT( equinox1, equinox2, [ /FK4 ] )
;
; INPUTS:
;       EQUINOX1 - Original equinox of coordinates, numeric scalar.  
;       EQUINOX2 - Equinox of precessed coordinates.
;
; OUTPUT:
;      matrix - double precision 3 x 3 precession matrix, used to precess
;               equatorial rectangular coordinates
;
; OPTIONAL INPUT KEYWORDS:
;       /FK4   - If this keyword is set, the FK4 (B1950.0) system precession
;               angles are used to compute the precession matrix.   The 
;               default is to use FK5 (J2000.0) precession angles
;
; EXAMPLES:
;       Return the precession matrix from 1950.0 to 1975.0 in the FK4 system
;
;       IDL> matrix = PREMAT( 1950.0, 1975.0, /FK4)
;
; PROCEDURE:
;       FK4 constants from "Computational Spherical Astronomy" by Taff (1983), 
;       p. 24. (FK4). FK5 constants from "Astronomical Almanac Explanatory
;       Supplement 1992, page 104 Table 3.211.1.
;
; REVISION HISTORY
;       Written, Wayne Landsman, HSTX Corporation, June 1994
;       Converted to IDL V5.0   W. Landsman   September 1997
;-    
  On_error,2                                           ;Return to caller

  npar = N_params()

   if ( npar LT 2 ) then begin 

     print,'Syntax - PREMAT, equinox1, equinox2, /FK4]'
     return,-1 

  endif 

  deg_to_rad = !DPI/180.0d
  sec_to_rad = deg_to_rad/3600.d0

   t = 0.001d0*( equinox2 - equinox1)

 if not keyword_set( FK4 )  then begin  
           st = 0.001d0*( equinox1 - 2000.d0)
;  Compute 3 rotation angles
           A = sec_to_rad * T * (23062.181D0 + ST*(139.656D0 +0.0139D0*ST) $
            + T*(30.188D0 - 0.344D0*ST+17.998D0*T))

           B = sec_to_rad * T * T * (79.280D0 + 0.410D0*ST + 0.205D0*T) + A

        C = sec_to_rad * T * (20043.109D0 - ST*(85.33D0 + 0.217D0*ST) $
              + T*(-42.665D0 - 0.217D0*ST -41.833D0*T))

 endif else begin  

           st = 0.001d0*( equinox1 - 1900.d0)
;  Compute 3 rotation angles

           A = sec_to_rad * T * (23042.53D0 + ST*(139.75D0 +0.06D0*ST) $
            + T*(30.23D0 - 0.27D0*ST+18.0D0*T))

           B = sec_to_rad * T * T * (79.27D0 + 0.66D0*ST + 0.32D0*T) + A

           C = sec_to_rad * T * (20046.85D0 - ST*(85.33D0 + 0.37D0*ST) $
              + T*(-42.67D0 - 0.37D0*ST -41.8D0*T))

 endelse  

  sina = sin(a) &  sinb = sin(b)  & sinc = sin(c)
  cosa = cos(a) &  cosb = cos(b)  & cosc = cos(c)

  r = dblarr(3,3)
  r[0,0] = [ cosa*cosb*cosc-sina*sinb, sina*cosb+cosa*sinb*cosc,  cosa*sinc]
  r[0,1] = [-cosa*sinb-sina*cosb*cosc, cosa*cosb-sina*sinb*cosc, -sina*sinc]
  r[0,2] = [-cosb*sinc, -sinb*sinc, cosc]

  return,r
  end
pro precess, ra, dec, equinox1, equinox2, PRINT = print, FK4 = FK4, $
        RADIAN=radian
;+
; NAME:
;      PRECESS
; PURPOSE:
;      Precess coordinates from EQUINOX1 to EQUINOX2.  
; EXPLANATION:
;      For interactive display, one can use the procedure ASTRO which calls 
;      PRECESS or use the /PRINT keyword.   The default (RA,DEC) system is 
;      FK5 based on epoch J2000.0 but FK4 based on B1950.0 is available via 
;      the /FK4 keyword.
;
;      Use BPRECESS and JPRECESS to convert between FK4 and FK5 systems
; CALLING SEQUENCE:
;      PRECESS, ra, dec, [ equinox1, equinox2, /PRINT, /FK4, /RADIAN ]
;
; INPUT - OUTPUT:
;      RA - Input right ascension (scalar or vector) in DEGREES, unless the 
;              /RADIAN keyword is set
;      DEC - Input declination in DEGREES (scalar or vector), unless the 
;              /RADIAN keyword is set
;              
;      The input RA and DEC are modified by PRECESS to give the 
;      values after precession.
;
; OPTIONAL INPUTS:
;      EQUINOX1 - Original equinox of coordinates, numeric scalar.  If 
;               omitted, then PRECESS will query for EQUINOX1 and EQUINOX2.
;      EQUINOX2 - Equinox of precessed coordinates.
;
; OPTIONAL INPUT KEYWORDS:
;      /PRINT - If this keyword is set and non-zero, then the precessed
;               coordinates are displayed at the terminal.    Cannot be used
;               with the /RADIAN keyword
;      /FK4   - If this keyword is set and non-zero, the FK4 (B1950.0) system
;               will be used otherwise FK5 (J2000.0) will be used instead.
;      /RADIAN - If this keyword is set and non-zero, then the input and 
;               output RA and DEC vectors are in radians rather than degrees
;
; RESTRICTIONS:
;       Accuracy of precession decreases for declination values near 90 
;       degrees.  PRECESS should not be used more than 2.5 centuries from
;       2000 on the FK5 system (1950.0 on the FK4 system).
;
; EXAMPLES:
;       (1) The Pole Star has J2000.0 coordinates (2h, 31m, 46.3s, 
;               89d 15' 50.6"); compute its coordinates at J1985.0
;
;       IDL> precess, ten(2,31,46.3)*15, ten(89,15,50.6), 2000, 1985, /PRINT
;
;               ====> 2h 16m 22.73s, 89d 11' 47.3"
;
;       (2) Precess the B1950 coordinates of Eps Ind (RA = 21h 59m,33.053s,
;       DEC = (-56d, 59', 33.053") to equinox B1975.
;
;       IDL> ra = ten(21, 59, 33.053)*15
;       IDL> dec = ten(-56, 59, 33.053)
;       IDL> precess, ra, dec ,1950, 1975, /fk4
;
; PROCEDURE:
;       Algorithm from Computational Spherical Astronomy by Taff (1983), 
;       p. 24. (FK4). FK5 constants from "Astronomical Almanac Explanatory
;       Supplement 1992, page 104 Table 3.211.1.
;
; PROCEDURE CALLED:
;       Function PREMAT - computes precession matrix 
;
; REVISION HISTORY
;       Written, Wayne Landsman, STI Corporation  August 1986
;       Correct negative output RA values   February 1989
;       Added /PRINT keyword      W. Landsman   November, 1991
;       Provided FK5 (J2000.0)  I. Freedman   January 1994
;       Precession Matrix computation now in PREMAT   W. Landsman June 1994
;       Added /RADIAN keyword                         W. Landsman June 1997
;       Converted to IDL V5.0   W. Landsman   September 1997
;       Correct negative output RA values when /RADIAN used    March 1999 
;       Work for arrays, not just vectors  W. Landsman    September 2003 
;-    
  On_error,2                                           ;Return to caller

  npar = N_params()
  deg_to_rad = !DPI/180.0D0

   if ( npar LT 2 ) then begin 

     print,'Syntax - PRECESS, ra, dec, [ equinox1, equinox2,' + $ 
                ' /PRINT, /FK4, /RADIAN ]'
     print,'         NOTE: RA and DEC must be in DEGREES unless /RADIAN is set'
     return 

  endif else if (npar LT 4) then $
      read,'Enter original and new equinox of coordinates: ',equinox1,equinox2 

  npts = min( [N_elements(ra), N_elements(dec)] )
  if npts EQ 0 then $  
       message,'ERROR - Input RA and DEC must be vectors or scalars'
  array  = size(ra,/N_dimen) GE 2
  if array then dimen = size(ra,/dimen)

  if not keyword_set( RADIAN) then begin
          ra_rad = ra*deg_to_rad     ;Convert to double precision if not already
          dec_rad = dec*deg_to_rad 
  endif else begin
        ra_rad= double(ra) & dec_rad = double(dec)
  endelse

  a = cos( dec_rad )  

 CASE npts of                    ;Is RA a vector or scalar?

   1:    x = [a*cos(ra_rad), a*sin(ra_rad), sin(dec_rad)] ;input direction 

   else: begin          

         x = dblarr(npts,3)
         x[0,0] = reform(a*cos(ra_rad),npts,/over)
         x[0,1] = reform(a*sin(ra_rad),npts,/over)
         x[0,2] = reform(sin(dec_rad),npts,/over)
         x = transpose(x)
         end

   ENDCASE  

   sec_to_rad = deg_to_rad/3600.d0

; Use PREMAT function to get precession matrix from Equinox1 to Equinox2

  r = premat(equinox1, equinox2, FK4 = fk4)

  x2 = r#x      ;rotate to get output direction cosines

 if npts EQ 1 then begin                 ;Scalar

        ra_rad = atan(x2[1],x2[0])
        dec_rad = asin(x2[2])

 endif else begin                ;Vector     

        ra_rad = dblarr(npts) + atan(x2[1,*],x2[0,*])
        dec_rad = dblarr(npts) + asin(x2[2,*])

 endelse

  if not keyword_set(RADIAN) then begin
        ra = ra_rad/deg_to_rad
        ra = ra + (ra LT 0.)*360.D            ;RA between 0 and 360 degrees
        dec = dec_rad/deg_to_rad
  endif else begin
        ra = ra_rad & dec = dec_rad
        ra = ra + (ra LT 0.)*2.0d*!DPI
  endelse

  if array then begin
       ra = reform(ra, dimen , /over)
       dec = reform(dec, dimen, /over)
  endif

  if keyword_set( PRINT ) then $
      print, 'Equinox (' + strtrim(equinox2,2) + '): ',adstring(ra,dec,1)

  return
  end
pro observatory,obsname,obs_struct, print = print
;+
; NAME:
;       OBSERVATORY
; PURPOSE:
;       Return longitude, latitude, altitude & time zones of an observatory
; EXPLANATION:
;       Given an observatory name, returns a structure giving the longitude,
;       latitude, altitude, and time zone 
;
; CALLING SEQUENCE:
;       Observatory, obsname, obs_struct, [ /PRINT ]
;
; INPUTS:
;       obsname - scalar or vector string giving abbreviated name(s) of 
;             observatories for which location or time information is requested.
;             If obsname is an empty string, then information is returned for 
;             all observatories in the database.     See the NOTES: section
;             for the list of recognized observatories.   The case of the 
;             string does not matter  
; OUTPUTS:
;       obs_struct - an IDL structure containing information on  the specified
;                 observatories.   The structure tags are as follows: 
;       .observatory - abbreviated observatory name
;       .name - full observatory name  
;       .longitude - observatory longitude in degrees *west* 
;       .latitude - observatory latitude in degrees
;       .altitude - observatory altitude in meters above sea level
;       .tz - time zone, number of hours *west* of Greenwich
;
; OPTIONAL INPUT KEYWORD:
;     /PRINT - If this keyword is set, (or if only 1 parameter is supplied)
;             then OBSERVATORY will display information about the specified
;             observatories at the terminal
; EXAMPLE:
;     Get the latitude, longitude and altitude of Kitt Peak National Observatory
;
;     IDL> observatory,'kpno',obs
;     IDL> print,obs.longitude  ==> 111.6 degrees west 
;     IDL> print,obs.latitude  ==> +31.9633 degrees
;     IDL> print,obs.altitude  ==> 2120 meters above sea level
;
; NOTES:
;   Observatory information is taken from noao$lib/obsdb.dat file in IRAF 2.11
;   Currently recognized observatory names are as follows:
;  'tug': Tubitak in Turkey
;  'dmi': Danish Meteorological Institute, Lyngbyvej
;  'kpno': Kitt Peak National Observatory
;  'ctio': Cerro Tololo Interamerican Observatory
;  'eso': European Southern Observatory
;  'lick': Lick Observatory
;  'mmto': MMT Observatory
;  'cfht': Canada-France-Hawaii Telescope
;  'lapalma': Roque de los Muchachos, La Palma
;  'mso': Mt. Stromlo Observatory
;  'sso': Siding Spring Observatory
;  'aao': Anglo-Australian Observatory
;  'mcdonald': McDonald Observatory
;  'lco': Las Campanas Observatory
;  'mtbigelow': Catalina Observatory: 61 inch telescope
;  'dao': Dominion Astrophysical Observatory
;  'spm': Observatorio Astronomico Nacional, San Pedro Martir
;  'tona': Observatorio Astronomico Nacional, Tonantzintla
;  'Palomar': The Hale Telescope
;  'mdm': Michigan-Dartmouth-MIT Observatory
;  'NOV': National Observatory of Venezuela
;  'bmo': Black Moshannon Observatory
;  'BAO': Beijing XingLong Observatory
;  'keck': W. M. Keck Observatory
;  'ekar': Mt. Ekar 182 cm. Telescope
;  'apo': Apache Point Observatory
;  'lowell': Lowell Observatory
;  'vbo': Vainu Bappu Observatory
;  'flwo': Whipple Observatory
;  'oro': Oak Ridge Observatory
;  'lna': Laboratorio Nacional de Astrofisica - Brazil
;  'saao': South African Astronomical Observatory
;  'casleo': Complejo Astronomico El Leoncito, San Juan
;  'bosque': Estacion Astrofisica Bosque Alegre, Cordoba
;  'rozhen': National Astronomical Observatory Rozhen - Bulgaria
;  'irtf': NASA Infrared Telescope Facility
;  'bgsuo': Bowling Green State Univ Observatory
;  'ca': Calar Alto Observatory
;  'holi': Observatorium Hoher List (Universitaet Bonn) - Germany
;  'lmo': Leander McCormick Observatory
;  'fmo': Fan Mountain Observatory
;  'whitin': Whitin Observatory, Wellesley College
;
; PROCEDURE CALLS:
;    TEN()             
; REVISION HISTORY:
;    Written   W. Landsman                 July 2000
;-

 On_error,2                                  ;Return to caller

 if N_params() LT 1 then begin
    print,'Observatory, obsname, obs_struct, [/print]'
    return
 endif
 
obs=[ 'tug', 'dmi', 'kpno','ctio','eso','lick','mmto','cfht','lapalma','mso','sso','aao', $
  'mcdonald','lco','mtbigelow','dao','spm','tona','Palomar','mdm','NOV','bmo',$
  'BAO','keck','ekar','apo','lowell','vbo','flwo','oro','lna','saao','casleo', $
  'bosque','rozhen','irtf','bgsuo','ca','holi','lmo','fmo','whitin' ]

 if N_elements(obsname) EQ 1 then if obsname eq '' then obsname = obs
 nobs = N_elements(obsname)
 obs_struct = {observatory:'',name:'', longitude:0.0, latitude:0.0, $
   altitude:0.0, tz:0.0}
 if Nobs GT 1 then obs_struct = replicate(obs_struct,Nobs)
 obs_struct.observatory = obsname


for i=0,Nobs-1 do begin
case strlowcase(obsname[i]) of 
"tug": begin
	name = "Tübitak, Turkey"
	longitude = [330,20.0]
	latitude = [36,49.5]
	altitude = 2485.
	tz = -2
        end
"dmi": begin
	name = "Danish Meteorological Institute"
	longitude = [348,36.0]
	latitude = [55,57.8]
	altitude = 20.
	tz = -1
        end
"kpno": begin
	name = "Kitt Peak National Observatory"
	longitude = [111,36.0]
	latitude = [31,57.8]
	altitude = 2120.
	tz = 7
        end
"ctio": begin
	name = "Cerro Tololo Interamerican Observatory"
	longitude = 70.815
	latitude = -30.16527778
	altitude = 2215.
	tz = 4
        end
"eso":  begin
	name = "European Southern Observatory"
	longitude = [70,43.8]
	latitude =  [-29,15.4]
	altitude = 2347.
	tz = 4
        end
"lick": begin
	name = "Lick Observatory"
	longitude = [121,38.2]
	latitude = [37,20.6]
	altitude = 1290.
	tz = 8
        end
"mmto": begin
	name = "MMT Observatory"
	longitude = [110,53.1]
	latitude = [31,41.3]
	altitude = 2600.
	tz = 7
        end
"cfht": begin
	name = "Canada-France-Hawaii Telescope"
	longitude = [155,28.3]
	latitude = [19,49.6]
	altitude = 4215.
	tz = 10
        end        
"lapalma": begin
	name = "Roque de los Muchachos, La Palma"
	longitude = [17,52.8]
	latitude = [28,45.5]
	altitude = 2327
	tz = 0
        end
"mso":  begin
	name = "Mt. Stromlo Observatory"
	longitude = [210,58,32.4]
	latitude = [-35,19,14.34]
	altitude = 767
	tz = -10
        end
"sso":  begin
	name = "Siding Spring Observatory"
	longitude = [210,56,19.70]
	latitude = [-31,16,24.10]
	altitude = 1149
	tz = -10
        end
"aao":  begin
	name = "Anglo-Australian Observatory"
	longitude = [210,56,2.09]
	latitude = [-31,16,37.34]
	altitude = 1164
	tz = -10
        end
"mcdonald": begin
	name = "McDonald Observatory"
	longitude = 104.0216667
	latitude = 30.6716667
	altitude = 2075
	tz = 6
        end
"lco":  begin
	name = "Las Campanas Observatory"
	longitude = [70,42.1]
	latitude = [-29,0.2]
	altitude = 2282
	tz = 4
        end
"mtbigelow": begin
	name = "Catalina Observatory: 61 inch telescope"
	longitude = [110,43.9]
	latitude = [32,25.0]
	altitude = 2510.
	tz = 7
        end
"dao":  begin
	name = "Dominion Astrophysical Observatory"
	longitude = [123,25.0]
	latitude = [48,31.3]
	altitude = 229.
	tz = 8
        end
 "spm":  begin
	name = "Observatorio Astronomico Nacional, San Pedro Martir"
	longitude = [115,29,13]
	latitude = [31,01,45]
	altitude = 2830.
	tz = 7
        end
 "tona": begin
	name = "Observatorio Astronomico Nacional, Tonantzintla"
	longitude = [98,18,50]
	latitude = [19,01,58]
	tz = 8
        altitude = -999999    ; Altiutude not supplied
        end
 "palomar": begin
	name = "The Hale Telescope"
	longitude = [116,51,46.80]
	latitude = [33,21,21.6]
	altitude = 1706.
	tz = 8
        end
 "mdm": begin
	name = "Michigan-Dartmouth-MIT Observatory"
	longitude = [111,37.0]
	latitude = [31,57.0]
	altitude = 1938.5
	tz = 7
        end
 "nov": begin
	name = "National Observatory of Venezuela"
	longitude = [70,52.0]
	latitude = [8,47.4]
	altitude = 3610
	tz = 4
        end
 "bmo": begin
	name = "Black Moshannon Observatory"
	longitude = [78,00.3]
	latitude = [40,55.3]
	altitude = 738.
	tz = 5
         end
 "bao": begin
	name = "Beijing XingLong Observatory"
	longitude = [242,25.5]
	latitude = [40,23.6]
	altitude = 950.
	tz = -8
        end
 "keck": begin
	name = "W. M. Keck Observatory"
	longitude = [155,28.7]
	latitude = [19,49.7]
	altitude = 4160.
	tz = 10
        end
 "ekar": begin
	name = "Mt. Ekar 182 cm. Telescope"
	longitude = [348,25,07.92]
	latitude = [45,50,54.92]
	altitude = 1413.69
	tz = -1
        end
 "apo":  begin
	name = "Apache Point Observatory"
	longitude = [105,49.2]
	latitude = [32,46.8]
	altitude = 2798.
	tz = 7 
        end
 "lowell": begin
	name = "Lowell Observatory"
	longitude = [111,32.1]
	latitude = [35,05.8]
	altitude = 2198. 
	tz = 7 
        end
 "vbo": begin
	name = "Vainu Bappu Observatory"
	longitude = 281.1734
	latitude = 12.57666
	altitude = 725. 
	tz = -5.5
         end
 "flwo": begin
        name = "Whipple Observatory"
        longitude = [110,52,39]
        latitude = [31,40,51.4]
        altitude = 2320.
        tz = 7
        end
 "oro": begin
	name = "Oak Ridge Observatory"
        longitude = [71,33,29.32]
        latitude =  [42,30,18.94]
        altitude =  184.
        tz = 5
        end

 "lna":  begin
        name = "Laboratorio Nacional de Astrofisica - Brazil"
        longitude = 45.5825
        latitude = [-22,32,04]
        altitude = 1864.
        tz = 3
        end

 "saao": begin
	name = "South African Astronomical Observatory"
	longitude = [339,11,21.5]
	latitude =  [-32,22,46]
	altitude =  1798.
	tz = -2
         end
 "casleo": begin
        name = "Complejo Astronomico El Leoncito, San Juan"
        longitude = [69,18,00] 
        latitude = [-31,47,57]
        altitude = 2552
        tz = 3
        end
 "bosque": begin
        name = "Estacion Astrofisica Bosque Alegre, Cordoba"
        longitude = [64,32,45]
        latitude = [-31,35,54]
        altitude = 1250
        tz = 3
        end
 "rozhen": begin
        name = "National Astronomical Observatory Rozhen - Bulgaria"
	longitude = [335,15,22]
	latitude = [41,41,35]
	altitude = 1759
	tz = -2
        end
 "irtf": begin
	name        = "NASA Infrared Telescope Facility"
	longitude   = 155.471999
	latitude    = 19.826218
	altitude    = 4168
	tz    = 10
        end
 "bgsuo": begin
        name = "Bowling Green State Univ Observatory"
        longitude = [83,39,33]
        latitude = [41,22,42]
        altitude = 225.
        tz = 5
        end
 "ca":   begin
	name = "Calar Alto Observatory"
	longitude = [2,32,46.5]
	latitude = [37,13,25]
	altitude = 2168
	tz = -1
        end
 "holi": begin
        name = "Observatorium Hoher List (Universitaet Bonn) - Germany"
        longitude = 6.85
        latitude = 50.16276
        altitude = 541
        tz = -1
       end
 "lmo":  begin
        name = "Leander McCormick Observatory"
        longitude = [78,31,24]
        latitude =  [38,02,00]
        altitude = 264
        tz = 5
        end
 "fmo": begin
        name = "Fan Mountain Observatory"
        longitude = [78,41,34]
        latitude =  [37,52,41]
        altitude = 556 
        tz = 5
       end
 "whitin": begin
	name = "Whitin Observatory, Wellesley College"
	longitude = 71.305833
	latitude = 42.295
	altitude = 32
	tz = 5
        end
 else: message,'Unable to find observatory ' + obs + ' in database'
 endcase

 obs_struct[i].longitude = ten(longitude)
 obs_struct[i].latitude = ten(latitude)
 obs_struct[i].tz = tz
 obs_struct[i].name = name
 obs_struct[i].altitude = altitude

 if N_params() EQ 1 or keyword_set(print) then begin
     print,' '
     print,'Observatory: ',obsname[i]
     print,'Name: ',name
     print,'longitude:',obs_struct[i].longitude
     print,'latitude:',obs_struct[i].latitude
     print,'altitude:',altitude
     print,'time zone:',tz
  endif
 endfor

 return
 end
;+
; NAME:
;   EQ2HOR
;
; PURPOSE:
;    Convert celestial  (ra-dec) coords to local horizon coords (alt-az).
;
; CALLING SEQUENCE:
;
;    eq2hor, ra, dec, jd, alt, az, [ha, LAT= , LON= , /WS, OBSNAME= , $
;                       /B1950 , PRECESS_= 0, NUTATE_= 0, REFRACT_= 0, $
;                       ABERRATION_= 0, ALTITUDE= , /VERBOSE, _EXTRA= ]
;
; DESCRIPTION:
;  This is a nice code to calculate horizon (alt,az) coordinates from equatorial
;  (ra,dec) coords.   It is typically accurate to about 1 arcsecond or better (I
;  have checked the output against the publicly available XEPHEM software). It
;  performs precession, nutation, aberration, and refraction corrections.  The
;  perhaps best thing about it is that it can take arrays as inputs, in all
;  variables and keywords EXCEPT Lat, lon, and Altitude (the code assumes these
;  aren't changing), and uses vector arithmetic in every calculation except
;  when calculating the precession matrices.
;
; INPUT VARIABLES:
;       RA   : Right Ascension of object  (J2000) in degrees (FK5); scalar or
;              vector.
;       Dec  : Declination of object (J2000) in degrees (FK5), scalar or vector.
;       JD   : Julian Date [scalar or vector]
;
;       Note: if RA and DEC are arrays, then alt and az will also be arrays.
;             If RA and DEC are arrays, JD may be a scalar OR an array of the
;             same dimensionality.
;
; OPTIONAL INPUT KEYWORDS:
;       lat   : north geodetic latitude of location in degrees
;       lon   : EAST longitude of location in degrees (Specify west longitude
;               with a negative sign.)
;       /WS    : Set this to get the azimuth measured westward from south (not
;               East of North).
;       obsname: Set this to a valid observatory name to be used by the
;              astrolib OBSERVATORY procedure, which will return the latitude
;              and longitude to be used by this program.
;       /B1950 : Set this if your ra and dec are specified in B1950, FK4
;              coordinates (instead of J2000, FK5)
;       precess_ : Set this to 1 to force precession [default], 0 for no
;               precession correction
;       nutate_  : Set this to 1 to force nutation [default], 0 for no nutation.
;       aberration_ : Set this to 1 to force aberration correction [default],
;                     0 for no correction.
;       refract_ : Set to 1 to force refraction correction [default], 0 for no
;                     correction.
;       altitude: The altitude of the observing location, in meters. [default=0].
;       verbose: Set this for verbose output.  The default is verbose=0.
;       _extra: This is for setting TEMPERATURE or PRESSURE explicitly, which are
;               used by CO_REFRACT to calculate the refraction effect of the
;               atmosphere. If you don't set these, the program will make an
;               intelligent guess as to what they are (taking into account your
;               altitude).  See CO_REFRACT for more details.
;
; OUTPUT VARIABLES: (all double precision)
;       alt    : altitude (in degrees)
;       az     : azimuth angle (in degrees, measured EAST from NORTH, but see
;                keyword WS above.)
;       ha     : hour angle (in degrees) (optional)
;
; DEPENDENCIES:
;       NUTATE, PRECESS, OBSERVATORY, SUNPOS, ADSTRING() (from the astrolib)
;       CO_NUTATE, CO_ABERRATION, CO_REFRACT, ALTAZ2HADEC
;
; BASIC STEPS
;   Apply refraction correction to find apparent Alt.
;   Calculate Local Mean Sidereal Time
;   Calculate Local Apparent Sidereal Time
;   Do Spherical Trig to find apparent hour angle, declination.
;   Calculate Right Ascension from hour angle and local sidereal time.
;   Nutation Correction to Ra-Dec
;   Aberration correction to Ra-Dec
;       Precess Ra-Dec to current equinox.
;
;
;CORRECTIONS I DO NOT MAKE:
;   *  Deflection of Light by the sun due to GR. (typically milliarcseconds,
;        can be arseconds within one degree of the sun)
;   *  The Effect of Annual Parallax (typically < 1 arcsecond)
;   *  and more (see below)
;
; TO DO
;    * Better Refraction Correction.  Need to put in wavelength dependence,
;    and integrate through the atmosphere.
;        * Topocentric Parallax Correction (will take into account elevation of
;          the observatory)
;    * Proper Motion (but this will require crazy lookup tables or something).
;        * Difference between UTC and UT1 in determining LAST -- is this
;          important?
;        * Effect of Annual Parallax (is this the same as topocentric Parallax?)
;    * Polar Motion
;        * Better connection to Julian Date Calculator.
;
; EXAMPLE
;
;  Find the position of the open cluster NGC 2264 at the Effelsburg Radio
;  Telescope in Germany, on June 11, 2023, at local time 22:00 (METDST).
;  The inputs will then be:
;
;       Julian Date = 2460107.250
;       Latitude = 50d 31m 36s
;       Longitude = 06h 51m 18s
;       Altitude = 369 meters
;       RA (J2000) = 06h 40m 58.2s
;       Dec(J2000) = 09d 53m 44.0s
;
;  IDL> eq2hor, ten(6,40,58.2)*15., ten(9,53,44), 2460107.250d, alt, az, $
;               lat=ten(50,31,36), lon=ten(6,51,18), altitude=369.0, /verb, $
;                pres=980.0, temp=283.0
;
; The program produces this output (because the VERBOSE keyword was set)
;
; Latitude = +50 31 36.0   Longitude = +06 51 18.0
; Julian Date =  2460107.250000
; Ra, Dec:  06 40 58.2  +09 53 44.0   (J2000)
; Ra, Dec:  06 42 15.7  +09 52 19.2   (J2023.4422)
; Ra, Dec:  06 42 13.8  +09 52 26.9   (fully corrected)
; LMST = +11 46 42.0
; LAST = +11 46 41.4
; Hour Angle = +05 04 27.6  (hh:mm:ss)
; Az, El =  17 42 25.6  +16 25 10.3   (Apparent Coords)
; Az, El =  17 42 25.6  +16 28 22.8   (Observer Coords)
;
; Compare this with the result from XEPHEM:
; Az, El =  17h 42m 25.6s +16d 28m 21s
;
; This 1.8 arcsecond discrepancy in elevation arises primarily from slight
; differences in the way I calculate the refraction correction from XEPHEM, and
; is pretty typical.
;
; AUTHOR:
;   Chris O'Dell
;       Univ. of Wisconsin-Madison
;   Observational Cosmology Laboratory
;   Email: odell@cmb.physics.wisc.edu
;-

pro eq2hor, ra, dec, jd, alt, az, ha, lat=lat, lon=lon, WS=WS, obsname=obsname,$
     B1950 = B1950, verbose=verbose, precess_=precess_, nutate_=nutate_, $
                refract_ = refract_, aberration_ = aberration_,  $
                altitude = altitude, _extra= _extra

 On_error,2
 compile_opt idl2
 
if N_params() LT 4 then begin
    print,'Syntax - EQ2HOR, ra, dec, jd, alt, az, [ha, LAT= , LON= , /WS, '
    print,'          OBSNAME= ,/B1950 , PRECESS_= 0, NUTATE_= 0, REFRACT_= 0 '
    print,'          ABERRATION_= 0, ALTITUDE= , /VERBOSE, TEMPERATURE=, ' +$
          'PRESSURE = ]'
     return
 endif

;*******************************************************************************
; INITIALIZE STUFF

; If no lat or lng entered, use Pine Bluff Observatory values!
;   (near Madison, Wisconsin, USA)
; * Feel free to change these to your favorite observatory *
if n_elements(lat) eq 0 then lat = 43.0783d ; (btw, this is the declination
                                            ; of the zenith)
if n_elements(lon) eq 0 then lon = -89.865d
if n_elements(altitude) eq 0 then altitude = 0. ; [meters]
if keyword_set(obsname) then begin
        ;override lat,lon, altitude if observatory name has been specified
        observatory, obsname, obs
        lat = obs.latitude
        lon = -1*obs.longitude ; minus sign is because OBSERVATORY uses west
;                               longitude as positive.
        altitude = obs.altitude
endif

if n_elements(precess_) eq 0 then precess_ = 1
if n_elements(nutate_) eq 0 then nutate_ = 1
if n_elements(aberration_) eq 0 then aberration_ = 1
if n_elements(refract_) eq 0 then refract_ = 1
v = keyword_set(verbose)

; conversion factors
d2r = !dpi/180.
h2r = !dpi/12.
h2d = 15.d

ra_ = ra ; do this so we don't change ra, dec arrays.
dec_ = dec

if v then print, 'Latitude = ', adstring(lat), '   Longitude = ', adstring(lon)
if v then print, 'Julian Date = ', jd, format='(A,f15.6)'
if keyword_set(B1950) then s_now='   (J1950)' else s_now='   (J2000)'
if v then print, 'Ra, Dec: ', adstring(ra_,dec_), s_now

;******************************************************************************
; PRECESS coordinates to current date
; (uses astro lib procedure PRECESS.pro)
J_now = (JD - 2451545.)/365.25 + 2000.0 ; compute current equinox
if precess_ then begin
        if keyword_set(B1950) then begin
                for i=0,n_elements(jd)-1 do begin
                        ra_i = ra_[i] & dec_i = dec_[i]
                        precess, ra_i, dec_i, 1950.0, J_now[i], /FK4
                        ra_[i] = ra_i & dec_[i] = dec_i
                endfor
        endif else begin
                for i=0,n_elements(jd)-1 do begin
                        ra_i = ra_[i] & dec_i = dec_[i]
                        precess, ra_i, dec_i, 2000.0, J_now[i]
                        ra_[i] = ra_i & dec_[i] = dec_i
                endfor
        endelse
endif

if v then print, 'Ra, Dec: ', adstring(ra_,dec_), '   (J' + $
          strcompress(string(J_now),/rem)+')'


;******************************************************************************
; calculate NUTATION and ABERRATION Corrections to Ra-Dec
co_nutate, jd, ra_, dec_, dra1, ddec1, eps=eps, d_psi=d_psi
co_aberration, jd, ra_, dec_, dra2, ddec2, eps=eps

; make nutation and aberration corrections
ra_ = ra_ + (dra1*nutate_ + dra2*aberration_)/3600.
dec_ = dec_ + (ddec1*nutate_ + ddec2*aberration_)/3600.

if v then print, 'Ra, Dec: ', adstring(ra_,dec_), '   (fully corrected)'


;**************************************************************************************
;Calculate LOCAL MEAN SIDEREAL TIME
ct2lst, lmst, lon, 0, jd  ; get LST (in hours) - note:this is independent of
                           ;time zone  since giving jd
lmst = lmst*h2d ; convert LMST to degrees (btw, this is the RA of the zenith)
; calculate local APPARENT sidereal time
LAST = lmst + d_psi *cos(eps)/3600. ; add correction in degrees
if v then print, 'LMST = ', adstring(lmst/15.)
if v then print, 'LAST = ', adstring(last/15.)

;******************************************************************************
; Find hour angle (in DEGREES)
ha = last - ra_
w = where(ha LT 0)
if w[0] ne -1 then ha[w] = ha[w] + 360.
ha = ha mod 360.
if v then print, 'Hour Angle = ', adstring(ha/15.), '  (hh:mm:ss)'

;******************************************************************************
; Now do the spherical trig to get APPARENT alt,az.
hadec2altaz, ha, dec_, lat, alt, az, WS=WS

if v then print,'Az, El = ', adstring(az,alt), '   (Apparent Coords)'

;*******************************************************************************************
; Make Correction for ATMOSPHERIC REFRACTION
; (use this for visible and radio wavelengths; author is unsure about other wavelengths.
;  See the comments in CO_REFRACT.pro for more details.)
if refract_ then alt = $
      co_refract(alt, altitude=altitude, _extra=_extra, /to_observed)
if v then print,'Az, El = ', adstring(az,alt), '   (Observer Coords)'

end
pro nutate, jd, nut_long, nut_obliq
;+
; NAME:
;       NUTATE
; PURPOSE:
;       Return the nutation in longitude and obliquity for a given Julian date
;
; CALLING SEQUENCE:
;       NUTATE, jd, Nut_long, Nut_obliq
;
; INPUT:
;       jd - Julian ephemeris date, scalar or vector, double precision  
; OUTPUT:
;       Nut_long - the nutation in longitude, same # of elements as jd
;       Nut_obliq - nutation in latitude, same # of elements as jd
;
; EXAMPLE:
;       (1) Find the nutation in longitude and obliquity 1987 on Apr 10 at Oh.
;              This is example 22.a from Meeus
;        IDL> jdcnv,1987,4,10,0,jul
;        IDL> nutate, jul, nut_long, nut_obliq
;             ==> nut_long = -3.788    nut_obliq = 9.443
;            
;       (2) Plot the large-scale variation of the nutation in longitude 
;               during the 20th century
;
;       IDL> yr = 1900 + indgen(100)     ;Compute once a year        
;       IDL> jdcnv,yr,1,1,0,jul          ;Find Julian date of first day of year
;       IDL> nutate,jul, nut_long        ;Nutation in longitude
;       IDL> plot, yr, nut_long
;
;       This plot will reveal the dominant (18.6 year) period, but a finer
;       grid is needed to display the shorter periods in the nutation.
; METHOD:
;       Uses the formula in Chapter 22 of ``Astronomical Algorithms'' by Jean 
;       Meeus (1998, 2nd ed.) which is based on the 1980 IAU Theory of Nutation
;       and includes all terms larger than 0.0003".
;
; PROCEDURES CALLED:
;       POLY()                       (from IDL User's Library)
;       CIRRANGE, ISARRAY()          (from IDL Astronomy Library)
;
; REVISION HISTORY:
;       Written, W.Landsman (Goddard/HSTX)      June 1996       
;       Converted to IDL V5.0   W. Landsman   September 1997
;       Corrected minor typos in values of d_lng W. Landsman  December 2000
;       Updated typo in cdelt term              December 2000
;-
 On_error,2
 
 if N_params() LT 2 then begin
        print,'Syntax - NUTATE, jd, nut_long, nut_obliq'
        return
 endif

 dtor = !DPI/180.0d
 ;  form time in Julian centuries from 1900.0

 t = (jd[*] - 2451545.0d)/36525.0d0


; Mean elongation of the Moon

   coeff1 = [297.85036d,  445267.111480d, -0.0019142, 1.d/189474d0 ]
  d = poly(T, coeff1)*dtor
  cirrange,d,/rad

; Sun's mean anomaly

   coeff2 = [357.52772d, 35999.050340d, -0.0001603d, -1.d/3d5 ]
   M = poly(T,coeff2)*dtor
   cirrange, M,/rad

; Moon's mean anomaly

   coeff3 = [134.96298d, 477198.867398d, 0.0086972d, 1.0/5.625d4 ]
   Mprime = poly(T,coeff3)*dtor
   cirrange, Mprime,/rad

; Moon's argument of latitude

    coeff4 = [93.27191d, 483202.017538d, -0.0036825, -1.0d/3.27270d5 ]
    F = poly(T, coeff4 )*dtor 
    cirrange, F,/RAD

; Longitude of the ascending node of the Moon's mean orbit on the ecliptic,
;  measured from the mean equinox of the date

  coeff5 = [125.04452d, -1934.136261d, 0.0020708d, 1.d/4.5d5]
  omega = poly(T, coeff5)*dtor
  cirrange,omega,/RAD

 d_lng = [0,-2,0,0,0,0,-2,0,0,-2,-2,-2,0,2,0,2,0,0,-2,0,2,0,0,-2,0,-2,0,0,2,$
   -2,0,-2,0,0,2,2,0,-2,0,2,2,-2,-2,2,2,0,-2,-2,0,-2,-2,0,-1,-2,1,0,0,-1,0,0, $
     2,0,2]

 m_lng = [0,0,0,0,1,0,1,0,0,-1,intarr(17),2,0,2,1,0,-1,0,0,0,1,1,-1,0, $
  0,0,0,0,0,-1,-1,0,0,0,1,0,0,1,0,0,0,-1,1,-1,-1,0,-1]

 mp_lng = [0,0,0,0,0,1,0,0,1,0,1,0,-1,0,1,-1,-1,1,2,-2,0,2,2,1,0,0,-1,0,-1, $
   0,0,1,0,2,-1,1,0,1,0,0,1,2,1,-2,0,1,0,0,2,2,0,1,1,0,0,1,-2,1,1,1,-1,3,0]

 f_lng = [0,2,2,0,0,0,2,2,2,2,0,2,2,0,0,2,0,2,0,2,2,2,0,2,2,2,2,0,0,2,0,0, $
   0,-2,2,2,2,0,2,2,0,2,2,0,0,0,2,0,2,0,2,-2,0,0,0,2,2,0,0,2,2,2,2]

 om_lng = [1,2,2,2,0,0,2,1,2,2,0,1,2,0,1,2,1,1,0,1,2,2,0,2,0,0,1,0,1,2,1, $
   1,1,0,1,2,2,0,2,1,0,2,1,1,1,0,1,1,1,1,1,0,0,0,0,0,2,0,0,2,2,2,2]

 sin_lng = [-171996, -13187, -2274, 2062, 1426, 712, -517, -386, -301, 217, $
    -158, 129, 123, 63, 63, -59, -58, -51, 48, 46, -38, -31, 29, 29, 26, -22, $
     21, 17, 16, -16, -15, -13, -12, 11, -10, -8, 7, -7, -7, -7, $
     6,6,6,-6,-6,5,-5,-5,-5,4,4,4,-4,-4,-4,3,-3,-3,-3,-3,-3,-3,-3 ]
 
 sdelt = [-174.2, -1.6, -0.2, 0.2, -3.4, 0.1, 1.2, -0.4, 0, -0.5, 0, 0.1, $
     0,0,0.1, 0,-0.1,dblarr(10), -0.1, 0, 0.1, dblarr(33) ] 


 cos_lng = [ 92025, 5736, 977, -895, 54, -7, 224, 200, 129, -95,0,-70,-53,0, $
    -33, 26, 32, 27, 0, -24, 16,13,0,-12,0,0,-10,0,-8,7,9,7,6,0,5,3,-3,0,3,3,$
     0,-3,-3,3,3,0,3,3,3, intarr(14) ]

 cdelt = [8.9, -3.1, -0.5, 0.5, -0.1, 0.0, -0.6, 0.0, -0.1, 0.3, dblarr(53) ]


; Sum the periodic terms 

 n = N_elements(jd)
 nut_long = dblarr(n)
 nut_obliq = dblarr(n)
 arg = d_lng#d + m_lng#m +mp_lng#mprime + f_lng#f +om_lng#omega
 sarg = sin(arg)
 carg = cos(arg)
 for i=0,n-1 do begin
        nut_long[i] =  0.0001d*total( (sdelt*t[i] + sin_lng)*sarg[*,i] )
        nut_obliq[i] = 0.0001d*total( (cdelt*t[i] + cos_lng)*carg[*,i] )
 end
 if not isarray(jd) then begin
        nut_long = nut_long[0]
        nut_obliq = nut_obliq[0]
 endif

 return
 end
PRO cirrange, ang, RADIANS=rad
;+
; NAME:
;       CIRRANGE
; PURPOSE:
;       To force an angle into the range 0 <= ang < 360.
; CALLING SEQUENCE:
;       CIRRANGE, ang, [/RADIANS]
;
; INPUTS/OUTPUT:
;       ang     - The angle to modify, in degrees.  This parameter is
;                 changed by this procedure.  Can be a scalar or vector.
;                 The type of ANG is always converted to double precision
;                 on output.
;
; OPTIONAL INPUT KEYWORDS:
;       /RADIANS - If present and non-zero, the angle is specified in
;                 radians rather than degrees.  It is forced into the range
;                 0 <= ang < 2 PI.
; PROCEDURE:
;       The angle is transformed between -360 and 360 using the MOD operator.   
;       Negative values (if any) are then transformed between 0 and 360
; MODIFICATION HISTORY:
;       Written by Michael R. Greason, Hughes STX, 10 February 1994.
;       Get rid of WHILE loop, W. Landsman, Hughex STX, May 1996
;       Converted to IDL V5.0   W. Landsman   September 1997
;-
 On_error,2
 if N_params() LT 1 then begin 
        print, 'Syntax:  CIRRANGE, ang, [ /RADIANS ]'
        return
 endif

;  Determine the additive constant.

 if keyword_set(RAD) then cnst = !dpi * 2.d $
                     else cnst = 360.d

; Deal with the lower limit.

 ang = ang mod cnst

; Deal with negative values, if any
 
 neg = where(ang LT 0., Nneg)
 if Nneg GT 0 then ang[neg] = ang[neg] + cnst

 return
 end
; $Id: poly.pro,v 1.7 2001/01/15 22:28:09 scottm Exp $
;
; Copyright (c) 1983-2001, Research Systems, Inc.  All rights reserved.
;       Unauthorized reproduction prohibited.

FUNCTION POLY,X,C
;+
; NAME:
;	POLY
;
; PURPOSE:
;	Evaluate a polynomial function of a variable.
;
; CATEGORY:
;	C1 - Operations on polynomials.
;
; CALLING SEQUENCE:
;	Result = POLY(X,C)
;
; INPUTS:
;	X:	The variable.  This value can be a scalar, vector or array.
;
;	C:	The vector of polynomial coefficients.  The degree of 
;		of the polynomial is N_ELEMENTS(C) - 1.
;
; OUTPUTS:
;	POLY returns a result equal to:
;		 C[0] + c[1] * X + c[2]*x^2 + ...
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	None.
;
; PROCEDURE:
;	Straightforward.
;
; MODIFICATION HISTORY:
;	DMS, Written, January, 1983.
;-

on_error,2		;Return to caller if an error occurs
N = N_ELEMENTS(C)-1	;Find degree of polynomial
Y = c[n]
for i=n-1,0,-1 do y = y * x + c[i]
return,y
end

PRO sunpos, jd, ra, dec, longmed, oblt, RADIAN = radian
;+
; NAME:
;       SUNPOS
; PURPOSE:
;       To compute the RA and Dec of the Sun at a given date.
;
; CALLING SEQUENCE:
;       SUNPOS, jd, ra, dec, [elong, obliquity, /RADIAN ]
; INPUTS:
;       jd    - The Julian date of the day (and time), scalar or vector
;               usually double precision
; OUTPUTS:
;       ra    - The right ascension of the sun at that date in DEGREES
;               double precision, same number of elements as jd
;       dec   - The declination of the sun at that date in DEGREES
;
; OPTIONAL OUTPUTS:
;       elong - Ecliptic longitude of the sun at that date in DEGREES.
;       obliquity - the obliquity of the ecliptic, in DEGREES
;
; OPTIONAL INPUT KEYWORD:
;       /RADIAN - If this keyword is set and non-zero, then all output variables 
;               are given in Radians rather than Degrees
;
; NOTES:
;       The accuracy in the 20th century  should be within 1"; however this 
;       has not been extensively tested.
;
;       The returned RA and Dec are in the given date's equinox.
;
;       Procedure was extensively revised in May 1996, and the new calling
;       sequence is incompatible with the old one.
; METHOD:
;       Uses a truncated version of Newcomb's Sun.    Adapted from the IDL
;       routine SUN_POS by CD Pike, which was adapted from a FORTRAN routine
;       by B. Emerson (RGO).
; EXAMPLE:
;       (1) Find the apparent RA and Dec of the Sun on May 1, 1982
;       
;       IDL> jdcnv, 1982, 5, 1,0 ,jd      ;Find Julian date jd = 2445090.5   
;       IDL> sunpos, jd, ra, dec
;       IDL> print,adstring(ra,dec,2)
;                02 31 32.61  +14 54 34.9
;
;       The Astronomical Almanac gives 02 31 32.58 +14 54 34.9 so the error
;               in SUNPOS for this case is < 0.5".      
;
;       (2) Find the apparent RA and Dec of the Sun for every day in 1997
;
;       IDL> jdcnv, 1997,1,1,0, jd                ;Julian date on Jan 1, 1997
;       IDL> sunpos, jd+ dindgen(365), ra, dec    ;RA and Dec for each day 
;
; MODIFICATION HISTORY:
;       Written by Michael R. Greason, STX, 28 October 1988.
;       Accept vector arguments, W. Landsman     April,1989
;       Eliminated negative right ascensions.  MRG, Hughes STX, 6 May 1992.
;       Rewritten using the 1993 Almanac.  Keywords added.  MRG, HSTX, 
;               10 February 1994.
;       Major rewrite, improved accuracy, always return values in degrees
;       W. Landsman  May, 1996 
;       Added /RADIAN keyword,    W. Landsman       August, 1997
;       Converted to IDL V5.0   W. Landsman   September 1997
;-
 On_error,2
;                       Check arguments.
 if N_params() LT 3 then begin 
     print, 'Syntax - SUNPOS, jd, ra, dec, [elong, obliquity, /RADIAN] '
     print, 'Inputs  -  jd (Julian date)'
     print, 'Outputs - Apparent RA and Dec, longitude, & obliquity'
     print, 'All angles in DEGREES unless /RADIAN is set'
     return
 endif

 dtor = !DPI/180.0d       ;(degrees to radian, double precision)

;  form time in Julian centuries from 1900.0

 t = (jd - 2415020.0d)/36525.0d0

;  form sun's mean longitude

 l = (279.696678d0+((36000.768925d0*t) mod 360.0d0))*3600.0d0

;  allow for ellipticity of the orbit (equation of centre)
;  using the Earth's mean anomoly ME

 me = 358.475844d0 + ((35999.049750D0*t) mod 360.0d0)
 ellcor  = (6910.1d0 - 17.2D0*t)*sin(me*dtor) + 72.3D0*sin(2.0D0*me*dtor)
 l = l + ellcor

; allow for the Venus perturbations using the mean anomaly of Venus MV

 mv = 212.603219d0 + ((58517.803875d0*t) mod 360.0d0) 
 vencorr = 4.8D0 * cos((299.1017d0 + mv - me)*dtor) + $
          5.5D0 * cos((148.3133d0 +  2.0D0 * mv  -  2.0D0 * me )*dtor) + $
          2.5D0 * cos((315.9433d0 +  2.0D0 * mv  -  3.0D0 * me )*dtor) + $
          1.6D0 * cos((345.2533d0 +  3.0D0 * mv  -  4.0D0 * me )*dtor) + $
          1.0D0 * cos((318.15d0   +  3.0D0 * mv  -  5.0D0 * me )*dtor)
l = l + vencorr

;  Allow for the Mars perturbations using the mean anomaly of Mars MM

 mm = 319.529425d0  +  (( 19139.858500d0 * t)  mod  360.0d0 )
 marscorr = 2.0d0 * cos((343.8883d0 -  2.0d0 * mm  +  2.0d0 * me)*dtor ) + $
            1.8D0 * cos((200.4017d0 -  2.0d0 * mm  + me) * dtor)
 l = l + marscorr

; Allow for the Jupiter perturbations using the mean anomaly of
; Jupiter MJ

 mj = 225.328328d0  +  (( 3034.6920239d0 * t)  mod  360.0d0 )
 jupcorr = 7.2d0 * cos(( 179.5317d0 - mj + me )*dtor) + $
          2.6d0 * cos((263.2167d0  -  MJ ) *dtor) + $
          2.7d0 * cos(( 87.1450d0  -  2.0d0 * mj  +  2.0D0 * me ) *dtor) + $
          1.6d0 * cos((109.4933d0  -  2.0d0 * mj  +  me ) *dtor)
 l = l + jupcorr

; Allow for the Moons perturbations using the mean elongation of
; the Moon from the Sun D

 d = 350.7376814d0  + (( 445267.11422d0 * t)  mod  360.0d0 )
 mooncorr  = 6.5d0 * sin(d*dtor)
 l = l + mooncorr

; Allow for long period terms

 longterm  = + 6.4d0 * sin(( 231.19d0  +  20.20d0 * t )*dtor)
 l  =    l + longterm
 l  =  ( l + 2592000.0d0)  mod  1296000.0d0 
 longmed = l/3600.0d0

; Allow for Aberration

 l  =  l - 20.5d0

; Allow for Nutation using the longitude of the Moons mean node OMEGA

 omega = 259.183275d0 - (( 1934.142008d0 * t ) mod 360.0d0 )
 l  =  l - 17.2d0 * sin(omega*dtor)

; Form the True Obliquity

 oblt  = 23.452294d0 - 0.0130125d0*t + (9.2d0*cos(omega*dtor))/3600.0d0

; Form Right Ascension and Declination

 l = l/3600.0d0
 ra  = atan( sin(l*dtor) * cos(oblt*dtor) , cos(l*dtor) )

 neg = where(ra LT 0.0d0, Nneg) 
 if Nneg GT 0 then ra[neg] = ra[neg] + 2.0d*!DPI

 dec = asin(sin(l*dtor) * sin(oblt*dtor))
 
 if keyword_set(RADIAN) then begin
        oblt = oblt*dtor 
        longmed = longmed*dtor
 endif else begin
        ra = ra/dtor
        dec = dec/dtor
 endelse
 end
  PRO MOONPOS, jd, ra, dec, dis, geolong, geolat, RADIAN = radian
;+
; NAME:                                     
;       MOONPOS
; PURPOSE:
;       To compute the RA and Dec of the Moon at specified Julian date(s).
;
; CALLING SEQUENCE:
;       MOONPOS, jd, ra, dec, dis, geolong, geolat, [/RADIAN ]
;
; INPUTS:
;       JD - Julian date, scalar or vector, double precision suggested
;
; OUTPUTS:
;       Ra  - Apparent right ascension of the moon in DEGREES, referred to the
;               true equator of the specified date(s) 
;       Dec - The declination of the moon in DEGREES 
;       Dis - The Earth-moon distance in kilometers (between the center of the
;             Earth and the center of the Moon).
;       Geolong - Apparent longitude of the moon in DEGREES, referred to the
;               ecliptic of the specified date(s)
;       Geolat - Apparent longitude of the moon in DEGREES, referred to the
;               ecliptic of the specified date(s)
;
;       The output variables will all have the same number of elements as the
;       input Julian date vector, JD.   If JD is a scalar then the output 
;       variables will be also.
;
; OPTIONAL INPUT KEYWORD:
;       /RADIAN - If this keyword is set and non-zero, then all output variables 
;               are given in Radians rather than Degrees
;
; EXAMPLES:
;       (1) Find the position of the moon on April 12, 1992
;
;       IDL> jdcnv,1992,4,12,0,jd    ;Get Julian date
;       IDL> moonpos, jd, ra ,dec     ;Get RA and Dec of moon
;       IDL> print,adstring(ra,dec,1)
;               ==> 08 58 45.23  +13 46  6.1
;
;       This is within 1" from the position given in the Astronomical Almanac
;       
;       (2) Plot the Earth-moon distance for every day at 0 TD in July, 1996
;
;       IDL> jdcnv,1996,7,1,0,jd                   ;Get Julian date of July 1
;       IDL> moonpos,jd+dindgen(31), ra, dec, dis  ;Position at all 31 days
;       IDL> plot,indgen(31),dis, /YNOZ
;
; METHOD:
;       Derived from the Chapront ELP2000/82 Lunar Theory (Chapront-Touze' and
;       Chapront, 1983, 124, 50), as described by Jean Meeus in Chapter 47 of
;       ``Astronomical Algorithms'' (Willmann-Bell, Richmond), 2nd edition, 
;       1998.    Meeus quotes an approximate accuracy of 10" in longitude and
;       4" in latitude, but he does not give the time range for this accuracy.
;
;       Comparison of this IDL procedure with the example in ``Astronomical
;       Algorithms'' reveals a very small discrepancy (~1 km) in the distance 
;       computation, but no difference in the position calculation.
;
;       This procedure underwent a major rewrite in June 1996, and the new
;       calling sequence is *incompatible with the old* (e.g. angles now 
;       returned in degrees instead of radians).
;
; PROCEDURES CALLED:
;       CIRRANGE, ISARRAY(), NUTATE, TEN()  - from IDL Astronomy Library
;       POLY() - from IDL User's Library
; MODIFICATION HISTORY:
;       Written by Michael R. Greason, STX, 31 October 1988.
;       Major rewrite, new (incompatible) calling sequence, much improved 
;               accuracy,       W. Landsman   Hughes STX      June 1996
;       Added /RADIAN keyword  W. Landsman August 1997
;       Converted to IDL V5.0   W. Landsman   September 1997
;       Use improved expressions for L',D,M,M', and F given in 2nd edition of
;            Meeus (very slight change),  W. Landsman    November 2000
;-
 On_error,2

 if N_params() LT 3 then begin
        print,'Syntax - MOONPOS, jd, ra, dec, dis, geolong, geolat, [/RADIAN]' 
        print,'Output angles in DEGREES unless /RADIAN is set'
        return
 endif

 npts = N_elements(jd)
 dtor = !DPI/180.0d

 ;  form time in Julian centuries from 1900.0

 t = (jd[*] - 2451545.0d)/36525.0d0

 d_lng = [0,2,2,0,0,0,2,2,2,2,0,1,0,2,0,0,4,0,4,2,2,1,1,2,2,4,2,0,2,2,1,2,0,0, $
 2,2,2,4,0,3,2,4,0,2,2,2,4,0,4,1,2,0,1,3,4,2,0,1,2,2]

 m_lng = [0,0,0,0,1,0,0,-1,0,-1,1,0,1,0,0,0,0,0,0,1,1,0,1,-1,0,0,0,1,0,-1,0, $
 -2,1,2,-2,0,0,-1,0,0,1,-1,2,2,1,-1,0,0,-1,0,1,0,1,0,0,-1,2,1,0,0]

 mp_lng = [1,-1,0,2,0,0,-2,-1,1,0,-1,0,1,0,1,1,-1,3,-2,-1,0,-1,0,1,2,0,-3,-2,$
 -1,-2,1,0,2,0,-1,1,0,-1,2,-1,1,-2,-1,-1,-2,0,1,4,0,-2,0,2,1,-2,-3,2,1,-1, $
  3,-1]

 f_lng = [0,0,0,0,0,2,0,0,0,0,0,0,0,-2,2,-2,0,0,0,0,0,0,0,0,0,0,0,0,2,0,0,0, $
 0,0,0,-2,2,0,2,0,0,0,0,0,0,-2,0,0,0,0,-2,-2,0,0,0,0,0,0,0,-2]

 sin_lng = [6288774,1274027,658314,213618,-185116,-114332,58793,57066,53322, $
 45758,-40923,-34720,-30383,15327,-12528,10980,10675,10034,8548,-7888,-6766, $
 -5163,4987,4036,3994,3861,3665,-2689,-2602,2390,-2348,2236,-2120,-2069,2048, $
 -1773,-1595,1215,-1110,-892,-810,759,-713,-700,691,596,549,537,520,-487, $
  -399,-381,351,-340,330,327,-323,299,294,0.0d]

 cos_lng = [-20905355,-3699111,-2955968,-569925,48888,-3149,246158,-152138, $
  -170733,-204586,-129620,108743,104755,10321,0,79661,-34782,-23210,-21636, $
   24208,30824,-8379,-16675,-12831,-10445,-11650,14403,-7003,0,10056,6322, $
  -9884,5751,0,-4950,4130,0,-3958,0,3258,2616,-1897,-2117,2354,0,0,-1423, $
  -1117,-1571,-1739,0,-4421,0,0,0,0,1165,0,0,8752.0d]

 d_lat = [0,0,0,2,2,2,2,0,2,0,2,2,2,2,2,2,2,0,4,0,0,0,1,0,0,0,1,0,4,4,0,4,2,2,$
    2,2,0,2,2,2,2,4,2,2,0,2,1,1,0,2,1,2,0,4,4,1,4,1,4,2]

 m_lat = [0,0,0,0,0,0,0,0,0,0,-1,0,0,1,-1,-1,-1,1,0,1,0,1,0,1,1,1,0,0,0,0,0,0,$
    0,0,-1,0,0,0,0,1,1,0,-1,-2,0,1,1,1,1,1,0,-1,1,0,-1,0,0,0,-1,-2]

 mp_lat = [0,1,1,0,-1,-1,0,2,1,2,0,-2,1,0,-1,0,-1,-1,-1,0,0,-1,0,1,1,0,0,3,0, $ 
   -1,1, -2,0,2,1,-2,3,2,-3,-1,0,0,1,0,1,1,0,0,-2,-1,1,-2,2,-2,-1,1,1,-1,0,0]

 f_lat =[ 1,1,-1,-1,1,-1,1,1,-1,-1,-1,-1,1,-1,1,1,-1,-1,-1,1,3,1,1,1,-1,-1,-1, $
     1,-1,1,-3,1,-3,-1,-1,1,-1,1,-1,1,1,1,1,-1,3,-1,-1,1,-1,-1,1,-1,1,-1,-1, $
     -1,-1,-1,-1,1]

 sin_lat = [5128122,280602,277693,173237,55413,46271,32573,17198,9266,8822, $
     8216,4324,4200,-3359,2463,2211,2065,-1870,1828,-1794,-1749,-1565,-1491, $
     -1475,-1410,-1344,-1335,1107,1021,833,777,671,607,596,491,-451,439,422, $
     421,-366,-351,331,315,302,-283,-229,223,223,-220,-220,-185,181,-177,176, $
    166,-164,132,-119,115,107.0d]

; Mean longitude of the moon refered to mean equinox of the date

 coeff0 = [218.3164477d, 481267.88123421d, -0.0015786d0, 1.0d/538841.0d, $
         -1.0d/6.5194d7 ]
 lprimed = poly(T, coeff0)
 cirrange, lprimed
 lprime = lprimed*dtor

; Mean elongation of the Moon

  coeff1 = [297.8501921d, 445267.1114034d, -0.0018819d, 1.0d/545868.0d, $
           -1.0d/1.13065d8 ]
  d = poly(T, coeff1)
  cirrange,d
  d = d*dtor

; Sun's mean anomaly

   coeff2 = [357.5291092d, 35999.0502909d, -0.0001536d, 1.0d/2.449d7 ]
   M = poly(T,coeff2) 
   cirrange, M 
   M = M*dtor

; Moon's mean anomaly

   coeff3 = [134.9633964d, 477198.8675055d, 0.0087414d, 1.0/6.9699d4, $
             -1.0d/1.4712d7 ]
   Mprime = poly(T, coeff3) 
   cirrange, Mprime
   Mprime = Mprime*dtor

; Moon's argument of latitude

    coeff4 = [93.2720950d, 483202.0175233d, -0.0036539, -1.0d/3.526d7, $
             1.0d/8.6331d8 ]
    F = poly(T, coeff4 ) 
    cirrange, F
    F = F*dtor

; Eccentricity of Earth's orbit around the Sun

    E = 1 - 0.002516d*T - 7.4d-6*T^2
    E2 = E^2

    ecorr1 = where(abs(m_lng) EQ 1)
    ecorr2 = where(abs(m_lat) EQ 1)
    ecorr3 = where(abs(m_lng) EQ 2)
    ecorr4 = where(abs(m_lat) EQ 2)

; Additional arguments

    A1 = (119.75d + 131.849d*T) * dtor
    A2 = (53.09d + 479264.290d*T) * dtor
    A3 = (313.45d + 481266.484d*T) * dtor
    suml_add = 3958*sin(A1) + 1962*sin(lprime - F) + 318*sin(A2)
    sumb_add =  -2235*sin(lprime) + 382*sin(A3) + 175*sin(A1-F) + $ 
              175*sin(A1 + F) + 127*sin(Lprime - Mprime) - $
              115*sin(Lprime + Mprime)

; Sum the periodic terms 

 geolong = dblarr(npts) & geolat = geolong & dis = geolong

 for i=0,npts-1 do begin

   sinlng = sin_lng & coslng = cos_lng & sinlat = sin_lat

   sinlng[ecorr1] = e[i]*sinlng[ecorr1]
   coslng[ecorr1] = e[i]*coslng[ecorr1]
   sinlat[ecorr2] = e[i]*sinlat[ecorr2]
   sinlng[ecorr3] = e2[i]*sinlng[ecorr3]
   coslng[ecorr3] = e2[i]*coslng[ecorr3]
   sinlat[ecorr4] = e2[i]*sinlat[ecorr4]

   arg = d_lng*d[i] + m_lng*m[i] +mp_lng*mprime[i] + f_lng*f[i]
   geolong[i] = lprimed[i] + ( total(sinlng*sin(arg)) + suml_add[i] )/1.0d6

   dis[i] = 385000.56d + total(coslng*cos(arg))/1.0d3

   arg = d_lat*d[i] + m_lat*m[i] +mp_lat*mprime[i] + f_lat*f[i]
   geolat[i] = (total(sinlat*sin(arg)) + sumb_add[i])/1.0d6
       
 endfor

 nutate, jd, nlong, elong                     ;Find the nutation in longitude
 geolong= geolong + nlong/3.6d3
 cirrange,geolong
 lambda = geolong*dtor
 beta = geolat*dtor

;Find mean obliquity and convert lambda,beta to RA, Dec 

 c = [21.448,-4680.93,-1.55,1999.25,-51.38,-249.67,-39.05,7.12,27.87,5.79,2.45d]
 epsilon = ten(23,26) + poly(t/1.d2,c)/3600.d
 eps = (epsilon + elong/3600.d )*dtor          ;True obliquity in radians

 ra = atan( sin(lambda)*cos(eps) - tan(beta)* sin(eps), cos(lambda) )
 cirrange,ra,/RADIAN
 dec = asin( sin(beta)*cos(eps) + cos(beta)*sin(eps)*sin(lambda) )

 if not isarray(jd) then begin
        ra = ra[0] & dec = dec[0] & dis = dis[0]
        geolong = geolong[0]  & geolat = geolat[0]
 endif

 if not keyword_set(RADIAN) then begin
        ra = ra/dtor & dec = dec/dtor
 endif else begin
        geolong = lambda & geolat = beta
 endelse

 return
 end
; $Id: julday.pro,v 1.17 2001/03/02 16:35:43 chris Exp $
;
; Copyright (c) 1988-2001, Research Systems, Inc.  All rights reserved.
;	Unauthorized reproduction prohibited.

;+
; NAME:
;	JULDAY
;
; PURPOSE:
;	Calculate the Julian Day Number for a given month, day, and year.
;	This is the inverse of the library function CALDAT.
;	See also caldat, the inverse of this function.
;
; CATEGORY:
;	Misc.
;
; CALLING SEQUENCE:
;	Result = JULDAY([[[[Month, Day, Year], Hour], Minute], Second])
;
; INPUTS:
;	MONTH:	Number of the desired month (1 = January, ..., 12 = December).
;
;	DAY:	Number of day of the month.
;
;	YEAR:	Number of the desired year.Year parameters must be valid
;               values from the civil calendar.  Years B.C.E. are represented
;               as negative integers.  Years in the common era are represented
;               as positive integers.  In particular, note that there is no
;               year 0 in the civil calendar.  1 B.C.E. (-1) is followed by
;               1 C.E. (1).
;
;	HOUR:	Number of the hour of the day.
;
;	MINUTE:	Number of the minute of the hour.
;
;	SECOND:	Number of the second of the minute.
;
;   Note: Month, Day, Year, Hour, Minute, and Second can all be arrays.
;         The Result will have the same dimensions as the smallest array, or
;         will be a scalar if all arguments are scalars.
;
; OPTIONAL INPUT PARAMETERS:
;	Hour, Minute, Second = optional time of day.
;
; OUTPUTS:
;	JULDAY returns the Julian Day Number (which begins at noon) of the
;	specified calendar date.  If Hour, Minute, and Second are not specified,
;	then the result will be a long integer, otherwise the result is a
;	double precision floating point number.
;
; COMMON BLOCKS:
;	None.
;
; SIDE EFFECTS:
;	None.
;
; RESTRICTIONS:
;	Accuracy using IEEE double precision numbers is approximately
;   1/10000th of a second, with higher accuracy for smaller (earlier)
;   Julian dates.
;
; MODIFICATION HISTORY:
;	Translated from "Numerical Recipies in C", by William H. Press,
;	Brian P. Flannery, Saul A. Teukolsky, and William T. Vetterling.
;	Cambridge University Press, 1988 (second printing).
;
;	AB, September, 1988
;	DMS, April, 1995, Added time of day.
;   CT, April 2000, Now accepts vectors or scalars.
;-
;
function JULDAY, MONTH, DAY, YEAR, Hour, Minute, Second

COMPILE_OPT idl2

ON_ERROR, 2		; Return to caller if errors

; Gregorian Calander was adopted on Oct. 15, 1582
; skipping from Oct. 4, 1582 to Oct. 15, 1582
GREG = 2299171L  ; incorrect Julian day for Oct. 25, 1582

; Process the input, if all are missing, use todays date.
NP = n_params()
IF (np EQ 0) THEN RETURN, SYSTIME(/JULIAN)
IF (np LT 3) THEN MESSAGE, 'Incorrect number of arguments.'

; Find the dimensions of the Result:
;  1. Find all of the input arguments that are arrays (ignore scalars)
;  2. Out of the arrays, find the smallest number of elements
;  3. Find the dimensions of the smallest array

; Step 1: find all array arguments
nDims = [SIZE(month,/N_DIMENSIONS), SIZE(day,/N_DIMENSIONS), $
	SIZE(year,/N_DIMENSIONS), SIZE(hour,/N_DIMENSIONS), $
	SIZE(minute,/N_DIMENSIONS), SIZE(second,/N_DIMENSIONS)]
arrays = WHERE(nDims GE 1)

nJulian = 1L    ; assume everything is a scalar
IF (arrays[0] GE 0) THEN BEGIN
	; Step 2: find the smallest number of elements
	nElement = [N_ELEMENTS(month), N_ELEMENTS(day), $
		N_ELEMENTS(year), N_ELEMENTS(hour), $
		N_ELEMENTS(minute), N_ELEMENTS(second)]
	nJulian = MIN(nElement[arrays], whichVar)
	; step 3: find dimensions of the smallest array
	CASE arrays[whichVar] OF
	0: julianDims = SIZE(month,/DIMENSIONS)
	1: julianDims = SIZE(day,/DIMENSIONS)
	2: julianDims = SIZE(year,/DIMENSIONS)
	3: julianDims = SIZE(hour,/DIMENSIONS)
	4: julianDims = SIZE(minute,/DIMENSIONS)
	5: julianDims = SIZE(second,/DIMENSIONS)
	ENDCASE
ENDIF

d_Second = 0d  ; defaults
d_Minute = 0d
d_Hour = 0d
; convert all Arguments to appropriate array size & type
SWITCH np OF  ; use switch so we fall thru all arguments...
6: d_Second = (SIZE(second,/N_DIMENSIONS) GT 0) ? $
	second[0:nJulian-1] : second
5: d_Minute = (SIZE(minute,/N_DIMENSIONS) GT 0) ? $
	minute[0:nJulian-1] : minute
4: d_Hour = (SIZE(hour,/N_DIMENSIONS) GT 0) ? $
	hour[0:nJulian-1] : hour
3: BEGIN ; convert m,d,y to type LONG
	L_MONTH = (SIZE(month,/N_DIMENSIONS) GT 0) ? $
		LONG(month[0:nJulian-1]) : LONG(month)
	L_DAY = (SIZE(day,/N_DIMENSIONS) GT 0) ? $
		LONG(day[0:nJulian-1]) : LONG(day)
	L_YEAR = (SIZE(year,/N_DIMENSIONS) GT 0) ? $
		LONG(year[0:nJulian-1]) : LONG(year)
	END
ENDSWITCH


min_calendar = -4716
max_calendar = 5000000
minn = MIN(l_year, MAX=maxx)
IF (minn LT min_calendar) OR (maxx GT max_calendar) THEN MESSAGE, $
	'Value of Julian date is out of allowed range.'
if (MAX(L_YEAR eq 0) NE 0) then message, $
	'There is no year zero in the civil calendar.'


bc = (L_YEAR LT 0)
L_YEAR = TEMPORARY(L_YEAR) + TEMPORARY(bc)
inJanFeb = (L_MONTH LE 2)
JY = L_YEAR - inJanFeb
JM = L_MONTH + (1b + 12b*TEMPORARY(inJanFeb))


JUL = floor(365.25d * JY) + floor(30.6001d*TEMPORARY(JM)) + L_DAY + 1720995L


; Test whether to change to Gregorian Calandar.
IF (MIN(JUL) GE GREG) THEN BEGIN  ; change all dates
	JA = long(0.01d * TEMPORARY(JY))
	JUL = TEMPORARY(JUL) + 2L - JA + long(0.25d * JA)
ENDIF ELSE BEGIN
	gregChange = WHERE(JUL ge GREG, ngreg)
	IF (ngreg GT 0) THEN BEGIN
		JA = long(0.01d * JY[gregChange])
		JUL[gregChange] = JUL[gregChange] + 2L - JA + long(0.25d * JA)
	ENDIF
ENDELSE


; hour,minute,second?
IF (np GT 3) THEN BEGIN ; yes, compute the fractional Julian date
; Add a small offset so we get the hours, minutes, & seconds back correctly
; if we convert the Julian dates back. This offset is proportional to the
; Julian date, so small dates (a long, long time ago) will be "more" accurate.
	eps = (MACHAR(/DOUBLE)).eps
	eps = eps*ABS(jul) > eps
; For Hours, divide by 24, then subtract 0.5, in case we have unsigned ints.
	jul = TEMPORARY(JUL) + ( (TEMPORARY(d_Hour)/24d - 0.5d) + $
		TEMPORARY(d_Minute)/1440d + TEMPORARY(d_Second)/86400d + eps )
ENDIF

; check to see if we need to reform vector to array of correct dimensions
IF (N_ELEMENTS(julianDims) GT 1) THEN $
	JUL = REFORM(TEMPORARY(JUL), julianDims)

RETURN, jul

END

PRO MOONPHASE,jd,phase_angle_M,alt_moon,alt_sun,obsname
;-----------------------------------------------------------------------
; Set various constants.
;-----------------------------------------------------------------------
RADEG  = 180.0/!PI
DRADEG = 180.0D/!DPI
AU = 149.6d+6       ; mean Sun-Earth distance     [km]
Rearth = 6365.0D    ; Earth radius                [km]
Rmoon = 1737.4D     ; Moon radius                 [km]
Dse = AU            ; default Sun-Earth distance  [km]
Dem = 384400.0D     ; default Earth-Moon distance [km]
	MOONPOS, jd, ra_moon, DECmoon, dis
distance=dis/6371.
;obsname='cfht'
eq2hor, ra_moon, DECmoon, jd, alt_moon, az_moon, ha_moon,  OBSNAME=obsname
		SUNPOS, jd, ra_sun, DECsun
eq2hor, ra_sun, DECsun, jd, alt_sun, az, ha, OBSNAME=obsname

RAdiff = ra_moon - ra_sun
sign = +1
if (RAdiff GT 180.0) OR (RAdiff LT 0.0 AND RAdiff GT -180.0) then sign = -1
phase_angle_E = sign*acos( sin(DECsun/DRADEG)*sin(DECmoon/DRADEG) + cos(DECsun/DRADEG)*cos(DECmoon/DRADEG)*cos(RAdiff/DRADEG) ) * DRADEG
phase_angle_M = -atan( Dse*sin(phase_angle_E/DRADEG), Dem - Dse*cos(phase_angle_E/DRADEG) ) * DRADEG


return
end

PRO get_moon_rise_set,jd,jd_rise,jd_set
MOONPHASE,jd,phase_angle_M,alt_moon,alt_sun
moon_sign=alt_moon/abs(alt_moon)
moon_lim=0.0
step=1./24./12.	; step is 5 minutes
;--------------------------------------------------------------------------------
altitude=911
time=911
for ijd=jd-0.6,jd+0.6,step do begin
	MOONPHASE,ijd,phase_angle_M,alt_moon,alt_sun
	altitude=[altitude,alt_moon]
	time=[time,ijd]
endfor
idx=where(altitude ne 911)
altitude=altitude(idx)
time=time(idx)
sign=deriv(altitude)/abs(deriv(altitude))
plot,time,sign,yrange=[-1.1,1.1]
oplot,[jd,jd],[!Y.crange]

for i=1,n_elements(altitude)-2,1 do begin
	if (sign(i-1) gt 0 and sign(i+1) lt 0) then jd_set=time(i)
	if (sign(i-1) lt 0 and sign(i+1) gt 0) then jd_rise=time(i)
endfor
return
end

;-------------------------------------------------------------------------------------
; Code to set up the starting and ending time (in JD format) for periods of lunar observability
; Version 1. June 2010
;-------------------------------------------------------------------------------------

;-------------------------------------------------------------------------------------
; Specify the observatory name
;-------------------------------------------------------------------------------------
obsname='cfht'

openw,66,'Moon_table1.dat'
openw,67,'Moon_table2.dat'
sunlimit=0.0
moonlimit=30.0
fmt='(f15.7,2(1x,f8.3))'
for JD=double(julday(12,7,2010,12,1,0)),double(julday(1,7,2012,12,1,0)),1. do begin
print,'------------------------------------------------------------------------'
print,'Checking JD:',JD
; for that day lay out sun and moon at 1 minute steps
openw,23,'temporary.dat'
tstep=1./24./4.		; in days
tstep=1./24./60.	; in days
for xJD=JD,JD+1.0,tstep do begin
MOONPHASE,xjd,phase_angle_M,alt_moon,alt_sun,obsname
printf,23,format=fmt,xJD,alt_moon,alt_sun
endfor
close,23
; now look at the position of sun and moon and find rise and set times
data=get_data('temporary.dat')
time=reform(data(0,*))
alt_moon=reform(data(1,*))
alt_sun=reform(data(2,*))
plot,time,alt_sun,psym=7,xstyle=1
plots,[!x.crange],[sunlimit,sunlimit]
plots,[!x.crange],[moonlimit,moonlimit]
oplot,time,alt_moon,psym=6
n=n_elements(time)
fmt2='(a33,1x,f12.3,2(1x,f9.2),2(1x,i2),1x,i4,2(1x,i2),1x,f7.2)'
	stoptime=1e33
	startime=-1e33
for k=1,n-1,1 do begin
	caldat,time(k),mm,dd,yy,hr,mi,se
; case of sun below limit moon rising
if (alt_sun(k) lt sunlimit and alt_moon(k) gt moonlimit and alt_moon(k-1) le moonlimit) then begin
	print,format=fmt2, 'START: Sun down, Moon rising at: ',time(k),alt_sun(k),alt_moon(k),mm,dd,yy,hr,mi,se
	plots,[time(k),time(k)],[!Y.crange]
	startime=time(k)
endif
; case of sun below limit moon setting
if (alt_sun(k) lt sunlimit and alt_moon(k) le moonlimit and alt_moon(k-1) gt moonlimit) then begin
	print,format=fmt2, 'STOP: Sun down, Moon setting at: ',time(k),alt_sun(k),alt_moon(k),mm,dd,yy,hr,mi,se
	plots,[time(k),time(k)],[!Y.crange]
	stoptime=time(k)
endif
; case of moon above limit as sun sets
if (alt_moon(k) gt moonlimit and alt_sun(k) le sunlimit and alt_sun(k-1) gt sunlimit) then begin
	print,format=fmt2, 'START: Moon up, sun setting at: ',time(k),alt_sun(k),alt_moon(k),mm,dd,yy,hr,mi,se
	plots,[time(k),time(k)],[!Y.crange]
	startime=time(k)
endif
; case of moon above limit as sun rises
if (alt_moon(k) gt moonlimit and alt_sun(k) gt sunlimit and alt_sun(k-1) le sunlimit) then begin
	print,format=fmt2, 'STOP: Moon up, sun rising at: ',time(k),alt_sun(k),alt_moon(k),mm,dd,yy,hr,mi,se
	plots,[time(k),time(k)],[!Y.crange]
	stoptime=time(k)
endif
endfor
print,stoptime-startime
if (stoptime-startime lt 1e3) then begin
	print,'Duration : ',(stoptime-startime)*24.,' hrs.'
	printf,66,format='(1x,f15.1,2(1x,f15.7))',JD,startime,stoptime
	printf,67,format='(1x,f15.1,2(1x,f15.7))',JD,startime,stoptime
	print,format='(1x,f15.1,2(1x,f15.7))',JD,startime,stoptime
endif
if (stoptime-startime gt 1e3) then begin
	printf,66,format='(1x,f15.1,1x,a)',JD,' ---------       -----------'
	print,format='(1x,f15.1,1x,a)',JD,' ---------       -----------'
endif
endfor
close,66	; close the master table
close,67	; close the other master table
; read the master table and now make a list of start/stop for the CONTIGUOUS periods
openw,44,'Observability_periods_'+obsname+'.dat'
data=get_data('Moon_table2.dat')
starting=reform(data(1,*))
stopping=reform(data(2,*))
n=n_elements(starting)
ic=7123	; this is the unique observing night number
for i=0,n-1,1 do begin
sta=starting(i)
; find the first number on the stopping list AFTER sta
diff=stopping-sta
idx=where(diff gt 0)
if (idx(0) ne -1) then begin
sto=stopping(idx(0))
print,format='(1x,i5,2(1x,f15.7))',ic,sta,sto
printf,44,format='(1x,i5,2(1x,f15.7))',ic,sta,sto
ic=ic+1
endif
endfor
close,44
end
