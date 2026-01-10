FUNCTION minimize_me_2,X,Y,pars
 common stuff,FFTideal,observed,ideal,maxerr,n,llim,rrlim,dlim,ulim,tstr,x0,y0,radius,mask,r,header
 ; unpack the parameter guesses
 p=pars(0)
 pars(1)=min([pars(1),3.])
 w=pars(1)
 pedestal=pars(2)
 get_kernel,kernel,p,w
 ;calculate the SSE to be returned as the target tominimize
 ; convolve ideal image with current kernel model
 paddedfft,kernel,arrayout
 modelofobservation=arrayout+pedestal
 scattered=modelofobservation-ideal
 diff=mask*(observed-modelofobservation)	; just the Sky
 !P.MULTI=[0,1,2]
 err=total(diff^2)	
 thing=err
 thing=mask*modelofobservation
 if (err lt maxerr) then begin
     ; write out the results
     writefits,strcompress('modelofobservation.fit',/remove_all),modelofobservation,header
     writefits,strcompress('scattered.fit',/remove_all),scattered,header
     writefits,strcompress('cleaned.fit',/remove_all),observed-scattered,header
     maxerr=err
     tvscl,diff*mask
     print,'Best so far: parameters =',pars,'SSE =',err
     surface,congrid(diff,100,100),title='Residuals',charsize=2
     histo,diff,-100,100,1
     endif
 return,thing
 end
