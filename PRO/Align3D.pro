; Align3D.PRO
;
; Routines to accomplish alignment of two 3D data sets.
;
; Written by: Richard Ketcham
;             Jackson School of Geosciences
;             The University of Texas at Austin
;             ketcham@mail.utexas.edu


; ========================================================================
; PROCEDURE NAME:
; A3D_MakeDistMatrix
;
; PURPOSE:
;   Creates a matrix in which each pixel value contains its distance from
; the center of a square image, in pixels.  It can be used to identify
; rotationally equivalent positions.
;
; POSITIONAL PARAMETERS:
;   imageDim: Dimension, in pixels, of the square image.
;
; OUTPUTS:
;   Returns an floating-point matrix with the same dimensions as the
; square image, with each value indicating its distance from the center.
;
; KEYWORD PARAMETERS:
;   none
;
; EXAMPLE:
;       ; Create distance matrix for processing 512x512 images.
;       dist = A3D_MakeDistMatrix(512)
;
; MODIFICATION HISTORY:
;   Written by Richard Ketcham, 2001
; ========================================================================
FUNCTION A3D_MakeDistMatrix, imageDim
  midPoint = (imageDim - 1.0)/2.0
  disp1 = (IndGen(imageDim,/Float) - midPoint)^2
  dist = disp1 # (FltArr(imageDim)+1.0) + (FltArr(imageDim)+1.0) # disp1
  return, sqrt(dist)
End


; ========================================================================
; PROCEDURE NAME:
; A3D_CompileAnnuli
;
; PURPOSE:
;   Creates a series of arrays that group pixels with the same distance
; the center of a square image.
;   Note that common courtesy dictates that, after one is through with the
; information this routine provides, one  should call A3D_DeallocateAnnuli
; to give the memory back.
;
; POSITIONAL PARAMETERS:
;   imageDim: Dimension, in pixels, of a square image.
;
; OUTPUTS:
;   Returns an array of pointers to arrays.  Each array contains a list of
; image indices which have a distance from the center in the range
; [index,index+1].
;
; KEYWORD PARAMETERS:
;   none
;
; EXAMPLE:
;       ; Create annuli for processing 512x512 images.
;       annuli = A3D_CompileAnnuli(512)
;
; MODIFICATION HISTORY:
;   Written by Richard Ketcham, 2001
; ========================================================================
FUNCTION A3D_CompileAnnuli, imageDim
; First, compile a 2D array in which each value corresponds to distance from the center
  dist = A3D_MakeDistMatrix(imageDim)

  radius = imageDim/2
; Allocate pointers to hold annuli at each 1-pixel increment
; Add an extra layer for pixels on border of circle

  annuli = PtrArr(radius+2)

; Create the annuli
  hist = Histogram(dist, REVERSE_INDICES=ind, MIN=0, BINSIZE=1.0)
  for i=0,radius+1 do begin
    annulus = ind[ind[i]:ind[i+1]-1]
    annuli[i] = Ptr_New(annulus, /No_Copy)
  endfor

; Clear memory
  dist = 0
  hist = 0

  return, annuli
End


; ========================================================================
; PROCEDURE NAME:
; A3D_DeallocateAnnuli
;
; PURPOSE:
;   Deallocates the array of pointers holding annuli created by
; A3D_CompileAnnuli.
;
; POSITIONAL PARAMETERS:
;   annuli: Array of pointers returned by A3D_CompileAnnuli.
;
; OUTPUTS:
;   none
;
; KEYWORD PARAMETERS:
;   none
;
; EXAMPLE:
;       ; Deallocate annuli
;       A3D_DeallocateAnnuli, annuli
;
; MODIFICATION HISTORY:
;   Written by Richard Ketcham, 2001
; ========================================================================
Pro A3D_DeallocateAnnuli, annuli
  s = Size(annuli)
  for i=0,s[1]-1 do if Ptr_Valid(annuli[i]) then Ptr_Free, annuli[i]
  annuli = 0
End


; ========================================================================
; PROCEDURE NAME:
; A3D_GetPoints
;
; PURPOSE:
;   Selects a series of points to used for matching two volumetric data
; sets.  The routine first eliminates a user-specified boundary from
; consideration, and then finds the user-requested number of the highest
; valued voxels.  The coordinates of these voxels are returned.
;   It is assumed that zero is an "invalid" value in the data volume, only
; occupying the corners of the original slices images not containing data.
;
; POSITIONAL PARAMETERS:
;   wholeVol: Pointer to a 3D array of data.
;   sub: IntArr(6) indicating range within wholeVol to inspect in form
;     [xMin, xMax, yMin, yMax, zMin, zMax]
;   numDel: Thickness of the boundary around the subvolume not to
;     consider.
;   numPts: Number of points to find.
;
; OUTPUTS:
;   Returns a FltArr(3,numPts) containing the indices of the <numPts>
; voxels with the highest values.
;
; KEYWORD PARAMETERS:
;   none
;
; EXAMPLE:
;   ; Find this highest-valued 128 voxels in the upper-x, lower-y, lower-z
;   ; octant of the volume pointed to by volPtr.
;   sz = Size(*volPtr, /DIMENSIONS)
;   pts = A3D_GetPoints(volPtr, [sz[0]/2, sz[0]-1, 0, sz[1]/2-1, 0, sz[2]/2-1], 10, 128)
;
; MODIFICATION HISTORY:
;   Written by Richard Ketcham, 2001
; ========================================================================
Function A3D_GetPoints, wholeVol, sub, numDel, numPts

  vol = (*wholeVol)[sub[0]:sub[1], sub[2]:sub[3], sub[4]:sub[5]]

  dim = Size(vol, /Dimensions)

; First, find unwanted border voxels
  inv2d = vol[*,*,dim[2]/2] GT 0
  struct = BytArr(3,3) + 1
  for i=0,numDel-1 do inv2d = Erode(inv2d, struct)

; Remove invalid voxels, including top or bottom
  for i=0,dim[2]-1 do begin
    if (sub[4] EQ 0) then begin
      if (i LT numDel) then vol[*,*,i] = 0 $
      else vol[*,*,i] = vol[*,*,i]*inv2d
    endif else begin
      if (i GE dim[2]-numDel) then vol[*,*,i] = 0 $
      else vol[*,*,i] = vol[*,*,i]*inv2d
    endelse
  endfor

; Get grayscales in volume
  hist = Histogram(vol, REVERSE_INDICES=ind)

; Get indices of highest numpts grayscales
  sel = ind[(N_Elements(ind)-numPts):(N_Elements(ind)-1)]

; Convert to indices
  pts = B3D_ArrayIndices([3,dim],sel)

; Adjust for subvolume
  if (sub[0] NE 0) then pts[0,*] = pts[0,*] + sub[0]
  if (sub[2] NE 0) then pts[1,*] = pts[1,*] + sub[2]
  if (sub[4] NE 0) then pts[2,*] = pts[2,*] + sub[4]

  return, pts
End


; ========================================================================
; PROCEDURE NAME:
; Align3D
;
; PURPOSE:
;   Aligns two nearly-aligned data sets, and interpolates one so it
; matches the other as closely as possible.  This implementation is based
; on a sample being scanned twice, once "dry" and the other infiltrated
; with a fluid ("wet").  It attempts to find a series of tranlational and
; rotational displacements: (dX, dY, dZ, phiX, phiY, phiZ) that maps the
; "wet" data set to the "dry" one.  Translational displacements are in
; voxels and rotational displacements are in degrees.  If the SCALE
; keyword is set, a seventh parameter is added (dS) that allows the "wet"
; data to be uniformly downscaled to compensate for expansion.
;   The routine assumes a certain directory and naming structure to
; streamline the process.  The starting point is a root directory with the
; sample number as its name, and subdirectories containing the "dry" and
; "wet" data having the same name with "d" and "w" appended, respectively.
; The data files should be in TIFF format with ".TIF" extensions, and be
; in alphabetical order.
; An example directory/filename configuration:
;   c:/files/17r
;     c:/files/17r/17rd
;       17rd0001.tif
;       17rd0002.tif
;       ... (etc.)
;     c:/files/17r/17rw
;       17rw0001.tif
;       17rw0002.tif
;       ... (etc.)
;
; POSITIONAL PARAMETERS:
;   numdel: Number of border pixels to omit from consideration. Default=10
;
; KEYWORD PARAMETERS:
;   CORREL: Set to 1 to use correlation as image-fitting merit function.
;     Otherwise minimizes the number of large outliers.
;   POINTS: Set to use point fitting, based on <2^points> points.
;   IMAGE_INDS: For image fitting, set to a 2-element array to specify
;     slice numbers to use.  Default is 3*numdel from each end of stack.
;   INITGUESS: FltArr(6) with initial guess: [dX, dY, dY, phiX, phiY, phiZ];
;     if SCALE is set, it's a FltArr(7) with the seventh paramater being dS.
;   ADJUST_FINAL: Do a rotational adjustment on each interpolated image.
;   WET: Pointer to "wet" image stack; set to skip reading, or to return stack.
;   DRY: Pointer to "dry" image stack; set to skip reading, or to return stack.
;   FINAL_COEFS: FltArr(6) (or 7 is SCALE set) of final coefficients. Set to
;     just regenerate the interpolated images.
;   SHOW: If image fitting is used, setting this will show each attempted fit.
;   COMBO_MEDIAN: Set to bin width of median filter to smooth right side of
;     "combo" images.  Default=3; =1 turns filter off (=0 does not!)
;   SCALE: If set, allows scale to be adjusted to account for uniform
;     expansion of the wet material.  Set to a value between 0.9 and 1.0 as
;     an initial guess for the fractional contraction to scale the wet images
;     back down to the dry.
;
; OUTPUTS:
;   Creates three directories with the interpolated wet images, the difference
; images, and compressed "combo" images showing scan and difference data side
; by side.  Also writes a file "Align3D.log" with fitted parameters.  If WET
; and/or DRY keyword parameters are specified and they point to empty
; variables, these variables are assigned to pointers holding the appropriate
; data set. Freeing these pointers (using Ptr_Free) is then the responsibility
; of the user.
;
; EXAMPLE:
;     Align3D, 10, DRY=d8, WET=w8, /ADJUST_FINAL, /SHOW, /CORREL
;
; NOTES:
;   This routine only works if the two data sets are fairly close to each
; other, or if the initial guess places them close to each other.  "Fairly
; close" is roughly within 3 slices of each other and within 10 pixels and
; and 10 degrees of each other in any slice, and less than 2 degrees of
; tilting (if a wider range is desired the "range" variable can be reset,
; although a larger range makes it more likely that a convergence point
; will not be found).
;   If a good initial guess is required, place a break point at the line
; marked below with "***", and run the routine using image fitting, and
; the SHOW keyword set.  Then, when the program reaches the break point,
; run a series of commands:
;   print, A3D_TransFunction_Img(dX, dY, dZ, phiX, phiY, phiZ)
; changing the parameters as necesary until the data sets seem fairly
; close to each other.  Then, set the variable "initGuess" to the vector
; of coefficients you've found and continue execution.  If you want to use
; an alternative fitting method, after you've got your initial guess using
; the above method you can terminate execution of the routine and run it
; again using the INIT_GUESS keyword to set your starting point.
;
; MODIFICATION HISTORY:
;   Written by Richard Ketcham, 4/16/02
; 11/22/02 RAK: Rearranged input properties
; 8/5/03 RAK: Rearranged input again, added options.
; ========================================================================
Pro Align3D, numdel, CORREL=useCorrel, POINTS=m, IMAGE_INDS=imageInds, $
    INITGUESS=initGuess, WET=wet, DRY=dry, ADJUST_FINAL=adjFinal, $
    FINAL_COEFS=coefs, SHOW=show, COMBO_MEDIAN=comboMedian, SCALE=scale

  common A3D_Data_Points, ptTarget, pts, vals, numPts, hdim
  common A3D_Data_Image, imgTarget, midLevel, correl, tailSize, border, $
      dim, topImg, botImg, topPts, botPts, showImgFitting
  common A3D_Tweak, ImgWinIndex, CharPixmapIndex

; Check input
  if (N_Params() EQ 0) then numdel = 10

  if Keyword_Set(m) then begin
    m = Round(m)
    if (m LT 2) OR (m GT 12) then begin
      clicked = Dialog_Message('Points should be integer in range 2-12', /Error)
      return
    endif
  endif

  if NOT Keyword_Set(comboMedian) then comboMedian = 3

  if Keyword_Set(scale) then begin
    if (scale GT 1) OR (scale LT 0.9) then begin
      clicked = Dialog_Message('SCALE should be in range 0.9-1.0', /Error)
      return
    endif
    if (scale EQ 1) then scale = 0.995  ; Default 0.5%
  endif

; Set bitmap variables for tweaking, if necessary.
  if Keyword_Set(adjFinal) then begin
    ImgWinIndex = -1
    CharPixmapIndex = -1
  endif

; Get starting directory
  baseDir = Dialog_Pickfile(/read, /directory)
; Last character is directory character (Only tested for Windows IDL)
  dirChar = StrMid(baseDir,Strlen(baseDir)-1)
; Extract prefix for sample
  tempStr = StrMid(baseDir, 0, StrLen(baseDir)-1)
  pos = StrPos(tempStr, dirChar, /REVERSE_SEARCH)
  rootName = StrMid(tempStr, pos+1)

; Read Data
  if (NOT Keyword_Set(dry)) OR (NOT Ptr_Valid(dry)) then begin
    Print, 'Reading dry stack'
    dry = B3D_ReadTiffs('tif', DIRECTORY=baseDir+rootName+"d"+dirChar, /NO_LOOK)
  endif
  if (NOT Keyword_Set(wet)) OR (NOT Ptr_Valid(wet)) then begin
    Print, 'Reading wet stack'
    wet = B3D_ReadTiffs('tif', DIRECTORY=baseDir+rootName+"w"+dirChar, /NO_LOOK)
  endif

  dim = Size(*dry, /Dimensions)
  hdim = dim/2

; Set up calculations
  shiftVal = Max(*dry) LE 4095 ? -4 : -8
  midLevel = 2^(7-shiftVal) - 1
; Estimate standard deviation if image fitting or tweaking
  if (NOT Keyword_Set(points)) OR Keyword_Set(adjFinal) then begin
    diffImg = Reform((*dry)[*,*,hdim]*1.0) - Reform((*dry)[*,*,hdim+1]*1.0)
    estSD = StdDev(diffImg)
    tailMult = 4
    tailSize = estSD*tailMult
  endif

  if NOT Keyword_Set(points) then begin   ; Image fitting
    func = 'A3D_TransFunction_Img'
    correl = Keyword_Set(useCorrel)
    imgTarget = wet
; If images are square, find border to erase.  Otherwise, punt and hope for the best
    if (dim[0] EQ dim[1]) then begin
      ann = A3D_CompileAnnuli(dim[1])
      eraseRad = dim[1]/2
      blackBorder = Where(Reform((*dry)[*,*,hdim]) EQ 0)
      border = [blackBorder, *ann[eraseRad+1], *ann[eraseRad], *ann[eraseRad-1]]
      if (numdel GT 1) then begin
        for i=0,numDel do border = [border, *ann[eraseRad-i]]
      endif
      border = border[UNIQ(border, SORT(border))]

      A3D_DeallocateAnnuli, ann
    endif else border = [0]

; Set up display window, if desired
    showImgFitting = Keyword_Set(SHOW)
    if (showImgFitting) then $
      Window, /Free, Title='Fitting', xsize = dim[0]*2, ysize = dim[1]

; Get slices and points to interpolate
    intSlice = LonArr(dim[0],dim[1])
    procPts = IndGen(dim[0]*dim[1], /LONG)
    topPts = B3D_ArrayIndices([3,dim],procPts)
    botPts = topPts
    if (N_Elements(imageInds) EQ 2) then begin
      topPts[2,*] = imageInds[0]
      botPts[2,*] = imageInds[1]
      topImg = Reform((*dry)[*,*,imageInds[0]]*1.0)
      botImg = Reform((*dry)[*,*,imageInds[1]]*1.0)
    endif else begin
      topPts[2,*] = 3*numdel
      botPts[2,*] = dim[2]-3*numdel
      topImg = Reform((*dry)[*,*,3*numdel]*1.0)
      botImg = Reform((*dry)[*,*,dim[2]-3*numdel]*1.0)
    endelse

  endif else begin
    func = 'A3D_TransFunction_Pt'
; Point-based approach; first calculate the number of points
    ptTarget = wet
    numPts = 2^m
    octPts = 2^(m-3)
; Then, find highest-valued points in each octant
    pts = LonArr(3,numPts)
; Get points in each octant
    Print, 'Finding highest points in each octant'
    pts[0,0] = A3D_GetPoints(dry, [0, hdim[0]-1, 0, hdim[1]-1, 0, hdim[2]-1], numdel, octPts)
    pts[0,octPts] = A3D_GetPoints(dry, [hdim[0], dim[0]-1, 0, hdim[1]-1, 0, hdim[2]-1], numdel, octPts)
    pts[0,2*octPts] = A3D_GetPoints(dry, [0, hdim[0]-1, hdim[1], dim[1]-1, 0, hdim[2]-1], numdel, octPts)
    pts[0,3*octPts] = A3D_GetPoints(dry, [hdim[0], dim[0]-1, hdim[1], dim[1]-1, 0, hdim[2]-1], numdel, octPts)
    pts[0,4*octPts] = A3D_GetPoints(dry, [0, hdim[0]-1, 0, hdim[1]-1, hdim[2], dim[2]-1], numdel, octPts)
    pts[0,5*octPts] = A3D_GetPoints(dry, [hdim[0], dim[0]-1, 0, hdim[1]-1, hdim[2], dim[2]-1], numdel, octPts)
    pts[0,6*octPts] = A3D_GetPoints(dry, [0, hdim[0]-1, hdim[1], dim[1]-1, hdim[2], dim[2]-1], numdel, octPts)
    pts[0,7*octPts] = A3D_GetPoints(dry, [hdim[0], dim[0]-1, hdim[1], dim[1]-1, hdim[2], dim[2]-1], numdel, octPts)
;
; Get values at each point
    vals = FltArr(numPts)
    for i=0,numPts-1 do vals[i] = (*dry)[pts[0,i],pts[1,i],pts[2,i]]
  endelse

; Set up iteration
; Parameters for transform are in array: [dX, dY, dZ, phiX, phiY, phiZ]
;   dX, dY, dX: Translation in x,y,z, in voxels
;   phiX, phiY, phiZ: Rotations around each axis, in degrees
  if NOT Keyword_Set(initGuess) then begin
    initGuess  = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    if Keyword_Set(scale) then initGuess = [initGuess, scale]
  endif

; *** If searching for an initial guess "by hand", put a break point at the next line,
; *** and follow instructions in "NOTES" above.
  range = [10.0, 10.0, 3.0, 2.0, 2.0, 10.0]
  if Keyword_Set(scale) then range = [range, 1.0-scale]


  if NOT Keyword_Set(coefs) then $
   result = Amoeba(1.e-6, FUNCTION_NAME=func, P0=initGuess, SCALE=range) $
  else result = coefs

  print, 'The Answer is: ', result

; Create transformation matrix
  trans = Identity(4)
; Put center at origin
  T3D, trans, MATRIX=trans, TRANSLATE=-hdim
; Rotate about all 3 axes
  T3D, trans, MATRIX=trans, ROTATE=[result[3],result[4],result[5]]
; Scale if requested
  if Keyword_Set(scale) then T3D, trans, MATRIX=trans, scale=Replicate(result[6],3)
; Put center back
  T3D, trans, MATRIX=trans, TRANSLATE=hdim
; Translate
  T3D, trans, MATRIX=trans, TRANSLATE=[result[0],result[1],result[2]]

; Create a new data stack...
  intSlice = LonArr(dim[0],dim[1])
  procPts = IndGen(dim[0]*dim[1], /LONG)
  slicePts = B3D_ArrayIndices([3,dim],procPts)

  prefix1 = baseDir+rootName+"wetint"
  File_MkDir, prefix1
  prefix1 = prefix1 + dirChar+rootName+"wi"

  prefix2 = baseDir+rootName+"diff"
  File_MkDir, prefix2
  prefix2 = prefix2 + dirChar+rootName+"dif"

  prefix3 = baseDir+rootName+"combo"
  File_MkDir, prefix3
  prefix3 = prefix3 + dirChar+rootName+"cmb"

  offset = midLevel

  totalDiff = 0
  totalNumVal = 0

  for sliceNum = 0,dim[2]-1 do begin
    print, 'Interpolating slice ', sliceNum+1, ' of ', dim[2]
    trPts = Vert_T3D(slicePts, MATRIX=trans)
    trVals = Interpolate(*wet, trPts[0,*], trPts[1,*], trPts[2,*], MISSING=0L)
    intSlice[*] = trVals[*]

    if Keyword_Set(adjFinal) then $
      A3D_TweakRotation, (*dry)[*,*,sliceNum], intSlice, estSD, /SHOW

    intSlice[blackBorder] = 0
    fileName = prefix1+string(sliceNum+1,FORMAT='(I3.3)') + '.tif'
    write_tiff,fileName,intSlice,/short, ORIENTATION=0

; Difference slice
    diffSlice = Long(1.0*intSlice - (*dry)[*,*,sliceNum] + offset)
    inval = Where((intSlice EQ 0) OR ((*dry)[*,*,sliceNum] EQ 0), numInval)
    diffSlice[inval] = 0
    fileName = prefix2+string(sliceNum+1,FORMAT='(I3.3)') + '.tif'
    write_tiff,fileName,diffSlice,/short, ORIENTATION=0

    totalDiff = totalDiff + TOTAL(diffSlice)
    totalNumVal = totalNumVal + N_Elements(diffSlice) - numInval

; Side by side
    comboImg = BytArr(2*dim[0], dim[1])
    comboImg[0:511, *] = Byte(IShft(intSlice, -8))
    if (comboMedian GT 1) then filtSlice = 1.0*Median(diffSlice, comboMedian) $
    else filtSlice = 1.0*diffSlice
    filtSlice = ((filtSlice/256.)-121.)*8
    filtSlice = (filtSlice > 0) < 255
    comboImg[512:1023,*] = Byte(filtSlice)
    fileName = prefix3+string(sliceNum+1,FORMAT='(I3.3)') + '.jpg'
    write_jpeg,fileName,comboImg ; ,/ORDER

    slicePts[2,*] = sliceNum + 1
  endfor

  meanDiff = (1.0*totalDiff/totalNumVal) - offset
  logFileName = baseDir+rootName+"align.log"
  tab = String(9B)
  OpenW, unit, logFileName, /GET_LUN
  PrintF, unit, 'Alignment results from sample ', rootName
  PrintF, unit, 'Fitting parameters'
  if Keyword_Set(points) then PrintF, unit, 'Point fitting, m=', m  $
  else PrintF, unit, 'Image fitting'
  if Keyword_Set(scale) then begin
    PrintF, unit, 'dX', tab, 'dY', tab, 'dZ', tab, 'rotX', tab, 'rotY', tab, 'rotZ', tab, 'scale'
    PrintF, unit, result[0], tab, result[1], tab, result[2], tab, result[3], tab, result[4], tab, result[5], tab, result[6]
  endif else begin
    PrintF, unit, 'dX', tab, 'dY', tab, 'dZ', tab, 'rotX', tab, 'rotY', tab, 'rotZ'
    PrintF, unit, result[0], tab, result[1], tab, result[2], tab, result[3], tab, result[4], tab, result[5]
  endelse
  PrintF, unit, 'Total diff', tab, 'Mean diff', tab, 'Num Valid Voxels', tab, 'Merit value'
  PrintF, unit, totalDiff, tab, meanDiff, tab, totalNumVal, tab, call_function(func, result)

  Close, unit
  Free_Lun, unit

  if NOT Arg_Present(dry) then Ptr_Free, dry
  if NOT Arg_Present(wet) then Ptr_Free, wet

  if Keyword_Set(adjFinal) then begin
    WDelete, ImgWinIndex
    WDelete, CharPixmapIndex
  endif

  print, 'Finished!'
End


; ========================================================================
; PROCEDURE NAME:
; A3D_TransFunction_Pt
;
; PURPOSE:
;   Implements the merit function used for point-based fitting between
; two data volumes.  This function is called repeatedly by the IDL routine
; AMOEBA with varying parameters.  The merit function is the mean sum of
; squared difference between corresponding point values in the dry and
; interpolated wet data volumes.
;
; POSITIONAL PARAMETERS:
;   c: The vector of coefficients: [dX, dY, dY, phiX, phiY, phiZ]
;
; OUTPUTS:
;   The merit function value.
;
; KEYWORD PARAMETERS:
;   none
;
; COMMON BLOCKS:
;   A3D_Data_Points: ptTarget, pts, vals, numPts, hdim
;     ptTarget: Pointer to the "target" (wet) data set
;     pts: Voxel coordinates of test points in the dry data set.
;     vals: Voxel values of test points in the dry data set.
;     numPts: Number of test points.
;     hDim: Half-dimensions of the data set (center of rotation).
;
; EXAMPLE:
;   ; Evaluate the goodness of fit of testCoefs:
;   meritVal = A3D_TransFunction_Pt(testCoefs)
;
; MODIFICATION HISTORY:
;   Written by Richard Ketcham, April 2002
; ========================================================================
Function A3D_TransFunction_Pt, c
  common A3D_Data_Points

; Create transformation matrix
  trans = Identity(4)
; Put center at origin
  T3D, trans, MATRIX=trans, TRANSLATE=-hdim
; Rotate about all 3 axes
  T3D, trans, MATRIX=trans, ROTATE=[c[3],c[4],c[5]]
; Scale if requested
  if (N_Elements(c) EQ 7) then T3D, trans, MATRIX=trans, scale=Replicate(c[6],3)
; Put center back
  T3D, trans, MATRIX=trans, TRANSLATE=hdim
; Translate as necessary
  T3D, trans, MATRIX=trans, TRANSLATE=[c[0],c[1],c[2]]

; Apply it to coordinates
  trPts = Vert_T3D(pts, MATRIX=trans)

; Interpolate
  trVals = Interpolate(*ptTarget, trPts[0,*], trPts[1,*], trPts[2,*])

; Sum squares
  normSumSq = TOTAL((vals-trvals)^2)/numPts

  print, [c, normSumSq]

  return, normSumSq
End


; ========================================================================
; PROCEDURE NAME:
; A3D_TransFunction_Img
;
; PURPOSE:
;   Implements the merit functions used for image-based fitting between
; two data volumes.  This routine is called repeatedly by the IDL routine
; AMOEBA with varying parameters.  There are two possible merit functions,
; each based on subtracting two images: (a) the number of voxels exceeding
; a prescribed departure from the mean; and (b) the sum of squared
; differences (i.e. correlation).  The function to use is defined by the
; "correl" variable in the A3D_Data_Image common block.
;
; INPUTS:
;   c: The vector of coefficients: [dX, dY, dY, phiX, phiY, phiZ]
;
; OUTPUTS:
;   The merit function value.
;
; KEYWORD PARAMETERS:
;   none
;
; COMMON BLOCKS:
;   A3D_Data_Image: imgTarget, midLevel, tailSize, border, dim, topImg, $
;         botImg, topPts, botPts, showImgFitting
;     imgTarget: Pointer to the "target" (wet) data set
;     midLevel: Middle grayscale level of image data
;     correl: If zero, use number of outliers; if not, use correlation
;     tailSize: Grayscale excursion of differenced images to count
;     border: Indices of image boundary to exclude from consideration
;     dim: Data set dimensions
;     topImg: Top test image from dry data volume
;     botImg: Bottom test image from dry data volume
;     topPts: Voxel coordinates for top image in dry data volume
;     botPts: Voxel coordinates for bottom image in dry data volume
;     showImgFitting: If not zero, each attempted fit is displayed
;
; EXAMPLE:
;   ; Evaluate the goodness of fit of testCoefs:
;   meritVal = A3D_TransFunction_Img(testCoefs)
;
; MODIFICATION HISTORY:
;   Written by Richard Ketcham, April 2002
; ========================================================================
Function A3D_TransFunction_Img, c
  common A3D_Data_Image

  start = SysTime(1)
; Create transformation matrix
  trans = Identity(4)
  hdim = dim/2
; Put center at origin
  T3D, trans, MATRIX=trans, TRANSLATE=-hdim
; Rotate about all 3 axes
  T3D, trans, MATRIX=trans, ROTATE=[c[3],c[4],c[5]]
; Scale if requested
  if (N_Elements(c) EQ 7) then T3D, trans, MATRIX=trans, scale=Replicate(c[6],3)
; Put center back
  T3D, trans, MATRIX=trans, TRANSLATE=hdim
; Translate as necessary
  T3D, trans, MATRIX=trans, TRANSLATE=[c[0],c[1],c[2]]

; Apply it to coordinates
  topIntPts = Vert_T3D(topPts, MATRIX=trans)
  botIntPts = Vert_T3D(botPts, MATRIX=trans)

; Interpolate
  topIntVals = Interpolate(*imgTarget, topIntPts[0,*], topIntPts[1,*], topIntPts[2,*], MISSING=0.0)
  botIntVals = Interpolate(*imgTarget, botIntPts[0,*], botIntPts[1,*], botIntPts[2,*], MISSING=0.0)

; Find difference
  if (correl EQ 0) then begin
    topDiff = Abs(topIntVals - topImg)
    botDiff = Abs(botIntVals - botImg)
  endif else begin
    topDiff = topIntVals - topImg
    botDiff = botIntVals - botImg
  endelse

; Get rid of borders
  topDiff[border] = 0
  botDiff[border] = 0

; Generate animation
  if (showImgFitting) then begin
    topDisp = (topIntVals - topImg) + midLevel
    botDisp = (botIntVals - botImg) + midLevel
    topDisp[border] = midLevel
    botDisp[border] = midLevel

; Display differences images, with independent scaling
    tvscl, Reform(topDisp, dim[0], dim[0])
    tvscl, Reform(botDisp, dim[0], dim[0]), 1
  endif

; Wait a fraction of a second to allow user interrupts to be noticed.
  wait, 0.001

  if (correl EQ 0) then begin
    topHist = Histogram(topDiff, MIN=0, BINSIZE=tailSize)
    topCount = N_Elements(topDiff) - topHist[0]
    botHist = Histogram(botDiff, MIN=0, BINSIZE=tailSize)
    botCount = N_Elements(botDiff) - botHist[0]

    print, [c, topCount+botCount]
    return, topCount+botCount
  endif

  ss = TOTAL(topDiff^2)+TOTAL(botDiff^2)
  print, [c, ss]
  return, ss
End


; ========================================================================
; PROCEDURE NAME:
; A3D_TweakRotation
;
; PURPOSE:
;   Adjusts the rotation of an image to better match with another.  Uses a
; divide and conquer algorithm to minimize the number of voxels exceeding
; a prescribed departure from the mean when the original and fitted images
; are subtracted.
;
; POSITIONAL PARAMETERS:
;   origImg: Original image to be matched.
;   fitImg: Fitted image to be matched more closely to origImg
;   esdSD: Estimated standard deviation of a perfect image subtraction.
;
; OUTPUTS:
;   fitImg is rotated as appropriate.
;
; KEYWORD PARAMETERS:
;   SHOW: Set to 1 to display the fitting process.
;   ANGLE_SWEEP: The angular range to check, in degrees.  Default = 0.5.
;
; COMMON BLOCKS:
;   A3D_Data_Image: imgTarget, midLevel, tailSize, border, dim, topImg, $
;         botImg, topPts, botPts, showImgFitting
;     imgTarget: Pointer to the "target" (wet) data set
;     midLevel: Middle grayscale level of image data
;     correl: If zero, use number of outliers; if not, use correlation
;     tailSize: Grayscale excursion of differenced images to count
;     border: Indices of image boundary to exclude from consideration
;     dim: Data set dimensions
;     topImg: Top test image from dry data volume
;     botImg: Bottom test image from dry data volume
;     topPts: Voxel coordinates for top image in dry data volume
;     botPts: Voxel coordinates for bottom image in dry data volume
;     showImgFitting: If not zero, each attempted fit is displayed
;   A3D_Tweak: ImgWinIndex, CharPixmapIndex
;     ImgWinIndex: Persistent IDL window number for displaying results
;     CharPixMapIndex: IDL offscreen bitmap to help display text
;
; EXAMPLE:
;   ; Tweak rotation of fitImg to better match origImg
;   A3D_TweakRotation(origImg, fitImg, estSD, /SHOW)
;
; MODIFICATION HISTORY:
;   Written by Richard Ketcham, June 2003
; ========================================================================
Pro A3D_TweakRotation, origImg, fitImg, estSD, SHOW=show, ANGLE_SWEEP=angleSweep
  common A3D_Data_Image
  common A3D_Tweak

  if not Keyword_Set(angleSweep) then angleSweep = 0.5

  rotOffset = -2.0
  tol=0.02

  shiftVal = (Max(origImg) LE 4095) ? -4 : -8
  numPixels = N_Elements(origImg)*1.0

  if Keyword_Set(show) AND (ImgWinIndex EQ -1) then begin
    Window, /Free, Title='Image animation', xsize = dim[0], ysize = dim[1]
    ImgWinIndex = !D.Window

; Set up character printing bitmap
    window, /Free, xsize=dim[0], ysize = dim[1], /pixmap
    CharPixmapIndex = !D.Window
; Set to use hardware (OS-provided) fonts
    !P.font = 0
; Choose the font
    DEVICE, SET_FONT= "ARIAL*BOLD*16"
  endif

  currRot = Rot(origImg, rotOffset, CUBIC=-0.5)

  loAngle = -angleSweep
  hiAngle = angleSweep

; Get endpoints
  rotImg = ROT(fitImg, rotOffset+loAngle, CUBIC=-0.5)
  currDiff = (rotImg - currRot)
  currDiff[border] = midLevel
  tails = Where((currDiff GT (midLevel+tailSize)) OR (currDiff LT (midLevel-tailSize)), count)
  loProp = count/numPixels

  rotImg = ROT(fitImg, rotOffset+hiAngle, CUBIC=-0.5)
  currDiff = (rotImg - currRot) + midLevel
  currDiff[border] = midLevel
  tails = Where((currDiff GT (midLevel+tailSize)) OR (currDiff LT (midLevel-tailSize)), count)
  hiProp = count/numPixels

; Get the (theoretical) worst value, for calculating ratio
  maxProp = hiProp > loProp
  numIt = 1

  repeat begin
    newAngle = (hiAngle + loAngle)*0.5

    rotImg = ROT(fitImg, rotOffset+newAngle, CUBIC=-0.5)
    currDiff = (rotImg - currRot) + midLevel
    currDiff[border] = midLevel
    tails = Where((currDiff GT (midLevel+tailSize)) OR (currDiff LT (midLevel-tailSize)), count)

    newProp = count/numPixels

    if Keyword_Set(show) then begin
      imageToShow = Ishft(Long(currDiff),shiftVal)  ; Convert to 8-bit

; Compile overlay
      label = 'Rotation = ' + String(newAngle,FORMAT='(F6.3)') + $
        ', Tail = ' + String(newProp, FORMAT='(e11.4)')
      Wset, CharPixmapIndex
      if (numIt EQ 1) then Erase
; Write label
      xyouts, 3, dim[1]-16*numIt, label, /DEVICE
      ind = Where(tvrd(/ORDER) eq 255)
      imageToShow[ind] = 255B

      Wset, ImgWinIndex
      TV, imageToShow, /ORDER
    endif

    if (newProp GT loProp) AND (newProp GT hiProp) then begin
; This is sort of an error condition, but in most cases is triggered by the merit function
;   being imperfect.
; One such case is where there is a very large "real" misfit between slices, because of a
;   large slice-to-slice change (feature at low angle to scan plane).  This might be solved
;   by running this loop once to "do the best we can", then finding the most offending voxels
;   (perhaps at some larger tail value) and repeating the analysis with those voxels left out.
; This will probably take us from the 0.1-0.05 degree precision level to 0.01
; For now, we'll just take the minimum we've found so far, but print a warning
      print, 'Dual minima found'
      loAngle = (hiProp LT loProp) ? hiAngle : loAngle
      loProp = hiProp < loProp
      hiAngle = loAngle
      hiProp = loProp
    endif else if (hiProp GT loProp) then begin
      hiProp = newProp
      hiAngle = newAngle
    endif else begin
      loProp = newProp
      loAngle = newAngle
    endelse
    numIt = numIt + 1
  endrep until (hiAngle - loAngle) LT tol
  minAngle = (hiProp LT loProp) ? hiAngle : loAngle
  print, minAngle

; Make corrected images
  fitImg = ROT(fitImg, minAngle, CUBIC=-0.5)
  fitImg = fitImg > 0 ; Correct underflow from rotation near border
End


; ========================================================================
; PROCEDURE NAME:
; A3D_PorosityCDF
;
; PURPOSE:
;   Create a CDF of % volume vs. % porosity given an image stack showing
; partial porosity.
;
; POSITIONAL PARAMETERS:
;   fluidGS: Grayscale value for 100% porosity; use 16-bit value minus 2^15
;   outfile: Path+name for CDF file
;
; KEYWORD PARAMETERS:
;   CDF: Set to named variable to return CDF
;   PHI: Set to named variable to return phi (porosity)
;   DIFF: Difference stack; set to use or receive
;   MEDIAN: Pre-smooth the image data, using box median filter of width <med>
;   FIT_POROSITY: Hard-wires the net porosity represented in the CDF.
;   CORRECT_SHIFT: If FIT_POROSITY is specified, setting this parameter
;     causes the source of error to be interpreted as a net grayscale shift
;     between the two data sets, probably caused by beam drift, and the
;     new drift is estimated.  Otherwise, the variable fluidGS is
;     adjusted.
;
; OUTPUTS:
;   Keyword variables CDF and PHI are filled, if specified.
;   Creates a text file with results.
;
; EXAMPLE:
;   ; Calculate CDF for sample 7f, assume df(H2O) is 4279
;   A3D_PorosityCDF, 4279, 'c:\files\7rcdf.txt'
;
; MODIFICATION HISTORY:
;   Written by Richard Ketcham, July 2002
; ========================================================================
Pro A3D_PorosityCDF, fluidGS, outfile, CDF=cdfm, PHI=phi, DIFF=diff, $
    MEDIAN=med, FIT_POROSITY=fitPorosity, CORRECT_SHIFT=correctShift

  if (NOT Keyword_Set(diff)) OR (N_Elements(diff) LE 1) then begin
    diff = B3D_ReadTiffs('tif', /Noptr)
  endif
  if (N_Elements(diff) LE 1) then return

  sz = Size(diff)
  totalSurplus = Total(diff)

; Filter the images, if necessary
  if Keyword_Set(med) then begin
    diffm = diff
    for i=0,sz[3]-1 do diffm[*,*,i] = Median(diffm[*,*,i], med)
    histm = Histogram(diffm,Min=0)
  endif else histm = Histogram(diff,Min=0)

; Do not consider black edges
  histm[0] = 0
; Truncate values likely to be influenced by averaging of data with black edges
  histm[1:30000] = 0

; Calculate grayscale surplus, number of voxels in overlap region
  totalSurplus = Total(histm*indgen(N_Elements(histm),/long))
  numOverlap = Total(histm)

  meanSurplus = 1.*totalSurplus/numOverlap - 2.^15
  if Keyword_Set(fitPorosity) then begin
    if Keyword_Set(correctShift) then begin
      shiftVal = fluidGS*fitPorosity - meanSurplus
      meanSurplus = meanSurplus + shiftVal
      print, 'Estimated GS shift = ', shiftVal
    endif else begin
      fluidGS = meanSurplus/fitPorosity
      shiftVal = 0
      print, 'Fitted fluid GS = ', fluidGS
    endelse
  endif else shiftVal = 0

; Fold over zero
  bottomHalf = histm[0:(32767-shiftVal)]
  bottomHalf = -Reverse(bottomHalf)
  topHalf = LonArr(N_Elements(bottomHalf))
  topHalf[0] = histm[(32768-shiftVal):N_Elements(histm)-1]

  histm = topHalf + bottomHalf
  histm = histm > 0 ; Omit negatives
  histm[0] = histm[0] + numOverlap - Total(histm)

; Fold over values above 100% porosity, if any
  if (fluidGS LT N_Elements(histm)) then begin
    bottomHalf = histm[0:fluidGS-1]
    topHalf = histm[fluidGS:N_Elements(histm)-1]
    if (N_Elements(topHalf) GT fluidGS) then begin
      topHalf[fluidGS-1] = Total(topHalf[fluidGS-1:N_Elements(topHalf)-1])
      topHalf = topHalf[0:fluidGS-1]
    endif
    if (fluidGS GT N_Elements(topHalf)) then begin
      filledTop = LonArr(fluidGS)
      filledTop[0] = topHalf
      topHalf = filledTop
    endif
    topHalf = -Reverse(topHalf)
    histm = topHalf + bottomHalf
    histm = histm > 0
    histm[fluidGS-1] = histm[fluidGS-1] + numOverlap - Total(histm)
  endif

; Construct phi
  phi = IndGen(fluidGS+1,/float)/fluidGS

; Estimate total porosity
  estPorosity = TOTAL(histm*phi)/TOTAL(histm)

; Compile CDF
  cdfm = histm*1.0
  for i=1,N_Elements(cdfm)-1 do cdfm[i] = cdfm[i] + cdfm[i-1]
  for i=0,N_Elements(cdfm)-1 do cdfm[i] = cdfm[i]/cdfm[N_Elements(cdfm)-1]

; Output some results
  print, "Number of overlap voxels is: ", numOverlap
  print, "Mean grayscale surplus is: ", meanSurplus
  print, "Estimated porosity is: ", estPorosity

  if (N_Params() EQ 2) then begin
    openw, 1, outfile
    for i=0,N_Elements(cdfm)-1 do printf, 1, cdfm[i], String(9B), phi[i]
    close, 1
  endif

  diffm = 0
  histm = 0
End
