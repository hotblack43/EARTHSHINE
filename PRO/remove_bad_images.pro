PRO getbasicname,instr,basicname
idx=strpos(instr,'/245')
basicname=strmid(instr,idx+1,strlen(instr))
return
end

baddir='/data/pth/DATA/ANDOR/BIASSUBTRACTEDALIGNEDSUM/BADIMAGES/'

night='JD2455856/'
night='JD2455905/'	; lunar eclipse!
night='JD2455934/'
night='JD2456000/'
night='JD2456014/';	 intermittent focus DARKCURRENTREDUCEDproblems
night='JD2456017/'
night='JD2456032/'
night='JD2456062/'
night='JD2455748/'
night='JD2455857/'
night='JD2455912/'
night='JD2455938/'
night='JD2456002/'
night='JD2456015/'
night='JD2456033/'
night='JD2456063/'
night='JD2455814/'	; DITHER images
night='JD2455858/'
night='JD2455917/'	; extremely good
night='JD2455940/'
night='JD2456003/'
night='JD2456016/'
night='JD2456035/'
night='JD2456064/'
night='JD2455836/'	; FW stuck
night='JD2455859/'
night='JD2455923/'	; cable in DS
night='JD2455943/'
night='JD2456004/'
night='JD2456017/'
night='JD2456045/'
night='JD2456073/'
night='JD2455847/'	; DITHER
night='JD2455864/'
night='JD2455924/'
night='JD2455944/'
night='JD2456005/'
night='JD2456028/'	; SKE
night='JD2456046/'
night='JD2456074/'
night='JD2455849/'	; DITHER
night='JD2455865/'	; not v. clear
night='JD2455930/'
night='JD2455945/'
night='JD2456006/'
night='JD2456029/'
night='JD2456047/'
night='JD2456075/'
night='JD2455854/'	; DITHER
night='JD2455886/'
night='JD2455932/'
night='JD2455988/'
night='JD2456007/'
night='JD2456030/'
night='JD2456061/'

files=file_search('/data/pth/DATA/ANDOR/BIASSUBTRACTEDALIGNEDSUM/'+night+'*.fit*',count=n)
print,'Found ',n,' images.'
for i=0,n-1,1 do begin
im=readfits(files(i))
print,'Image ',i,' of ',n-1
print,files(i)
print,min(im),max(im)
getbasicname,files(i),basicname
tvscl,hist_equal(im)
a=''
a=get_kbrd()
if (a eq 'q' or a eq 'Q') then stop
if (a eq 'r' or a eq 'R') then begin
print,'Want to move ',files(i),' to ',baddir+basicname
FILE_MOVE,files(i),baddir+basicname
endif
if (a eq 'k' or a eq 'K') then begin
print,'I am keeping that image'
endif
endfor
end
