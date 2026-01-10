 PRO get_all_ideal_models,jd,image_stack,labels
 path='/media/thejll/OLDHD/UNIVERSALSETOFMODELS/*'
 pathlen=strlen(path)
 name=strcompress('*'+jd+'*.fits',/remove_all)
 files=file_search(path,name,count=n)
 image_stack=[]
 labels=[]
 for i=0,n-1,1 do begin
     albstr=strmid(files(i),strpos(files(i),'.fits')-3,3)
     image_stack=[[[image_stack]],[[readfits(files(i))]]]
     len=strpos(files(i),'.fits')
     lab=strmid(files(i),strlen(path)-1,strpos(files(i),'ideal')-strlen(path))
     labels=[labels,lab+'_'+albstr]
     endfor
 return
 end
