PRO  make_mpg, prefix=prefix, suffix=suffix, nstart=nstart, nend=nend, digits=digits, $
    dims=dims, format=format, frame_rate=frame_rate, mpeg_file=mpeg_file, tmp_dir=tmp_dir
;-----------------------------------------------------------
; the image filenames are assumed of the format: image#.ext,
; where # is the index of the sequence
; and ext is one of the suported image types.
;-----------------------------------------------------------

;------- Check the arguments
if keyword_set(mpeg_file) eq 0  then begin
    mpeg_file='outfile.mpg'
end

print,keyword_set(prefix),keyword_set(suffix),keyword_set(nstart),keyword_set(nend),nstart,nend

if keyword_set(prefix) eq 0  then begin
    print, 'prefix is  missing'
    return
end
if keyword_set(suffix) eq 0  then begin
  print, 'suffix is  missing'
  return
end

if keyword_set(nstart) eq 0 then begin
    nstart=0
    print, 'nstart=', nstart
end

if keyword_set(nend)  eq 0 then begin
   nend=0
    print, 'n-end=', nend
end

if keyword_set(format) eq 0 then begin
    format = 0
end
if keyword_set(frame_rate) eq 0 then begin
    frame_rate = 5
end

if keyword_set(tmp_dir)  eq 0  then begin
        tmp_dir='.'
end

if (nstart gt nend) then begin
    print, 'nstart, and nend do not make sense',nstart,nend
  return
end
;------- Create the MPEG
if keyword_set(dims)  ne 1  then begin
    mympeg = obj_new('IDLgrMPEG', filename = mpeg_file, format=format, frame_rate=frame_rate, temp_directory=tmp_dir)
endif else begin
    mympeg = obj_new('IDLgrMPEG', filename = mpeg_file, dimensions=dims, format=format, frame_rate=frame_rate, temp_directory=tmp_dir)
endelse
;------- Read the images
for j = nstart, nend do begin
print,j,' of ',nend
  n = string(digits)
  format_str = '(I' + n+ '.' +n +')'
  index = string(format=format_str, j)
  image_name = prefix +strcompress(index, /remove_all) + '.' + suffix
  image = READ_IMAGE (image_name)
  image_size = SIZE(image)

  if (image_size[0] eq  0) then begin
    print, 'Cannot read image file: ', image_name
    return
  end
;------- Add the image to the sequence
mympeg -> Put, reverse(image,3) , j
;print, '.'
endfor

;------- Generate the Mpeg
mympeg -> Save
obj_destroy, mympeg
print, 'done'
return
END

make_mpg,prefix="c:\temp\test",suffix="jpg",nstart=100,nend=373,digits=3, mpeg_file="c:\temp\movie.mpg",frame_rate=2

;make_mpg,prefix="c:\temp\new_image",suffix="jpg",nstart=001,nend=294,digits=3, mpeg_file="c:\temp\movie.mpg",frame_rate=2
end
